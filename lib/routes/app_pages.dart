import 'package:get/get.dart';
import '../presentation/pages/favorites_screen.dart';
import '../presentation/pages/product_detail_screen.dart';
import '../presentation/pages/product_list_screen.dart';
import '../presentation/pages/settings_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const ProductListScreen(),
    ),
    GetPage(
      name: Routes.DETAILS,
      page: () => const ProductDetailScreen(),
    ),
    GetPage(
      name: Routes.FAVORITES,
      page: () => const FavoritesScreen(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsScreen(),
    ),
  ];
}
