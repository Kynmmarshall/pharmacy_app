import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_app/core/themes/app_theme.dart';
import 'package:pharmacy_app/data/local/database_helper.dart';
import 'package:pharmacy_app/features/auth/presentation/screens/login_screen.dart';
import 'package:pharmacy_app/features/auth/presentation/screens/register_screen.dart';
import 'package:pharmacy_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:pharmacy_app/features/home/presentation/screens/home_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final db = DatabaseHelper();
  await db.database; // Creates database on first run

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Define routes outside the class
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      title: 'PharmaCare',
    );
  }
}