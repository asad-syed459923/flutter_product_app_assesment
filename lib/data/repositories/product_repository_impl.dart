import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/db_service.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ApiClient apiClient;
  final DbService dbService;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.apiClient,
    required this.dbService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Product>>> getProducts(int skip, int limit) async {
    // Internet First logic as requested? 
    // Wait, prompt says: "Use internet first mechanism for data fetch"
    // "Implement caching for Products..."
    
    if (await networkInfo.isConnected) {
      try {
        final response = await apiClient.get(
          AppConstants.productsEndpoint,
          queryParameters: {'skip': skip, 'limit': limit},
        );

        final List productsJson = response.data['products'];
        final products = productsJson.map((e) => ProductModel.fromJson(e)).toList();

        // Cache products
        final db = await dbService.database;
        final batch = db.batch();
        for (var product in products) {
          batch.insert(
            AppConstants.tableNameProducts,
            product.toJson()..remove('isFavorite'), // Avoid overwriting isFavorite if implementation differed, but here we separate tables or careful merge
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);

        return Right(products);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      // Fetch from local
      try {
        final db = await dbService.database;
        final maps = await db.query(
          AppConstants.tableNameProducts,
          limit: limit,
          offset: skip,
        );
        final products = maps.map((e) => ProductModel.fromLocalMap(e)).toList();
        return Right(products);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await apiClient.get(
          AppConstants.searchEndpoint,
          queryParameters: {'q': query},
        );
        final List productsJson = response.data['products'];
        final products = productsJson.map((e) => ProductModel.fromJson(e)).toList();
        return Right(products);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
       // Search locally
       try {
        final db = await dbService.database;
        final maps = await db.query(
          AppConstants.tableNameProducts,
          where: 'title LIKE ?',
          whereArgs: ['%$query%'],
        );
        final products = maps.map((e) => ProductModel.fromLocalMap(e)).toList();
        return Right(products);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getFavorites() async {
    try {
      final db = await dbService.database;
      final maps = await db.query(AppConstants.tableNameFavorites);
      final products = maps.map((e) => ProductModel.fromLocalMap(e..['isFavorite'] = 1)).toList();
      return Right(products);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(Product product) async {
    try {
      final db = await dbService.database;
      final productModel = ProductModel(
        id: product.id,
        title: product.title,
        description: product.description,
        category: product.category,
        price: product.price,
        discountPercentage: product.discountPercentage,
        rating: product.rating,
        stock: product.stock,
        brand: product.brand,
        thumbnail: product.thumbnail,
        images: product.images,
        availabilityStatus: product.availabilityStatus,
        warrantyInformation: product.warrantyInformation,
        updatedAt: product.updatedAt,
        isFavorite: true,
      );
      await db.insert(
        AppConstants.tableNameFavorites,
        productModel.toJson()..remove('isFavorite'), // Remove isFavorite from map if table doesn't have it explicitly or if I just want to store data
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(int productId) async {
    try {
      final db = await dbService.database;
      await db.delete(
        AppConstants.tableNameFavorites,
        where: 'id = ?',
        whereArgs: [productId],
      );
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
