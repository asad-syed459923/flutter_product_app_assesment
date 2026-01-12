class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String brand;
  final String thumbnail;
  final List<String> images;
  final String availabilityStatus;
  final String warrantyInformation;
  final String updatedAt;
  final bool isFavorite;

  const Product({
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
  });
  
  double get discountedPrice => price * (1 - discountPercentage / 100);
}
