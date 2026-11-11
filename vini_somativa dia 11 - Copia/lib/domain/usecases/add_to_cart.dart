// lib/domain/usecases/add_to_cart.dart
import '../../data/providers/local_provider.dart';

class AddToCart {
  final LocalProvider local;

  AddToCart(this.local);

  Future<void> call(String productId) async {
    final current = await local.getCart();
    final updated = List<String>.from(current)..add(productId);
    await local.saveCart(updated);
  }
}
