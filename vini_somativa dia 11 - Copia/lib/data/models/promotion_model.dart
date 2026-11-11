// lib/data/models/promotion_model.dart
class PromotionModel {
  final String id;
  final String title;
  final String description;
  final String coupon;

  PromotionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.coupon,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) => PromotionModel(
        id: json['id']?.toString() ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        coupon: json['coupon'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'coupon': coupon,
      };
}
