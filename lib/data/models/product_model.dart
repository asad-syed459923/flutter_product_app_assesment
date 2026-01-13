import 'dart:convert';
import 'package:hive/hive.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class ProductModel extends Product {
  @override
  @HiveField(0)
  final int id;
  @override
  @HiveField(1)
  final String title;
  @override
  @HiveField(2)
  final String description;
  @override
  @HiveField(3)
  final String category;
  @override
  @HiveField(4)
  final double price;
  @override
  @HiveField(5)
  final double discountPercentage;
  @override
  @HiveField(6)
  final double rating;
  @override
  @HiveField(7)
  final int stock;
  @override
  @HiveField(8)
  final String brand;
  @override
  @HiveField(9)
  final String thumbnail;
  @override
  @HiveField(10)
  final List<String> images;
  @override
  @HiveField(11)
  final String availabilityStatus;
  @override
  @HiveField(12)
  final String warrantyInformation;
  @override
  @HiveField(13)
  final String updatedAt;
  @override
  @HiveField(14)
  final bool isFavorite;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.thumbnail,
    required this.images,
    required this.availabilityStatus,
    required this.warrantyInformation,
    required this.updatedAt,
    this.isFavorite = false,
  }) : super(
         id: id,
         title: title,
         description: description,
         category: category,
         price: price,
         discountPercentage: discountPercentage,
         rating: rating,
         stock: stock,
         brand: brand,
         thumbnail: thumbnail,
         images: images,
         availabilityStatus: availabilityStatus,
         warrantyInformation: warrantyInformation,
         updatedAt: updatedAt,
         isFavorite: isFavorite,
       );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Name',
      description: json['description'] ?? 'No Description',
      category: json['category'] ?? 'Uncategorized',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] ?? 0,
      brand: json['brand'] ?? 'Unknown Brand',
      thumbnail: json['thumbnail'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      availabilityStatus: json['availabilityStatus'] ?? 'Unknown',
      warrantyInformation: json['warrantyInformation'] ?? 'No Warranty Info',
      updatedAt: json['meta']?['updatedAt'] ?? DateTime.now().toIso8601String(),
      isFavorite: json['isFavorite'] ?? false,
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
      'images': images,
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
      images:
          map['images'] != null
              ? (jsonDecode(map['images']) as List).cast<String>()
              : [],
      availabilityStatus: map['availabilityStatus'] ?? 'Unknown',
      warrantyInformation: map['warrantyInformation'] ?? 'No Warranty Info',
      updatedAt: map['updatedAt'] ?? '',
      isFavorite: (map['isFavorite'] == 1),
    );
  }
}
