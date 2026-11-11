// lib/domain/usecases/remove_from_cart.dart
import '../../data/providers/local_provider.dart';

class RemoveFromCart {
  final LocalProvider local;
  RemoveFromCart(this.local);

  Future<void> call(String productId) async {
    await local.removeFromCart(productId);
  }
}
