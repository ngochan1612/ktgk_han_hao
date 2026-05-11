import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'store/app_provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/cuisine_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/food_list_screen.dart';
import 'screens/payment_success_screen.dart';
import 'services/hive_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await HiveService.init();

  runApp(
    ChangeNotifierProvider(create: (_) => AppProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant App',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class CuisineWrapper extends StatelessWidget {
  const CuisineWrapper({super.key});
  @override
  Widget build(BuildContext context) => const CuisineScreen();
}

class SignUpWrapper extends StatelessWidget {
  const SignUpWrapper({super.key});
  @override
  Widget build(BuildContext context) => const SignUpScreen();
}

class ForgotPasswordWrapper extends StatelessWidget {
  const ForgotPasswordWrapper({super.key});
  @override
  Widget build(BuildContext context) => const ForgotPasswordScreen();
}

class CartWrapper extends StatelessWidget {
  const CartWrapper({super.key});
  @override
  Widget build(BuildContext context) => const CartScreen();
}

class FoodListWrapper extends StatelessWidget {
  final Map<String, dynamic> cuisine;
  const FoodListWrapper({super.key, required this.cuisine});
  @override
  Widget build(BuildContext context) => FoodListScreen(cuisine: cuisine);
}

class PaymentWrapper extends StatelessWidget {
  final double total;
  const PaymentWrapper({super.key, required this.total});
  @override
  Widget build(BuildContext context) => PaymentSuccessScreen(total: total);
}
