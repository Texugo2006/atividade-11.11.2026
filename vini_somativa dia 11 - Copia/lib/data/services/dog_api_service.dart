// lib/data/services/dog_api_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DogTip {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  DogTip({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class DogInfo {
  final String imageUrl;
  final String breedRaw;
  final String breedDisplayName;
  final List<DogTip> tips;

  DogInfo({
    required this.imageUrl,
    required this.breedRaw,
    required this.breedDisplayName,
    required this.tips,
  });
}

class DogApiService {
  final http.Client client;
  DogApiService({http.Client? client}) : client = client ?? http.Client();

  static const Map<String, String> _breedTranslations = {
    'mountain-bernese': 'Boiadeiro Bernês (Bernese Mountain Dog)',
    'mountain-swiss': 'Grande Boiadeiro Suíço',
    'retriever-golden': 'Golden Retriever',
    'retriever-flatcoated': 'Flat-Coated Retriever',
    'retriever-curly': 'Curly-Coated Retriever',
    'retriever-chesapeake': 'Chesapeake Bay Retriever',
    'labrador': 'Labrador Retriever',
    'germanshepherd': 'Pastor Alemão',
    'poodle-standard': 'Poodle Gigante',
    'poodle-miniature': 'Poodle Miniatura',
    'poodle-toy': 'Poodle Toy',
    'poodle-medium': 'Poodle Médio',
    'poodle': 'Poodle',
    'bulldog-french': 'Buldogue Francês',
    'bulldog-english': 'Buldogue Inglês',
    'bulldog-boston': 'Boston Terrier',
    'bulldog': 'Buldogue',
    'beagle': 'Beagle',
    'rottweiler': 'Rottweiler',
    'chihuahua': 'Chihuahua',
    'dachshund': 'Dachshund (Salsicha / Teckel)',
    'boxer': 'Boxer',
    'husky': 'Husky Siberiano',
    'pug': 'Pug',
    'dalmatian': 'Dálmata',
    'doberman': 'Doberman',
    'corgi-cardigan': 'Welsh Corgi Cardigan',
    'corgi-pembroke': 'Welsh Corgi Pembroke',
    'corgi': 'Corgi',
    'pomeranian': 'Spitz Alemão / Lulu da Pomerânia',
    'samoyed': 'Samoieda',
    'shiba': 'Shiba Inu',
    'akita': 'Akita Inu',
    'malamute': 'Alaskan Malamute',
    'maltese': 'Maltês',
    'shihtzu': 'Shih Tzu',
    'collie-border': 'Border Collie',
    'border-collie': 'Border Collie',
    'collie': 'Collie',
    'schnauzer-miniature': 'Schnauzer Miniatura',
    'schnauzer-giant': 'Schnauzer Gigante',
    'schnauzer': 'Schnauzer',
    'pinscher-miniature': 'Pinscher Miniatura',
    'pinscher': 'Pinscher',
    'pitbull': 'American Pit Bull Terrier',
    'terrier-yorkshire': 'Yorkshire Terrier',
    'terrier-bull': 'Bull Terrier',
    'terrier-fox': 'Fox Terrier',
    'greatdane': 'Dogue Alemão',
    'stbernard': 'São Bernardo',
    'hound-basset': 'Basset Hound',
    'hound-blood': 'Bloodhound',
    'hound-afghan': 'Galgo Afegão',
    'chow': 'Chow Chow',
    'spaniel-cocker': 'Cocker Spaniel',
    'groenendael': 'Pastor Belga Groenendael',
    'otterhound': 'Otterhound (Cão de Lontra)',
    'whippet': 'Whippet',
    'vizsla': 'Braco Húngaro (Vizsla)',
    'weimaraner': 'Weimaraner',
  };

  // Formata o nome da raça a partir do slug da URL da Dog API
  static String formatBreedName(String rawSlug) {
    if (_breedTranslations.containsKey(rawSlug)) {
      return _breedTranslations[rawSlug]!;
    }

    final parts = rawSlug.split('-');
    if (parts.length > 1) {
      return parts.reversed.map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}').join(' ');
    }
    return rawSlug.isEmpty ? 'Cachorro' : '${rawSlug[0].toUpperCase()}${rawSlug.substring(1)}';
  }

  // Gera dicas dinâmicas e personalizadas do especialista para a raça sorteada
  static List<DogTip> generateTipsForBreed(String breedSlug, String breedDisplayName) {
    final slug = breedSlug.toLowerCase();

    // 1. Dica de Atividade e Exercício
    DogTip energyTip;
    if (slug.contains('bulldog') || slug.contains('pug') || slug.contains('boxer')) {
      energyTip = DogTip(
        title: 'Respiração e Cuidados no Calor',
        description: 'Por ter focinho achatado (braquicefálico), o $breedDisplayName requer passeios curtos nos horários mais frescos do dia para evitar superaquecimento e fadiga respiratória.',
        icon: Icons.air,
        color: Colors.blue,
      );
    } else if (slug.contains('chihuahua') || slug.contains('pomeranian') || slug.contains('maltese') || slug.contains('shihtzu') || slug.contains('toy')) {
      energyTip = DogTip(
        title: 'Rotina Ideal para Pequeno Porte',
        description: 'O $breedDisplayName é perfeito para ambientes internos. Caminhadas leves de 20 minutos e brincadeiras com bolinhas ou mordedores são suficientes para mantê-lo feliz.',
        icon: Icons.home,
        color: Colors.teal,
      );
    } else if (slug.contains('mountain') || slug.contains('bernese') || slug.contains('greatdane') || slug.contains('stbernard') || slug.contains('rottweiler') || slug.contains('doberman')) {
      energyTip = DogTip(
        title: 'Proteção Articular para Cães Grandes',
        description: 'Como o $breedDisplayName atinge grande porte, evite subidas bruscas em escadas e pisos muito lisos durante o crescimento para preservar as articulações dos quadris.',
        icon: Icons.fitness_center,
        color: Colors.indigo,
      );
    } else {
      energyTip = DogTip(
        title: 'Gasto de Energia e Exercício Diário',
        description: 'O $breedDisplayName possui ótimo vigor físico. Programe passeios diários de 40 a 60 minutos e use brinquedos interativos recheáveis para estímulo mental.',
        icon: Icons.directions_run,
        color: Colors.orange,
      );
    }

    // 2. Dica de Pelagem e Higiene
    DogTip coatTip;
    if (slug.contains('mountain') || slug.contains('bernese') || slug.contains('samoyed') || slug.contains('husky') || slug.contains('collie') || slug.contains('golden') || slug.contains('retriever') || slug.contains('chow') || slug.contains('groenendael') || slug.contains('shepherd')) {
      coatTip = DogTip(
        title: 'Escovação Frequente de Subpelo',
        description: 'A pelagem exuberante do $breedDisplayName exige escovação pelo menos 3 vezes na semana com rasqueadeira para evitar nós e diminuir pelos espalhados pela casa.',
        icon: Icons.brush,
        color: Colors.purple,
      );
    } else if (slug.contains('poodle') || slug.contains('schnauzer') || slug.contains('bichon') || slug.contains('maltese')) {
      coatTip = DogTip(
        title: 'Tosa e Hidratação Periódica',
        description: 'Pelos encaracolados ou contínuos do $breedDisplayName necessitam de tosa higiênica e banho a cada 15 a 20 dias em nosso pet shop para manter o desembaraço.',
        icon: Icons.content_cut,
        color: Colors.deepPurple,
      );
    } else {
      coatTip = DogTip(
        title: 'Higiene e Brilho de Pelos Curtos',
        description: 'A manutenção do pelo do $breedDisplayName é rápida: passe uma luva de borracha semanalmente para retirar pelos mortos e utilize shampoo neutro nos banhos.',
        icon: Icons.clean_hands,
        color: Colors.teal,
      );
    }

    // 3. Dica de Nutrição e Saúde
    DogTip healthTip;
    if (slug.contains('mountain') || slug.contains('bernese') || slug.contains('greatdane') || slug.contains('stbernard') || slug.contains('mastiff') || slug.contains('rottweiler') || slug.contains('shepherd') || slug.contains('labrador') || slug.contains('golden')) {
      healthTip = DogTip(
        title: 'Nutrição Especializada e Anti-Torção',
        description: 'Ofereça ração Super Premium para cães de grande porte dividida em 2 refeições diárias e evite brincadeiras pesadas imediatamente após a alimentação.',
        icon: Icons.restaurant,
        color: Colors.green,
      );
    } else if (slug.contains('chihuahua') || slug.contains('yorkshire') || slug.contains('dachshund') || slug.contains('pug') || slug.contains('maltese')) {
      healthTip = DogTip(
        title: 'Saúde Bucal e Tártaro',
        description: 'Cães como o $breedDisplayName acumulam tártaro com facilidade. Ofereça petiscos dentais mastigáveis da nossa loja e realize profilaxia com veterinário.',
        icon: Icons.healing,
        color: Colors.red,
      );
    } else {
      healthTip = DogTip(
        title: 'Prevenção e Vacinas Anuais',
        description: 'Mantenha em dia as vacinas V10 e Antirrábica do seu $breedDisplayName e aplique antipulgas mensalmente para garantir imunidade completa.',
        icon: Icons.medical_services,
        color: Colors.red,
      );
    }

    return [energyTip, coatTip, healthTip];
  }

  // Consome a Dog API pública externa e retorna objeto DogInfo completo com raça e dicas
  Future<DogInfo?> getRandomDogInfo() async {
    try {
      final response = await client.get(
        Uri.parse('https://dog.ceo/api/breeds/image/random'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final imageUrl = data['message'] as String;

          // Extrai o slug da raça a partir da URL: https://images.dog.ceo/breeds/{slug}/...
          final uri = Uri.parse(imageUrl);
          String breedSlug = 'dog';
          final breedsIndex = uri.pathSegments.indexOf('breeds');
          if (breedsIndex != -1 && uri.pathSegments.length > breedsIndex + 1) {
            breedSlug = uri.pathSegments[breedsIndex + 1];
          }

          final breedDisplayName = formatBreedName(breedSlug);
          final tips = generateTipsForBreed(breedSlug, breedDisplayName);

          return DogInfo(
            imageUrl: imageUrl,
            breedRaw: breedSlug,
            breedDisplayName: breedDisplayName,
            tips: tips,
          );
        }
      }
    } catch (_) {}
    return null;
  }
}
