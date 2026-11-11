// test/product_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:petshop_app/data/models/product_model.dart';
import 'package:petshop_app/domain/entities/product.dart';

void main() {
  group('ProductModel & POO Entities Tests', () {
    final mockJson = {
      'id': 'p100',
      'name': 'Ração Teste Premium',
      'price': 120.50,
      'imageUrl': 'https://images.unsplash.com/test.jpg',
      'breed': 'Cães Adultos',
      'brand': 'Royal Canin',
    };

    test('Deve desserializar ProductModel a partir de um JSON válido', () {
      final model = ProductModel.fromJson(mockJson);

      expect(model.id, equals('p100'));
      expect(model.name, equals('Ração Teste Premium'));
      expect(model.price, equals(120.50));
      expect(model.imageUrl, equals('https://images.unsplash.com/test.jpg'));
      expect(model.breed, equals('Cães Adultos'));
      expect(model.brand, equals('Royal Canin'));
    });

    test('Deve serializar ProductModel para JSON corretamente', () {
      final model = ProductModel(
        id: 'p101',
        name: 'Brinquedo Gato',
        price: 35.0,
        imageUrl: 'https://images.unsplash.com/cat.jpg',
        breed: 'Gatos',
        brand: 'PetFun',
      );

      final json = model.toJson();

      expect(json['id'], equals('p101'));
      expect(json['name'], equals('Brinquedo Gato'));
      expect(json['price'], equals(35.0));
      expect(json['breed'], equals('Gatos'));
      expect(json['brand'], equals('PetFun'));
    });

    test('Deve comprovar polimorfismo sendo subclasse de Product', () {
      final model = ProductModel.fromJson(mockJson);

      // Verificação de herança e polimorfismo Dart
      expect(model, isA<Product>());
      expect(model.id, isNotEmpty);
      expect(model.price, isPositive);
    });

    test('Deve lidar com campos nulos e converter tipos defensivamente', () {
      final jsonIncompleto = {
        'id': 'p102',
        'name': 'Item Básico',
        'price': 50, // int em vez de double
      };

      final model = ProductModel.fromJson(jsonIncompleto);

      expect(model.id, equals('p102'));
      expect(model.name, equals('Item Básico'));
      expect(model.price, equals(50.0));
      expect(model.breed, equals('Todas')); // valor padrão defensivo
      expect(model.brand, equals('Geral')); // valor padrão defensivo
    });
  });
}
