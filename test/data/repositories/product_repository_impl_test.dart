import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_product_app_assesment/core/constants/app_constants.dart';
import 'package:flutter_product_app_assesment/core/network/api_client.dart';
import 'package:flutter_product_app_assesment/core/network/network_info.dart';
import 'package:flutter_product_app_assesment/data/datasources/db_service.dart';
import 'package:flutter_product_app_assesment/data/models/product_model.dart';
import 'package:flutter_product_app_assesment/data/repositories/product_repository_impl.dart';
import 'package:sqflite/sqflite.dart';
import '../../helpers/test_helper.mocks.dart';

void main() {
  late ProductRepositoryImpl repository;
  late MockApiClient mockApiClient;
  late MockDbService mockDbService;
  late MockNetworkInfo mockNetworkInfo;
  late MockDatabase mockDatabase;
  late MockBatch mockBatch;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDbService = MockDbService();
    mockNetworkInfo = MockNetworkInfo();
    mockDatabase = MockDatabase();
    mockBatch = MockBatch();
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

  final tProductList = [tProductModel];

  group('getProducts', () {
    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockApiClient.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: ''),
              data: {'products': []},
              statusCode: 200));
       when(mockDbService.database).thenAnswer((_) async => mockDatabase);
       when(mockDatabase.batch()).thenReturn(mockBatch);
      
      // act
      await repository.getProducts(0, 10);
      
      // assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return remote data when call to remote datasource is successful',
          () async {
        // arrange
        when(mockApiClient.get(any, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: {
                  'products': [tProductModel.toJson()..remove('isFavorite')] // API response structure
                },
                statusCode: 200));
        
        when(mockDbService.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.batch()).thenReturn(mockBatch);
        
        // act
        final result = await repository.getProducts(0, 10);
        
        // assert
        verify(mockApiClient.get(AppConstants.productsEndpoint, queryParameters: {'skip': 0, 'limit': 10}));
        expect(result, isA<Right>());
      });
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return local data when device is offline', () async {
        // arrange
        when(mockDbService.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          AppConstants.tableNameProducts,
          limit: 10,
          offset: 0,
        )).thenAnswer((_) async {
             final map = tProductModel.toJson();
             map['images'] = '[]'; // DB stores images as string
             return [map];
        });
        
        // act
        final result = await repository.getProducts(0, 10);
         
        // assert
        verify(mockDatabase.query(AppConstants.tableNameProducts, limit: 10, offset: 0));
        // We need to match the return parsing.
        // ProductModel.fromLocalMap parses images from String json.
        // My tProductModel.toJson() for DB logic stores 'images' as '[]' (jsonEncoded) in my Impl.
        // So I should ensure mock returns map compatible with fromLocalMap.
        expect(result, isA<Right>());
      });
    });
  });
}
