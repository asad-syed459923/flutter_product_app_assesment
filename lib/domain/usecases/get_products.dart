import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsParams {
  final int skip;
  final int limit;
  GetProductsParams({required this.skip, required this.limit});
}

class GetProductsUseCase implements UseCase<List<Product>, GetProductsParams> {
  final ProductRepository repository;
  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(GetProductsParams params) async {
    return await repository.getProducts(params.skip, params.limit);
  }
}
