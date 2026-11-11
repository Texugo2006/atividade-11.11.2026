// lib/data/services/via_cep_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ViaCepAddress {
  final String cep;
  final String logradouro;
  final String bairro;
  final String localidade;
  final String uf;

  ViaCepAddress({
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.localidade,
    required this.uf,
  });

  factory ViaCepAddress.fromJson(Map<String, dynamic> json) => ViaCepAddress(
        cep: json['cep'] ?? '',
        logradouro: json['logradouro'] ?? '',
        bairro: json['bairro'] ?? '',
        localidade: json['localidade'] ?? '',
        uf: json['uf'] ?? '',
      );
}

class ViaCepService {
  final http.Client client;
  ViaCepService({http.Client? client}) : client = client ?? http.Client();

  // Consulta API pública ViaCEP para autocompletar endereço e frete local
  Future<ViaCepAddress?> getAddressByCep(String rawCep) async {
    final cleanCep = rawCep.replaceAll(RegExp(r'\D'), '');
    if (cleanCep.length != 8) return null;

    try {
      final response = await client.get(
        Uri.parse('https://viacep.com.br/ws/$cleanCep/json/'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['erro'] == true) return null;
        return ViaCepAddress.fromJson(data);
      }
    } catch (_) {}
    return null;
  }
}
