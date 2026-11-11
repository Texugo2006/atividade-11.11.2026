// lib/data/providers/local_provider.dart
import 'package:hive_flutter/hive_flutter.dart';

class LocalProvider {
  static const _boxName = 'petshop_local';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);

  // ---------- Dados Sensíveis: Autenticação e Token ----------
  Future<void> saveToken(String token) async =>
      await _box.put('auth_token', token);

  Future<String?> getToken() async =>
      await _box.get('auth_token') as String?;

  // ---------- Dados Sensíveis: Perfil do Tutor e Pet (Armazenamento Local) ----------
  Future<void> saveUserProfile({
    required String name,
    required String email,
    required String phone,
    required String petName,
    required String petBreed,
    String? address,
    String? cep,
  }) async {
    final profile = {
      'name': name,
      'email': email,
      'phone': phone,
      'petName': petName,
      'petBreed': petBreed,
      'address': address ?? '',
      'cep': cep ?? '',
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _box.put('user_profile', profile);
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final raw = _box.get('user_profile');
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw as Map);
  }

  Future<void> clearSession() async {
    await _box.delete('auth_token');
    await _box.delete('user_profile');
  }

  // ---------- Carrinho de Compras Local ----------
  Future<void> saveCart(List<String> productIds) async =>
      await _box.put('cart', productIds);

  Future<List<String>> getCart() async {
    final list = _box.get('cart', defaultValue: <String>[]);
    return List<String>.from(list as List);
  }

  Future<void> addToCart(String productId) async {
    final current = await getCart();
    current.add(productId);
    await saveCart(current);
  }

  Future<void> removeFromCart(String productId) async {
    final current = await getCart();
    current.remove(productId);
    await saveCart(current);
  }

  Future<void> clearCart() async {
    await _box.delete('cart');
  }

  // ---------- Agendamentos de Serviços Locais (Hive) ----------
  Future<List<Map<String, dynamic>>> getAppointments() async {
    final list = _box.get('appointments', defaultValue: <dynamic>[]);
    return (list as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> saveAppointment(Map<String, dynamic> appointment) async {
    final list = await getAppointments();
    list.add(appointment);
    await _box.put('appointments', list);
  }

  Future<void> cancelAppointment(String id) async {
    final list = await getAppointments();
    list.removeWhere((item) => item['id'] == id);
    await _box.put('appointments', list);
  }
}
