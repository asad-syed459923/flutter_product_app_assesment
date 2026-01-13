import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:flutter_product_app_assesment/domain/entities/product.dart';
import 'package:flutter_product_app_assesment/presentation/widgets/product_card.dart';

void main() {
  const tProduct = Product(
    id: 1,
    title: 'Test Product',
    description: 'Desc',
    category: 'Cat',
    price: 100,
    discountPercentage: 10,
    rating: 4.5,
    stock: 10,
    brand: 'Brand',
    thumbnail: 'http://example.com/image.png',
    images: [],
    availabilityStatus: 'In Stock',
    warrantyInformation: '1 Year',
    updatedAt: '2023-01-01',
    isFavorite: false,
  );

  testWidgets('ProductCard displays correct information', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: tProduct,
              onTap: () {},
              onFavoriteToggle: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('Brand: Brand - Category: Cat'), findsOneWidget); 
      expect(find.text('\$100.0'), findsOneWidget); // crossed out price
      expect(find.text('\$90.00'), findsOneWidget); // discounted price
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('In Stock'), findsOneWidget);
      expect(find.text('1 Year'), findsOneWidget);
      expect(find.text('Updated: 2023-01-01'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });
  });

  testWidgets('ProductCard calls callbacks', (WidgetTester tester) async {
    bool tapped = false;
    bool favorited = false;

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: tProduct,
              onTap: () => tapped = true,
              onFavoriteToggle: () => favorited = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      expect(tapped, true);

      await tester.tap(find.byIcon(Icons.favorite_border));
      expect(favorited, true);
    });
  });
}
