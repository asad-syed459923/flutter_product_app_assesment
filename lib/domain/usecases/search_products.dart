import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class SearchProductsUseCase implements UseCase<List<Product>, String> {
  final ProductRepository repository;
  SearchProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(String query) async {
    return await repository.searchProducts(query);
  }
}
