// lib/data/models/product_model.dart
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  final String breed;
  final String brand;

  ProductModel({
    required String id,
    required String name,
    required double price,
    required String imageUrl,
    required this.breed,
    required this.brand,
  }) : super(id: id, name: name, price: price, imageUrl: imageUrl);

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: json['imageUrl'] as String? ?? '',
        breed: json['breed'] as String? ?? 'Todas',
        brand: json['brand'] as String? ?? 'Geral',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'breed': breed,
        'brand': brand,
      };
}
