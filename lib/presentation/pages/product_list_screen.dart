import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../controllers/product_controller.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends GetView<ProductController> {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Get.toNamed(Routes.FAVORITES),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(Routes.SETTINGS),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'search'.tr,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                controller.onSearchChanged(value);
              },
            ),
          ),
          Expanded(
            child: Obx(() {
               if (controller.isLoading.value && controller.products.isEmpty) {
                 return const Center(child: CircularProgressIndicator());
               }
               
               if (controller.errorMessage.isNotEmpty && controller.products.isEmpty) {
                 return Center(child: Text(controller.errorMessage.value));
               }

               if (controller.products.isEmpty) {
                 return Center(child: Text('no_products'.tr));
               }

               return RefreshIndicator(
                 onRefresh: () async => await controller.fetchProducts(isRefresh: true),
                 child: GridView.builder(
                   controller: controller.scrollController,
                   padding: const EdgeInsets.all(8),
                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                     crossAxisCount: 2,
                     childAspectRatio: 0.7,
                     crossAxisSpacing: 8,
                     mainAxisSpacing: 8,
                   ),
                   itemCount: controller.products.length + (controller.isMoreLoading.value ? 1 : 0),
                   itemBuilder: (context, index) {
                     if (index == controller.products.length) {
                       return const Center(child: CircularProgressIndicator());
                     }
                     final product = controller.products[index];
                     return ProductCard(
                       product: product,
                       onTap: () => Get.toNamed(Routes.DETAILS, arguments: product),
                       onFavoriteToggle: () => controller.toggleFavorite(product),
                     );
                   },
                 ),
               );
            }),
          ),
        ],
      ),
    );
  }
}
