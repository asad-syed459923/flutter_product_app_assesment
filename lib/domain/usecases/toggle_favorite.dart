import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class ToggleFavoriteUseCase implements UseCase<void, Product> {
  final ProductRepository repository;
  ToggleFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Product product) async {
    if (product.isFavorite) {
      return await repository.removeFromFavorites(product.id);
    } else {
      return await repository.addToFavorites(product);
    }
  }
}
