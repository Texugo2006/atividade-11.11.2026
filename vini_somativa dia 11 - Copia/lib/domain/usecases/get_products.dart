// lib/domain/usecases/get_products.dart
import '../repositories/product_repository.dart';
import '../entities/product.dart';

class GetProducts {
  final ProductRepository repository;

  GetProducts(this.repository);

  Future<List<Product>> call() async => await repository.getAll();
}
