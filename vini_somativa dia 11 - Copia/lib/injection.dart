// lib/injection.dart
import 'package:get_it/get_it.dart';
import 'core/constants.dart';
import 'data/services/api_service.dart';
import 'data/services/via_cep_service.dart';
import 'data/services/dog_api_service.dart';
import 'data/providers/api_provider.dart';
import 'data/providers/local_provider.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/usecases/get_products.dart';
import 'domain/usecases/create_product.dart';
import 'domain/usecases/update_product.dart';
import 'domain/usecases/delete_product.dart';
import 'domain/usecases/add_to_cart.dart';
import 'domain/usecases/remove_from_cart.dart';
import 'domain/usecases/clear_cart.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  // Serviços RESTful externos
  getIt.registerSingleton<ApiService>(ApiService(baseUrl: kBaseUrl));
  getIt.registerSingleton<ViaCepService>(ViaCepService());
  getIt.registerSingleton<DogApiService>(DogApiService());

  // Repositório que utiliza ApiProvider
  getIt.registerFactory<ProductRepository>(
      () => ApiProvider(getIt<ApiService>()));

  // Persistência local segura com Hive (dados sensíveis no dispositivo)
  final local = LocalProvider();
  await local.init();
  getIt.registerSingleton<LocalProvider>(local);

  // Use-cases de Produtos (CRUD RESTful)
  getIt.registerFactory(() => GetProducts(getIt<ProductRepository>()));
  getIt.registerFactory(() => CreateProduct(getIt<ProductRepository>()));
  getIt.registerFactory(() => UpdateProduct(getIt<ProductRepository>()));
  getIt.registerFactory(() => DeleteProduct(getIt<ProductRepository>()));

  // Use-cases de Carrinho (Persistência Local)
  getIt.registerFactory(() => AddToCart(getIt<LocalProvider>()));
  getIt.registerFactory(() => RemoveFromCart(getIt<LocalProvider>()));
  getIt.registerFactory(() => ClearCart(getIt<LocalProvider>()));

  // Registro do ApiProvider
  final apiProvider = ApiProvider(getIt<ApiService>());
  getIt.registerSingleton<ApiProvider>(apiProvider);
}
