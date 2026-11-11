// lib/domain/usecases/update_product.dart
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class UpdateProduct {
  final ProductRepository repository;
  UpdateProduct(this.repository);

  Future<Product> call(Product product) async {
    return await repository.update(product);
  }
}
