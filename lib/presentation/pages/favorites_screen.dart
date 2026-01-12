import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../controllers/favorites_controller.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends GetView<FavoritesController> {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure we reload favorites when entering screen
    controller.loadFavorites();

    return Scaffold(
      appBar: AppBar(title: Text('favorites'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.favorites.isEmpty) {
          return Center(child: Text('no_products'.tr));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: controller.favorites.length,
          itemBuilder: (context, index) {
            final product = controller.favorites[index];
            return ProductCard(
              product: product,
              onTap: () => Get.toNamed(Routes.DETAILS, arguments: product),
              onFavoriteToggle: null, // Removed toggle here or implement removal
            );
          },
        );
      }),
    );
  }
}
