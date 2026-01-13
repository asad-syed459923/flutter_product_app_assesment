import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:flutter_product_app_assesment/main.dart';
import 'package:flutter_product_app_assesment/presentation/pages/product_list_screen.dart';
import 'package:flutter_product_app_assesment/domain/entities/product.dart';
import 'package:flutter_product_app_assesment/presentation/controllers/product_controller.dart';
import 'helpers/test_helper.mocks.dart';

void main() {
  late MockProductController mockController;

  setUp(() {
    Get.reset();
    mockController = MockProductController();

    // Stubbing Rx variables to return real Rx objects so Obx works
    when(mockController.products).thenReturn(<Product>[].obs);
    when(mockController.isLoading).thenReturn(false.obs);
    when(mockController.isMoreLoading).thenReturn(false.obs);
    when(mockController.errorMessage).thenReturn(''.obs);
    when(mockController.isSearching).thenReturn(false.obs);

    // Stubbing Getter usage for Controllers
    when(mockController.searchController).thenReturn(TextEditingController());
    when(mockController.scrollController).thenReturn(ScrollController());

    // Stubbing GetX Lifecycle
    final callback = InternalFinalCallback<void>(callback: () {});
    when(mockController.onStart).thenReturn(callback);
    when(mockController.onDelete).thenReturn(callback);

    // Stubbing Methods usually returns Future<void> or void
    when(
      mockController.fetchProducts(isRefresh: anyNamed('isRefresh')),
    ).thenAnswer((_) async {});
    when(mockController.onSearchChanged(any)).thenReturn(null);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets(
    'ProductListScreen loads and shows title and no products message',
    (WidgetTester tester) async {
      // Inject mock controller
      Get.put<ProductController>(mockController);

      await mockNetworkImagesFor(() async {
        // Pump MyApp
        await tester.pumpWidget(const ProductAssessment());
        await tester.pumpAndSettle();
      });

      // Verify
      expect(find.byType(ProductListScreen), findsOneWidget);
      expect(find.text('Product Store'), findsOneWidget);
      expect(find.text('No products found.'), findsOneWidget);
    },
  );
}
