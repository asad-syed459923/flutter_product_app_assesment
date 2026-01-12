import 'dart:convert';
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.price,
    required super.discountPercentage,
    required super.rating,
    required super.stock,
    required super.brand,
    required super.thumbnail,
    required super.images,
    required super.availabilityStatus,
    required super.warrantyInformation,
    required super.updatedAt,
    super.isFavorite,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Name',
      description: json['description'] ?? 'No Description',
      category: json['category'] ?? 'Uncategorized',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] ?? 0,
      brand: json['brand'] ?? 'Unknown Brand',
      thumbnail: json['thumbnail'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      availabilityStatus: json['availabilityStatus'] ?? 'Unknown',
      warrantyInformation: json['warrantyInformation'] ?? 'No Warranty Info',
      updatedAt: json['meta']?['updatedAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'thumbnail': thumbnail,
      'images': jsonEncode(images), // Storing list as string for SQLite
      'availabilityStatus': availabilityStatus,
      'warrantyInformation': warrantyInformation,
      'updatedAt': updatedAt,
    };
  }

  factory ProductModel.fromLocalMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      price: map['price'],
      discountPercentage: map['discountPercentage'],
      rating: map['rating'],
      stock: map['stock'],
      brand: map['brand'],
      thumbnail: map['thumbnail'],
      images: map['images'] != null ? (jsonDecode(map['images']) as List).cast<String>() : [],
      availabilityStatus: map['availabilityStatus'] ?? 'Unknown',
      warrantyInformation: map['warrantyInformation'] ?? 'No Warranty Info',
      updatedAt: map['updatedAt'] ?? '',
      isFavorite: (map['isFavorite'] == 1),
    );
  }
}
