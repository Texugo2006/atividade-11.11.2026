// lib/data/providers/api_provider.dart
import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/product.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';

class ApiProvider implements ProductRepository {
  final ApiService api;

  ApiProvider(this.api);

  @override
  Future<List<Product>> getAll() async {
    return await api.fetchProducts();
  }

  @override
  Future<Product> create(Product product) async {
    final model = product is ProductModel
        ? product
        : ProductModel(
            id: product.id,
            name: product.name,
            price: product.price,
            imageUrl: product.imageUrl,
            breed: (product is PetProduct) ? product.breed : 'Todas',
            brand: (product is PetProduct) ? product.brand : 'Geral',
          );
    return await api.createProduct(model);
  }

  @override
  Future<Product> update(Product product) async {
    final model = product is ProductModel
        ? product
        : ProductModel(
            id: product.id,
            name: product.name,
            price: product.price,
            imageUrl: product.imageUrl,
            breed: (product is PetProduct) ? product.breed : 'Todas',
            brand: (product is PetProduct) ? product.brand : 'Geral',
          );
    return await api.updateProduct(model);
  }

  @override
  Future<void> delete(String id) async {
    await api.deleteProduct(id);
  }
}
