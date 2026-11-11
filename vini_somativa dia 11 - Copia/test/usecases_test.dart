// test/usecases_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:petshop_app/domain/entities/product.dart';
import 'package:petshop_app/domain/repositories/product_repository.dart';
import 'package:petshop_app/domain/usecases/get_products.dart';
import 'package:petshop_app/domain/usecases/create_product.dart';
import 'package:petshop_app/domain/usecases/update_product.dart';
import 'package:petshop_app/domain/usecases/delete_product.dart';

// Mock do repositório em memória para testes unitários isolados
class MockProductRepository implements ProductRepository {
  final List<Product> _items = [];

  MockProductRepository([List<Product>? initial]) {
    if (initial != null) _items.addAll(initial);
  }

  @override
  Future<List<Product>> getAll() async => List.unmodifiable(_items);

  @override
  Future<Product> create(Product product) async {
    _items.add(product);
    return product;
  }

  @override
  Future<Product> update(Product product) async {
    final index = _items.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _items[index] = product;
    }
    return product;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((p) => p.id == id);
  }
}

void main() {
  group('Clean Architecture Use Cases Tests', () {
    late MockProductRepository mockRepo;
    late PetProduct sampleProduct;

    setUp(() {
      sampleProduct = PetProduct(
        id: 'p1',
        name: 'Ração Cães Adultos',
        price: 139.90,
        imageUrl: 'https://images.unsplash.com/test.jpg',
        breed: 'Cães',
        brand: 'Royal Canin',
      );
      mockRepo = MockProductRepository([sampleProduct]);
    });

    test('GetProducts deve retornar a lista de produtos do repositório', () async {
      final usecase = GetProducts(mockRepo);
      final result = await usecase.call();

      expect(result.length, equals(1));
      expect(result.first.id, equals('p1'));
      expect(result.first.name, equals('Ração Cães Adultos'));
    });

    test('CreateProduct deve adicionar um novo produto com sucesso', () async {
      final usecase = CreateProduct(mockRepo);
      final newProd = PetProduct(
        id: 'p2',
        name: 'Petisco Dental',
        price: 12.50,
        imageUrl: 'https://images.unsplash.com/petisco.jpg',
        breed: 'Cães',
        brand: 'Pedigree',
      );

      final created = await usecase.call(newProd);
      final all = await mockRepo.getAll();

      expect(created.id, equals('p2'));
      expect(all.length, equals(2));
      expect(all.last.name, equals('Petisco Dental'));
    });

    test('UpdateProduct deve atualizar dados do produto existente', () async {
      final usecase = UpdateProduct(mockRepo);
      final updatedProd = PetProduct(
        id: 'p1',
        name: 'Ração Cães Adultos - Atualizada',
        price: 145.00,
        imageUrl: 'https://images.unsplash.com/test.jpg',
        breed: 'Cães',
        brand: 'Royal Canin',
      );

      await usecase.call(updatedProd);
      final all = await mockRepo.getAll();

      expect(all.first.name, equals('Ração Cães Adultos - Atualizada'));
      expect(all.first.price, equals(145.00));
    });

    test('DeleteProduct deve remover o produto do repositório por id', () async {
      final usecase = DeleteProduct(mockRepo);

      await usecase.call('p1');
      final all = await mockRepo.getAll();

      expect(all.isEmpty, isTrue);
    });
  });
}
