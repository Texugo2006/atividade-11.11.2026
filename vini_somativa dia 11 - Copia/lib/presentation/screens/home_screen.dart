// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/entities/product.dart';
import '../../data/models/service_model.dart';
import '../../data/models/promotion_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/dog_api_service.dart';
import '../../data/providers/local_provider.dart';
import '../widgets/product_card.dart';
import 'product_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  String _searchQuery = '';
  String _selectedCategory = 'Todas';
  int _cartCount = 0;

  // Cache e estado
  Future<List<Product>>? _productsFuture;
  Future<List<PetServiceModel>>? _servicesFuture;
  Future<List<PromotionModel>>? _promotionsFuture;
  DogInfo? _dogInfo;
  bool _loadingDog = false;
  String? get _dogImageUrl => _dogInfo?.imageUrl;

  @override
  void initState() {
    super.initState();
    _loadAll();
    _loadCartCount();
    _fetchRandomDog();
  }

  void _loadAll() {
    final getProducts = Provider.of<GetProducts>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    setState(() {
      _productsFuture = getProducts.call();
      _servicesFuture = apiService.fetchServices();
      _promotionsFuture = apiService.fetchPromotions();
    });
  }

  Future<void> _loadCartCount() async {
    final local = Provider.of<LocalProvider>(context, listen: false);
    final cart = await local.getCart();
    if (mounted) {
      setState(() => _cartCount = cart.length);
    }
  }

  Future<void> _fetchRandomDog() async {
    setState(() => _loadingDog = true);
    final dogApi = Provider.of<DogApiService>(context, listen: false);
    final info = await dogApi.getRandomDogInfo();
    if (mounted) {
      setState(() {
        _dogInfo = info;
        _loadingDog = false;
      });
    }
  }

  Future<void> _showAgendamentoDialog(PetServiceModel service) async {
    final local = Provider.of<LocalProvider>(context, listen: false);
    final profile = await local.getUserProfile();
    final defaultPetName = profile?['petName'] ?? 'Meu Pet';
    final petController = TextEditingController(text: defaultPetName.toString().isEmpty ? 'Meu Pet' : defaultPetName.toString());

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.teal),
            const SizedBox(width: 8),
            Expanded(child: Text('Agendar ${service.name}')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timer, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 6),
                Text('Duração: ${service.duration}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.monetization_on, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text('Valor: R\$ ${service.price.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: petController,
              decoration: const InputDecoration(
                labelText: 'Nome do Pet para o atendimento',
                isDense: true,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pets, size: 18),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'O agendamento será registrado e salvo no seu perfil.',
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newAppointment = {
                'id': 'ag_${DateTime.now().millisecondsSinceEpoch}',
                'serviceName': service.name,
                'price': service.price,
                'duration': service.duration,
                'petName': petController.text.trim().isEmpty ? 'Pet' : petController.text.trim(),
                'date': DateTime.now().add(const Duration(days: 1)).toString().split(' ')[0],
                'status': 'Confirmado',
              };
              await local.saveAppointment(newAppointment);

              if (ctx.mounted) Navigator.of(ctx).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Agendamento de "${service.name}" salvo no dispositivo! Veja em Perfil.'),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Confirmar Agendamento'),
          ),
        ],
      ),
    );
  }

  // ---------- ABA 1: Catálogo & Promoções ----------
  Widget _buildCatalogTab() {
    return Column(
      children: [
        // Banners de Promoções Ativas
        FutureBuilder<List<PromotionModel>>(
          future: _promotionsFuture,
          builder: (ctx, snap) {
            final promos = snap.data ?? [];
            if (promos.isEmpty) return const SizedBox.shrink();

            return Container(
              height: 105,
              margin: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: promos.length,
                itemBuilder: (ctx, i) {
                  final promo = promos[i];
                  return Container(
                    width: 280,
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade700, Colors.teal.shade400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_offer,
                                color: Colors.amberAccent, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                promo.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          promo.description,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Cupom: ${promo.coupon}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),

        // Barra de Busca e Filtro de Categoria
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar rações, brinquedos, marcas...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedCategory,
                items: ['Todas', 'Cães', 'Gatos']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val ?? 'Todas'),
              ),
            ],
          ),
        ),

        // Grid de Produtos Responsivo (com imagens menores e mais produtos visíveis)
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _loadAll();
              await _loadCartCount();
            },
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, size: 50, color: Colors.red),
                          const SizedBox(height: 8),
                          Text('Erro: ${snapshot.error}'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadAll,
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final all = snapshot.data ?? [];
                final filtered = all.where((p) {
                  final matchesSearch = p.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      p.id.toLowerCase().contains(_searchQuery.toLowerCase());

                  if (_selectedCategory == 'Todas') return matchesSearch;

                  String breed = '';
                  if (p is PetProduct) {
                    breed = p.breed.toLowerCase();
                  } else {
                    try {
                      breed = (p as dynamic).breed?.toString().toLowerCase() ?? '';
                    } catch (_) {}
                  }

                  final isDog = breed.contains('cão') ||
                      breed.contains('cães') ||
                      breed.contains('todas');
                  final isCat = breed.contains('gato');

                  if (_selectedCategory == 'Cães') return matchesSearch && isDog;
                  if (_selectedCategory == 'Gatos') return matchesSearch && isCat;
                  return matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('Nenhum produto encontrado.'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 210,
                    childAspectRatio: 0.76,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => ProductCard(
                    product: filtered[i],
                    onModified: () {
                      _loadAll();
                      _loadCartCount();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ---------- ABA 2: Serviços & Agendamento ----------
  Widget _buildServicesTab() {
    return FutureBuilder<List<PetServiceModel>>(
      future: _servicesFuture,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final services = snapshot.data ?? [];
        if (services.isEmpty) {
          return const Center(child: Text('Nenhum serviço disponível no momento.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: services.length,
          itemBuilder: (ctx, i) {
            final s = services[i];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            s.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'R\$ ${s.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.description,
                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 16, color: Colors.blueGrey),
                        const SizedBox(width: 4),
                        Text('Duração: ${s.duration}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.blueGrey)),
                        const Spacer(),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: const Text('Agendar'),
                          onPressed: () => _showAgendamentoDialog(s),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------- ABA 3: Curiosidades Pet (Dog API Externa - Imagem Menor) ----------
  Widget _buildDogApiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),

          // Imagem menor e centrada (170x220)
          Container(
            height: 170,
            width: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.grey.shade100,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _loadingDog
                  ? const Center(child: CircularProgressIndicator())
                  : _dogImageUrl != null
                      ? Image.network(
                          _dogImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.pets, size: 40, color: Colors.grey),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.pets, size: 40, color: Colors.grey),
                        ),
            ),
          ),

          // Raça do cachorro destacada logo abaixo da imagem
          if (_dogInfo != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.teal.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pets, size: 18, color: Colors.teal),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Raça: ${_dogInfo!.breedDisplayName}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Sortear Outro Cachorro'),
            onPressed: _loadingDog ? null : _fetchRandomDog,
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _dogInfo != null
                  ? 'Dicas Rápidas do Especialista para ${_dogInfo!.breedDisplayName}:'
                  : 'Dicas Rápidas do Especialista Digital Horizon:',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          if (_dogInfo != null && _dogInfo!.tips.isNotEmpty)
            ..._dogInfo!.tips.map((tip) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: tip.color.withValues(alpha: 0.15),
                      child: Icon(tip.icon, color: tip.color, size: 20),
                    ),
                    title: Text(
                      tip.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(
                      tip.description,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ))
          else ...[
            const Card(
              child: ListTile(
                leading: Icon(Icons.water_drop, color: Colors.blue),
                title: Text('Hidratação Constante'),
                subtitle: Text(
                    'Troque a água do seu pet pelo menos 2 vezes ao dia para mantê-la sempre fresca.'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.brush, color: Colors.purple),
                title: Text('Escovação de Pelos'),
                subtitle: Text(
                    'Escovar os pelos semanalmente previne nós e reduz a formação de bolas de pelo em gatos.'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.medical_services, color: Colors.red),
                title: Text('Vacinas em Dia'),
                subtitle: Text(
                    'Mantenha as vacinas V10 e Antirrábica anuais para garantir a imunidade do seu melhor amigo.'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------- ABA 4: Sobre o Estabelecimento Local ----------
  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.store, color: Colors.teal, size: 30),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pet Shop Patas & Pelos',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Campanha Digital Horizon - Comércio Local',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.location_on, color: Colors.teal),
                    title: Text('Endereço'),
                    subtitle: Text('Rua das Flores, 450 - Centro'),
                  ),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.access_time, color: Colors.teal),
                    title: Text('Horário de Atendimento'),
                    subtitle: Text('Segunda a Sábado: 08:00 às 19:00'),
                  ),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.phone, color: Colors.teal),
                    title: Text('Contato / WhatsApp'),
                    subtitle: Text('(11) 98765-4321'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.teal.shade700,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.person),
            label: const Text('Acessar Meu Perfil & Pets'),
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Shop - Digital Horizon'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Meu Perfil',
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                tooltip: 'Carrinho',
                onPressed: () async {
                  await Navigator.pushNamed(context, '/cart');
                  _loadCartCount();
                },
              ),
              if (_cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$_cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildCatalogTab(),
          _buildServicesTab(),
          _buildDogApiTab(),
          _buildAboutTab(),
        ],
      ),
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Novo Produto'),
              onPressed: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductFormScreen()),
                );
                if (created == true) {
                  _loadAll();
                }
              },
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (i) {
          setState(() => _currentTab = i);
          _loadCartCount();
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.content_cut),
            label: 'Serviços',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Dicas Pet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Sobre',
          ),
        ],
      ),
    );
  }
}
