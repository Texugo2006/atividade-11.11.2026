// lib/data/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/service_model.dart';
import '../models/promotion_model.dart';

class ApiService {
  final String baseUrl;
  final http.Client client;

  ApiService({required this.baseUrl, http.Client? client})
      : client = client ?? http.Client();

  // GET all products (Informações públicas)
  Future<List<ProductModel>> fetchProducts() async {
    final response = await client.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => ProductModel.fromJson(e)).toList();
    }
    throw Exception('Falha ao buscar produtos: ${response.statusCode}');
  }

  // POST new product (Criar registro via RESTful)
  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await client.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ProductModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Falha ao criar produto: ${response.statusCode}');
  }

  // PUT update product (Atualizar registro via RESTful)
  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await client.put(
      Uri.parse('$baseUrl/products/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return ProductModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Falha ao atualizar produto: ${response.statusCode}');
  }

  // DELETE product (Excluir registro via RESTful)
  Future<void> deleteProduct(String id) async {
    final response = await client.delete(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao excluir produto: ${response.statusCode}');
    }
  }

  // GET services (Serviços do estabelecimento local)
  Future<List<PetServiceModel>> fetchServices() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/services'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => PetServiceModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  // GET promotions (Promoções ativas do estabelecimento)
  Future<List<PromotionModel>> fetchPromotions() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/promotions'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => PromotionModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }
}
