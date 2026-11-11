// lib/data/models/service_model.dart
class PetServiceModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String duration;

  PetServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.duration,
  });

  factory PetServiceModel.fromJson(Map<String, dynamic> json) => PetServiceModel(
        id: json['id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        description: json['description'] as String? ?? '',
        duration: json['duration'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'duration': duration,
      };
}
