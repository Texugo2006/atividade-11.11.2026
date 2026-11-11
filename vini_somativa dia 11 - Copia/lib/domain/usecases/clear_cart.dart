// lib/domain/usecases/clear_cart.dart
import '../../data/providers/local_provider.dart';

class ClearCart {
  final LocalProvider local;
  ClearCart(this.local);

  Future<void> call() async {
    await local.clearCart();
  }
}
