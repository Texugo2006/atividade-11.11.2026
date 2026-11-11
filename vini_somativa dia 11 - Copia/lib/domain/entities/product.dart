// lib/domain/entities/product.dart
abstract class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}

// Produto específico para pet shop (ex.: raça e marca)
class PetProduct extends Product {
  final String breed;
  final String brand;

  PetProduct({
    required String id,
    required String name,
    required double price,
    required String imageUrl,
    required this.breed,
    required this.brand,
  }) : super(id: id, name: name, price: price, imageUrl: imageUrl);
}
