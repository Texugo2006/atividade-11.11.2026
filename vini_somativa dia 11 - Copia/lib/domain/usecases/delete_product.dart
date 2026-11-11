// lib/domain/usecases/delete_product.dart
import '../repositories/product_repository.dart';

class DeleteProduct {
  final ProductRepository repository;
  DeleteProduct(this.repository);

  Future<void> call(String id) async {
    await repository.delete(id);
  }
}
