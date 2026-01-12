import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_product_app_assesment/domain/entities/product.dart';
import 'package:flutter_product_app_assesment/domain/usecases/get_products.dart';
import '../../helpers/test_helper.mocks.dart';

void main() {
  late GetProductsUseCase useCase;
  late MockProductRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockProductRepository();
    useCase = GetProductsUseCase(mockProductRepository);
  });

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
    thumbnail: 'url',
    images: [],
    availabilityStatus: 'In Stock',
    warrantyInformation: '1 Year',
    updatedAt: '2023-01-01',
  );

  test('should get list of products from repository', () async {
    // arrange
    when(mockProductRepository.getProducts(any, any))
        .thenAnswer((_) async => const Right([tProduct]));
    
    // act
    final result = await useCase(GetProductsParams(skip: 0, limit: 10));
    
    // assert
    expect(result, const Right([tProduct]));
    verify(mockProductRepository.getProducts(0, 10));
    verifyNoMoreInteractions(mockProductRepository);
  });
}
