// lib/presentation/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/local_provider.dart';
import '../../data/models/product_model.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/via_cep_service.dart';
import '../../domain/usecases/remove_from_cart.dart';
import '../../domain/usecases/clear_cart.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cepController = TextEditingController();
  ViaCepAddress? _address;
  bool _searchingCep = false;
  double _shippingFee = 0.0;
  bool _shippingCalculated = false;

  @override
  void dispose() {
    _cepController.dispose();
    super.dispose();
  }

  Future<void> _consultarCep(ViaCepService viaCep) async {
    final cep = _cepController.text.trim();
    if (cep.isEmpty) return;

    setState(() => _searchingCep = true);
    final result = await viaCep.getAddressByCep(cep);
    setState(() {
      _searchingCep = false;
      _address = result;
      if (result != null) {
        _shippingCalculated = true;
        // Simulação de frete para estabelecimento local
        _shippingFee = 12.00;
      }
    });

    if (result == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CEP não encontrado ou inválido.')),
      );
    }
  }

  void _finalizarPedido(ClearCart clearCart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Pedido Confirmado!'),
          ],
        ),
        content: Text(
          _address != null
              ? 'Seu pedido no Pet Shop Digital Horizon foi registrado com sucesso!\n\nEntrega para:\n${_address!.logradouro}, ${_address!.bairro} - ${_address!.localidade}/${_address!.uf}\n\nObrigado por apoiar o comércio local!'
              : 'Seu pedido foi registrado com sucesso!\nObrigado por apoiar o comércio local.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await clearCart.call();
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (mounted) setState(() {});
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = Provider.of<LocalProvider>(context, listen: false);
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    final viaCep = Provider.of<ViaCepService>(context, listen: false);
    final removeFromCart = Provider.of<RemoveFromCart>(context, listen: false);
    final clearCart = Provider.of<ClearCart>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho de Compras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Esvaziar Carrinho',
            onPressed: () async {
              await clearCart.call();
              setState(() {});
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: FutureBuilder<List<String>>(
            future: local.getCart(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final ids = snapshot.data ?? [];
          if (ids.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_shopping_cart, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Seu carrinho está vazio',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder<List<ProductModel>>(
            future: apiProvider.api.fetchProducts(),
            builder: (c, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final allProducts = snap.data ?? [];
              final Map<String, ProductModel> map = {
                for (var p in allProducts) p.id: p
              };

              // Itens no carrinho
              final cartItems = ids
                  .where((id) => map.containsKey(id))
                  .map((id) => map[id]!)
                  .toList();

              final subtotal =
                  cartItems.fold<double>(0.0, (acc, item) => acc + item.price);
              final total = subtotal + (_shippingCalculated ? _shippingFee : 0.0);

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: cartItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final p = cartItems[i];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              p.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.pets, size: 24, color: Colors.grey),
                              ),
                            ),
                          ),
                          title: Text(p.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('R\$ ${p.price.toStringAsFixed(2)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            tooltip: 'Remover',
                            onPressed: () async {
                              await removeFromCart.call(p.id);
                              setState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // Seção de Cálculo de Frete via API Pública ViaCEP
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.local_shipping, size: 18, color: Colors.teal),
                              SizedBox(width: 8),
                              Text(
                                'Calcular Frete e Entrega:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _cepController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Digite o CEP (Ex: 01001000)',
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _searchingCep
                                    ? null
                                    : () => _consultarCep(viaCep),
                                child: _searchingCep
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Consultar'),
                              ),
                            ],
                          ),
                          if (_address != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.teal),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${_address!.logradouro}, ${_address!.bairro} - ${_address!.localidade}/${_address!.uf}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.blueGrey),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Frete Local Estimado: R\$ ${_shippingFee.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Resumo do Pedido e Botão de Finalizar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:',
                                  style: TextStyle(fontSize: 15)),
                              Text('R\$ ${subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                          if (_shippingCalculated)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Frete:',
                                    style: TextStyle(fontSize: 15)),
                                Text('R\$ ${_shippingFee.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 15)),
                              ],
                            ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'R\$ ${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text(
                                'Finalizar Compra Local',
                                style: TextStyle(fontSize: 16),
                              ),
                              onPressed: () => _finalizarPedido(clearCart),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    ),
  ),
);
  }
}
