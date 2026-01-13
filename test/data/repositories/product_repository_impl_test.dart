import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_product_app_assesment/core/constants/app_constants.dart';
import 'package:flutter_product_app_assesment/data/models/product_model.dart';
import 'package:flutter_product_app_assesment/data/repositories/product_repository_impl.dart';

import '../../helpers/test_helper.mocks.dart';

void main() {
  late ProductRepositoryImpl repository;
  late MockApiClient mockApiClient;
  late MockDbService mockDbService;
  late MockNetworkInfo mockNetworkInfo;
  late MockBox<ProductModel> mockProductsBox;
  late MockBox<ProductModel> mockFavoritesBox;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDbService = MockDbService();
    mockNetworkInfo = MockNetworkInfo();
    mockProductsBox = MockBox<ProductModel>();
    mockFavoritesBox = MockBox<ProductModel>();

    // Stub DbService getters
    when(mockDbService.productsBox).thenReturn(mockProductsBox);
    when(mockDbService.favoritesBox).thenReturn(mockFavoritesBox);

    repository = ProductRepositoryImpl(
      apiClient: mockApiClient,
      dbService: mockDbService,
      networkInfo: mockNetworkInfo,
    );
  });

  const tProductModel = ProductModel(
    id: 1,
    title: 'Test Product',
    description: 'Desc',
    category: 'Cat',
    price: 100,
    discountPercentage: 10,
    rating: 4.5,
    stock: 10,
    brand: 'Brand',
    thumbnail: 'url',
    images: [],
    availabilityStatus: 'In Stock',
    warrantyInformation: '1 Year',
    updatedAt: '2023-01-01',
  );

  group('getProducts', () {
    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        mockApiClient.get(any, queryParameters: anyNamed('queryParameters')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'products': []},
          statusCode: 200,
        ),
      );
      when(mockFavoritesBox.containsKey(any)).thenReturn(false);
      when(mockProductsBox.put(any, any)).thenAnswer((_) async => {});

      // act
      await repository.getProducts(0, 10);

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
        'should return remote data, merge favorites, and cache data',
        () async {
          // arrange
          when(
            mockApiClient.get(
              any,
              queryParameters: anyNamed('queryParameters'),
            ),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: {
                'products': [
                  tProductModel.toJson(), // API response
                ],
              },
              statusCode: 200,
            ),
          );

          when(mockFavoritesBox.containsKey(tProductModel.id)).thenReturn(true);
          when(mockProductsBox.put(any, any)).thenAnswer((_) async => {});

          // act
          final result = await repository.getProducts(0, 10);

          // assert
          verify(
            mockApiClient.get(
              AppConstants.productsEndpoint,
              queryParameters: {'skip': 0, 'limit': 10},
            ),
          );
          verify(
            mockFavoritesBox.containsKey(tProductModel.id),
          ); // Merged favorite status
          verify(mockProductsBox.put(tProductModel.id, any)); // Cached

          expect(result, isA<Right>());
          result.fold((l) => null, (r) {
            expect(r.length, 1);
            expect(
              r.first.isFavorite,
              true,
            ); // Should be true due to mockFavoritesBox
          });
        },
      );
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return local data from Hive', () async {
        // arrange
        when(mockProductsBox.values).thenReturn([tProductModel]);
        when(mockFavoritesBox.containsKey(any)).thenReturn(false);

        // act
        final result = await repository.getProducts(0, 10);

        // assert
        verify(mockProductsBox.values);
        expect(result, isA<Right>());
        result.fold((l) => null, (r) {
          expect(r.length, 1);
          expect(r.first.id, tProductModel.id);
        });
      });

      test('should return empty list if skip is out of bounds', () async {
        // arrange
        when(mockProductsBox.values).thenReturn([tProductModel]);

        // act
        final result = await repository.getProducts(10, 10);

        // assert
        expect(result, isA<Right>());
        result.fold((l) => null, (r) => expect(r.isEmpty, true));
      });
    });
  });
}
