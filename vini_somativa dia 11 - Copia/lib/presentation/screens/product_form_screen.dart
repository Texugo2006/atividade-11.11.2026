// lib/presentation/screens/product_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product.dart';
import '../../data/models/product_model.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/update_product.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product; // Se nulo, é criação (POST); se preenchido, é edição (PUT)

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  late TextEditingController _breedController;
  late TextEditingController _brandController;
  bool _loading = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    final pet = p is ProductModel ? p : null;

    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController =
        TextEditingController(text: p != null ? p.price.toStringAsFixed(2) : '');
    _imageController = TextEditingController(
      text: p?.imageUrl ??
          'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=500',
    );
    _breedController = TextEditingController(text: pet?.breed ?? 'Todas');
    _brandController = TextEditingController(text: pet?.brand ?? 'Royal Canin');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _breedController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final name = _nameController.text.trim();
      final price = double.parse(_priceController.text.replaceAll(',', '.'));
      final imageUrl = _imageController.text.trim();
      final breed = _breedController.text.trim();
      final brand = _brandController.text.trim();

      if (isEditing) {
        // Atualização via RESTful (PUT)
        final updateProduct =
            Provider.of<UpdateProduct>(context, listen: false);
        final updated = ProductModel(
          id: widget.product!.id,
          name: name,
          price: price,
          imageUrl: imageUrl,
          breed: breed,
          brand: brand,
        );
        await updateProduct.call(updated);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto atualizado com sucesso!')),
        );
      } else {
        // Criação via RESTful (POST)
        final createProduct =
            Provider.of<CreateProduct>(context, listen: false);
        final newId = 'p_${DateTime.now().millisecondsSinceEpoch}';
        final newProd = ProductModel(
          id: newId,
          name: name,
          price: price,
          imageUrl: imageUrl,
          breed: breed,
          brand: brand,
        );
        await createProduct.call(newProd);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Novo produto cadastrado com sucesso!')),
        );
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar produto: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Produto' : 'Cadastrar Novo Produto'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome do produto' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Preço (R\$) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o preço';
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) return 'Preço inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Marca',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _breedController,
                      decoration: const InputDecoration(
                        labelText: 'Raça / Categoria',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pets),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'URL da Imagem *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe a URL da imagem' : null,
              ),
              const SizedBox(height: 24),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: Icon(isEditing ? Icons.save : Icons.add_circle),
                      label: Text(
                        isEditing ? 'Salvar Alterações' : 'Cadastrar Produto',
                        style: const TextStyle(fontSize: 16),
                      ),
                      onPressed: _save,
                    ),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }
}
