import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_product_app_assesment/presentation/controllers/favorites_controller.dart';
import 'package:flutter_product_app_assesment/presentation/controllers/product_controller.dart';
import 'package:flutter_product_app_assesment/presentation/controllers/settings_controller.dart';
import 'package:get/get.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../../data/datasources/db_service.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/search_products.dart';
import '../../domain/usecases/toggle_favorite.dart';

class DependencyInjection {
  static Future<void> init() async {
    // Core
    final dio = Dio();
    Get.put<ApiClient>(ApiClient(dio: dio));
    Get.put<NetworkInfo>(NetworkInfoImpl(Connectivity()));
    
    final dbService = DbService(); 
    await dbService.init();
    Get.put<DbService>(dbService);

    // Repositories
    Get.put<ProductRepository>(ProductRepositoryImpl(
      apiClient: Get.find(),
      dbService: Get.find(),
      networkInfo: Get.find(),
    ));

    // UseCases
    Get.put(GetProductsUseCase(Get.find()));
    Get.put(SearchProductsUseCase(Get.find()));
    Get.put(GetFavoritesUseCase(Get.find()));
    Get.put(ToggleFavoriteUseCase(Get.find()));

    // Controllers (Register as Singleton or Factory? Settings is Singleton. Product often Singleton or Scoped. Let's make them singletons for simplicity here or lazy)
    Get.put<SettingsController>(SettingsController());
    Get.put<ProductController>(ProductController(
      getProductsUseCase: Get.find(),
      searchProductsUseCase: Get.find(),
      toggleFavoriteUseCase: Get.find(),
    ));
    Get.put<FavoritesController>(FavoritesController(
      getFavoritesUseCase: Get.find(),
    ));
  }
}
