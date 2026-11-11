// test/dog_api_service_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:petshop_app/data/services/dog_api_service.dart';

void main() {
  group('DogApiService & Breed Tips Tests', () {
    test('Deve formatar raças conhecidas a partir do dicionário em português', () {
      expect(
        DogApiService.formatBreedName('mountain-bernese'),
        equals('Boiadeiro Bernês (Bernese Mountain Dog)'),
      );
      expect(
        DogApiService.formatBreedName('retriever-golden'),
        equals('Golden Retriever'),
      );
      expect(
        DogApiService.formatBreedName('bulldog-french'),
        equals('Buldogue Francês'),
      );
    });

    test('Deve formatar raças não catalogadas revertendo slug adequadamente', () {
      expect(
        DogApiService.formatBreedName('hound-ibizan'),
        equals('Ibizan Hound'),
      );
      expect(
        DogApiService.formatBreedName('akita'),
        equals('Akita Inu'),
      );
      expect(
        DogApiService.formatBreedName(''),
        equals('Cachorro'),
      );
    });

    test('Deve gerar exatamente 3 dicas contextualizadas por raça', () {
      final tipsBulldog = DogApiService.generateTipsForBreed('bulldog-french', 'Buldogue Francês');
      expect(tipsBulldog.length, equals(3));
      expect(tipsBulldog[0].title, contains('Respiração'));

      final tipsHusky = DogApiService.generateTipsForBreed('husky', 'Husky Siberiano');
      expect(tipsHusky.length, equals(3));
      expect(tipsHusky[1].title, contains('Subpelo'));

      final tipsPoodle = DogApiService.generateTipsForBreed('poodle-toy', 'Poodle Toy');
      expect(tipsPoodle.length, equals(3));
      expect(tipsPoodle[1].title, contains('Tosa'));
    });

    test('Deve consumir API externa Dog API com sucesso via MockClient', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString() == 'https://dog.ceo/api/breeds/image/random') {
          return http.Response(
            jsonEncode({
              'message': 'https://images.dog.ceo/breeds/mountain-bernese/n02107683_3900.jpg',
              'status': 'success',
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = DogApiService(client: mockClient);
      final dogInfo = await service.getRandomDogInfo();

      expect(dogInfo, isNotNull);
      expect(dogInfo!.breedRaw, equals('mountain-bernese'));
      expect(dogInfo.breedDisplayName, equals('Boiadeiro Bernês (Bernese Mountain Dog)'));
      expect(dogInfo.imageUrl, equals('https://images.dog.ceo/breeds/mountain-bernese/n02107683_3900.jpg'));
      expect(dogInfo.tips.length, equals(3));
    });

    test('Deve tratar erros de rede da Dog API retornando null com segurança', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = DogApiService(client: mockClient);
      final dogInfo = await service.getRandomDogInfo();

      expect(dogInfo, isNull);
    });
  });
}
