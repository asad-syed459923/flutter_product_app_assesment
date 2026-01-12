import 'package:get/get.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/entities/product.dart';

class FavoritesController extends GetxController {
  final GetFavoritesUseCase getFavoritesUseCase;

  FavoritesController({required this.getFavoritesUseCase});

  var favorites = <Product>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    isLoading.value = true;
    final result = await getFavoritesUseCase(NoParams());
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (data) => favorites.assignAll(data),
    );
    isLoading.value = false;
  }
}
