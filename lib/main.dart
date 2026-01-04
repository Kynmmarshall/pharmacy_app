import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_app/screens/cart_screen.dart';
import 'package:pharmacy_app/screens/consult_screen.dart';
import 'package:pharmacy_app/screens/medecine_detail_screen.dart';
import 'package:pharmacy_app/screens/profile_screen.dart';
import 'package:pharmacy_app/themes/app_theme.dart';
import 'package:pharmacy_app/data/local/database_helper.dart';
import 'package:pharmacy_app/screens/login_screen.dart';
import 'package:pharmacy_app/screens/register_screen.dart';
import 'package:pharmacy_app/screens/forgot_password_screen.dart';
import 'package:pharmacy_app/screens/home_screen.dart';
import 'package:pharmacy_app/screens/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database - FIXED: Use proper async initialization
  try {
    final db = DatabaseHelper();
    await db.database; // Creates database on first run
    print('✅ Database initialized successfully');
  } catch (e) {
    print('❌ Database initialization error: $e');
  }

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
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/medicine/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
        return MedicineDetailScreen(medicineId: id);
      },
    ),
    GoRoute(
      path: '/consult',
      builder: (context, state) => const ConsultScreen(),
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