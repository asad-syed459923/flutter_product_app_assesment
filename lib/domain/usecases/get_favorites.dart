import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetFavoritesUseCase implements UseCase<List<Product>, NoParams> {
  final ProductRepository repository;
  GetFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) async {
    return await repository.getFavorites();
  }
}
