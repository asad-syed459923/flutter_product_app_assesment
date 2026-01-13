import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/search_products.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../domain/entities/product.dart';
import 'favorites_controller.dart';

class ProductController extends GetxController {
  final GetProductsUseCase getProductsUseCase;
  final SearchProductsUseCase searchProductsUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  ProductController({
    required this.getProductsUseCase,
    required this.searchProductsUseCase,
    required this.toggleFavoriteUseCase,
  });

  var products = <Product>[].obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var errorMessage = ''.obs;
  var isSearching = false.obs;
  
  final int limit = 20;
  int skip = 0;
  bool canLoadMore = true;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  var searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    scrollController.addListener(_onScroll);
    
    debounce(searchText, (value) {
      search(value);
    }, time: const Duration(milliseconds: 500));
  }

  void onSearchChanged(String value) {
    searchText.value = value;
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 &&
        !isMoreLoading.value &&
        canLoadMore &&
        !isSearching.value) {
      loadMoreProducts();
    }
  }

  Future<void> fetchProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      skip = 0;
      products.clear();
      canLoadMore = true;
      errorMessage.value = '';
    }

    if (!canLoadMore && !isRefresh) return;

    if (skip == 0) {
      isLoading.value = true;
    } else {
      isMoreLoading.value = true;
    }

    final result = await getProductsUseCase(GetProductsParams(skip: skip, limit: limit));

    result.fold(
      (failure) {
        if (skip == 0) errorMessage.value = failure.message;
        else Get.snackbar('Error', failure.message);
      },
      (newProducts) {
        if (newProducts.length < limit) {
          canLoadMore = false;
        }
        products.addAll(newProducts);
        skip += limit;
      },
    );

    isLoading.value = false;
    isMoreLoading.value = false;
  }

  Future<void> loadMoreProducts() async {
    await fetchProducts();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      isSearching.value = false;
      fetchProducts(isRefresh: true);
      return;
    }

    isSearching.value = true;
    isLoading.value = true;
    errorMessage.value = '';
    
    final result = await searchProductsUseCase(query);
     result.fold(
      (failure) {
        errorMessage.value = failure.message;
        products.clear();
      },
      (searchResults) {
        products.assignAll(searchResults);
      },
    );

    isLoading.value = false;
  }

  Future<void> toggleFavorite(Product product) async {
    final result = await toggleFavoriteUseCase(product);
    result.fold(
      (failure) => Get.snackbar('Error', 'Could not update favorite'),
      (_) {
        // Refresh local state if needed, or let FavoritesController handle the list update via stream or direct update
        // We might want to update the specific product in 'products' list isFavorite flag locally to reflect UI immediately
        // But Product entity is immutable.
        // We can just trigger a refresh or find index and replace.
        // Since we are using GetX and separate Favorites list, we should probably update FavoritesController too.
        if (Get.isRegistered<FavoritesController>()) {
           Get.find<FavoritesController>().loadFavorites();
        }
        
        // Update local list for UI feedback (heart icon)
        final index = products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          final current = products[index];
          final newStatus = !current.isFavorite;
          
          final newProduct = Product(
            id: current.id,
            title: current.title,
            description: current.description,
            category: current.category,
            price: current.price,
            discountPercentage: current.discountPercentage,
            rating: current.rating,
            stock: current.stock,
            brand: current.brand,
            thumbnail: current.thumbnail,
            images: current.images,
            availabilityStatus: current.availabilityStatus,
            warrantyInformation: current.warrantyInformation,
            updatedAt: current.updatedAt,
            isFavorite: newStatus,
          );
          
          products[index] = newProduct; 
        }
      },
    );
  }
}
