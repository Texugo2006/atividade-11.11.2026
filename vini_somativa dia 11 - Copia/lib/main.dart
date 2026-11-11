// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'injection.dart' as di;
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/cart_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'domain/usecases/get_products.dart';
import 'domain/usecases/create_product.dart';
import 'domain/usecases/update_product.dart';
import 'domain/usecases/delete_product.dart';
import 'domain/usecases/add_to_cart.dart';
import 'domain/usecases/remove_from_cart.dart';
import 'domain/usecases/clear_cart.dart';
import 'data/providers/local_provider.dart';
import 'data/providers/api_provider.dart';
import 'data/services/api_service.dart';
import 'data/services/via_cep_service.dart';
import 'data/services/dog_api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.setup(); // registra dependências e inicializa Hive
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<ApiService>(create: (_) => di.getIt<ApiService>()),
        Provider<ViaCepService>(create: (_) => di.getIt<ViaCepService>()),
        Provider<DogApiService>(create: (_) => di.getIt<DogApiService>()),

        // Providers
        Provider<LocalProvider>(create: (_) => di.getIt<LocalProvider>()),
        Provider<ApiProvider>(create: (_) => di.getIt<ApiProvider>()),

        // Use-cases de Produtos (RESTful CRUD)
        Provider<GetProducts>(create: (_) => di.getIt<GetProducts>()),
        Provider<CreateProduct>(create: (_) => di.getIt<CreateProduct>()),
        Provider<UpdateProduct>(create: (_) => di.getIt<UpdateProduct>()),
        Provider<DeleteProduct>(create: (_) => di.getIt<DeleteProduct>()),

        // Use-cases de Carrinho (Persistência Local)
        Provider<AddToCart>(create: (_) => di.getIt<AddToCart>()),
        Provider<RemoveFromCart>(create: (_) => di.getIt<RemoveFromCart>()),
        Provider<ClearCart>(create: (_) => di.getIt<ClearCart>()),
      ],
      child: MaterialApp(
        title: 'Pet Shop Digital Horizon',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const HomeScreen(),
          '/cart': (_) => const CartScreen(),
          '/login': (_) => const LoginScreen(),
        },
      ),
    );
  }
}
