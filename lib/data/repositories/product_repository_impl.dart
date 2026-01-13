import 'package:dartz/dartz.dart';
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
  Future<Either<Failure, List<Product>>> getProducts(
    int skip,
    int limit,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await apiClient.get(
          AppConstants.productsEndpoint,
          queryParameters: {'skip': skip, 'limit': limit},
        );

        final List productsRaw = response.data['products'];

        // Fetch local favorites to merge status
        // Efficient enough for Hive map lookup
        final favBox = dbService.favoritesBox;

        final products =
            productsRaw.map((e) {
              final json = e as Map<String, dynamic>;
              final id = json['id'];
              // Check if favorite
              json['isFavorite'] = favBox.containsKey(id);
              return ProductModel.fromJson(json);
            }).toList();

        // Cache products
        final prodBox = dbService.productsBox;
        for (var product in products) {
          await prodBox.put(product.id, product);
        }

        return Right(products);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      // Fetch from local Hive box
      try {
        final prodBox = dbService.productsBox;
        final favBox = dbService.favoritesBox;

        // Hive stores in no particular order (insertion order mostly), but keys are IDs.
        // We need to implement pagination (skip/limit) manually on the list.
        // This is not efficient for large datasets but typical for Hive/local simple caching.
        final allProducts = prodBox.values.toList();

        // Apply skip/limit
        if (skip >= allProducts.length) {
          return const Right([]);
        }
        final end =
            (skip + limit < allProducts.length)
                ? skip + limit
                : allProducts.length;
        final products =
            allProducts.getRange(skip, end).map((p) {
              // Ensure isFavorite is up to date (though strictly, prodBox should be updated on toggle)
              // But let's check favBox to be sure
              // Since ProductModel is immutable, we might need a copy if we want to enforce consistency
              // But here we just return what's in box.
              // Better: Check favBox.
              bool isFav = favBox.containsKey(p.id);
              if (p.isFavorite != isFav) {
                // Return updated model (hacky without copyWith)
                return ProductModel(
                  id: p.id,
                  title: p.title,
                  description: p.description,
                  category: p.category,
                  price: p.price,
                  discountPercentage: p.discountPercentage,
                  rating: p.rating,
                  stock: p.stock,
                  brand: p.brand,
                  thumbnail: p.thumbnail,
                  images: p.images,
                  availabilityStatus: p.availabilityStatus,
                  warrantyInformation: p.warrantyInformation,
                  updatedAt: p.updatedAt,
                  isFavorite: isFav,
                );
              }
              return p;
            }).toList();

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
        final List productsRaw = response.data['products'];

        final favBox = dbService.favoritesBox;

        final products =
            productsRaw.map((e) {
              final json = e as Map<String, dynamic>;
              final id = json['id'];
              json['isFavorite'] = favBox.containsKey(id);
              return ProductModel.fromJson(json);
            }).toList();

        return Right(products);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      // Search locally
      try {
        final prodBox = dbService.productsBox;
        final favBox = dbService.favoritesBox;

        final products =
            prodBox.values
                .where((p) {
                  return p.title.toLowerCase().contains(query.toLowerCase());
                })
                .map((p) {
                  bool isFav = favBox.containsKey(p.id);
                  if (p.isFavorite != isFav) {
                    return ProductModel(
                      id: p.id,
                      title: p.title,
                      description: p.description,
                      category: p.category,
                      price: p.price,
                      discountPercentage: p.discountPercentage,
                      rating: p.rating,
                      stock: p.stock,
                      brand: p.brand,
                      thumbnail: p.thumbnail,
                      images: p.images,
                      availabilityStatus: p.availabilityStatus,
                      warrantyInformation: p.warrantyInformation,
                      updatedAt: p.updatedAt,
                      isFavorite: isFav,
                    );
                  }
                  return p;
                })
                .toList();

        return Right(products);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getFavorites() async {
    try {
      final favBox = dbService.favoritesBox;
      final products =
          favBox.values.map((p) {
            // Ensure isFavorite is true
            if (!p.isFavorite) {
              return ProductModel(
                id: p.id,
                title: p.title,
                description: p.description,
                category: p.category,
                price: p.price,
                discountPercentage: p.discountPercentage,
                rating: p.rating,
                stock: p.stock,
                brand: p.brand,
                thumbnail: p.thumbnail,
                images: p.images,
                availabilityStatus: p.availabilityStatus,
                warrantyInformation: p.warrantyInformation,
                updatedAt: p.updatedAt,
                isFavorite: true,
              );
            }
            return p;
          }).toList();
      return Right(products);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(Product product) async {
    try {
      final favBox = dbService.favoritesBox;
      // Convert to Model if not already (safest way involves re-creating)
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

      await favBox.put(product.id, productModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(int productId) async {
    try {
      final favBox = dbService.favoritesBox;
      await favBox.delete(productId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
