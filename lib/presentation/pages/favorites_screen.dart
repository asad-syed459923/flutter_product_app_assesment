import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../controllers/favorites_controller.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends GetView<FavoritesController> {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    controller.loadFavorites();

    return Scaffold(
      appBar: AppBar(title: Text('favorites'.tr)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;

          return Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.favorites.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.heart_broken_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text('no_products'.tr, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                  ],
                ),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: width > 600 ? 0.65 : 0.55,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: controller.favorites.length,
              itemBuilder: (context, index) {
                final product = controller.favorites[index];
                return ProductCard(
                  product: product,
                  onTap: () => Get.toNamed(Routes.DETAILS, arguments: product),
                  onFavoriteToggle: null,
                );
              },
            );
          });
        },
      ),
    );
  }
}
