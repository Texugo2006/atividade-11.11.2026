// lib/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/local_provider.dart';
import '../../data/services/via_cep_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _petNameController = TextEditingController();
  final _petBreedController = TextEditingController();
  final _cepController = TextEditingController();
  final _addressController = TextEditingController();
  final _tokenController = TextEditingController();

  bool _loading = false;
  bool _searchingCep = false;

  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final local = Provider.of<LocalProvider>(context, listen: false);
    final profile = await local.getUserProfile();
    final token = await local.getToken();
    final apps = await local.getAppointments();

    if (profile != null) {
      _nameController.text = profile['name'] ?? '';
      _emailController.text = profile['email'] ?? '';
      _phoneController.text = profile['phone'] ?? '';
      _petNameController.text = profile['petName'] ?? '';
      _petBreedController.text = profile['petBreed'] ?? '';
      _addressController.text = profile['address'] ?? '';
      _cepController.text = profile['cep'] ?? '';
    }
    _tokenController.text = token ?? 'token_jwt_sec_892348a7b';
    _appointments = apps;
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _petNameController.dispose();
    _petBreedController.dispose();
    _cepController.dispose();
    _addressController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _consultarCep() async {
    final cep = _cepController.text.trim();
    if (cep.isEmpty) return;

    setState(() => _searchingCep = true);
    final viaCep = Provider.of<ViaCepService>(context, listen: false);
    final addr = await viaCep.getAddressByCep(cep);
    setState(() => _searchingCep = false);

    if (addr != null) {
      _addressController.text =
          '${addr.logradouro}, ${addr.bairro} - ${addr.localidade}/${addr.uf}';
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CEP não encontrado.')),
        );
      }
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final local = Provider.of<LocalProvider>(context, listen: false);

    await local.saveUserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      petName: _petNameController.text.trim(),
      petBreed: _petBreedController.text.trim(),
      address: _addressController.text.trim(),
      cep: _cepController.text.trim(),
    );

    await local.saveToken(_tokenController.text.trim());

    setState(() => _loading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil salvo com sucesso!'),
        ),
      );
    }
  }

  Future<void> _clear() async {
    final local = Provider.of<LocalProvider>(context, listen: false);
    await local.clearSession();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _petNameController.clear();
    _petBreedController.clear();
    _cepController.clear();
    _addressController.clear();
    _tokenController.clear();
    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão e dados locais apagados.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil & Pets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair da Conta',
            onPressed: _clear,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            const Text(
              'Dados do Tutor:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telefone / WhatsApp',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Dados do Pet Cadastrado:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _petNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Pet',
                      prefixIcon: Icon(Icons.pets),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _petBreedController,
                    decoration: const InputDecoration(
                      labelText: 'Raça / Espécie',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              'Endereço de Entrega:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cepController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'CEP',
                      prefixIcon: Icon(Icons.pin_drop),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchingCep ? null : _consultarCep,
                  child: _searchingCep
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Buscar CEP'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Endereço Completo',
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Token de Acesso:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Token de Sessão',
                prefixIcon: Icon(Icons.vpn_key),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text(
                      'Salvar Perfil',
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: _save,
                  ),

            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.event_note, color: Colors.teal),
                const SizedBox(width: 8),
                const Text(
                  'Meus Agendamentos:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_appointments.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_appointments.isEmpty)
              Card(
                color: Colors.grey.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Nenhum serviço agendado no momento.\nAgende banho, tosa ou consultas na aba de Serviços!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _appointments.length,
                itemBuilder: (ctx, i) {
                  final ag = _appointments[i];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Icon(Icons.pets, color: Colors.white, size: 20),
                      ),
                      title: Text(
                        ag['serviceName'] ?? 'Serviço',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        'Pet: ${ag['petName']} | Data: ${ag['date']} | R\$ ${(ag['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 22),
                        tooltip: 'Cancelar Agendamento',
                        onPressed: () async {
                          final local = Provider.of<LocalProvider>(context, listen: false);
                          await local.cancelAppointment(ag['id']);
                          await _loadProfile();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Agendamento cancelado com sucesso.')),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    ),
  ),
);
  }
}
