import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts(int skip, int limit);
  Future<Either<Failure, List<Product>>> searchProducts(String query);
  Future<Either<Failure, List<Product>>> getFavorites();
  Future<Either<Failure, void>> addToFavorites(Product product);
  Future<Either<Failure, void>> removeFromFavorites(int productId);
}
