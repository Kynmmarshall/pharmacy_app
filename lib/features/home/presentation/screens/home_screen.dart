import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_app/data/providers/database_provider.dart';
import 'package:pharmacy_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pharmacy_app/features/home/presentation/widgets/medicine_card.dart';
import 'package:pharmacy_app/features/home/presentation/widgets/category_chip.dart';
import 'package:pharmacy_app/features/home/presentation/widgets/search_bar.dart';
import 'package:pharmacy_app/features/home/presentation/widgets/featured_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userName = authState.user?['name'] ?? 'Guest';
    final medicinesAsync = ref.watch(medicinesProvider);
    
    debugPrint('🏠 HomeScreen - User: $userName');
    debugPrint('🏠 HomeScreen - Authenticated: ${authState.isAuthenticated}');
    debugPrint('🏠 HomeScreen - User data: ${authState.user}');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PharmaCare',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: medicinesAsync.when(
        loading: () {
          debugPrint('⏳ HomeScreen: Loading medicines...');
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          debugPrint('❌ HomeScreen: Error loading medicines: $error');
          return Center(child: Text('Error: $error'));
        },
        data: (medicines) {
          debugPrint('✅ HomeScreen: Loaded ${medicines.length} medicines');
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Text(
                    'Hello, $userName! 👋',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find your medications easily',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  
                  // Search Bar
                  PharmacySearchBar(),
                  const SizedBox(height: 24),
                  
                  // Categories Section
                  Text(
                    'Categories',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        CategoryChip(label: 'All', icon: Icons.all_inclusive),
                        CategoryChip(label: 'Pain Relief', icon: Icons.health_and_safety),
                        CategoryChip(label: 'Vitamins', icon: Icons.local_hospital),
                        CategoryChip(label: 'Skin Care', icon: Icons.spa),
                        CategoryChip(label: 'First Aid', icon: Icons.medical_services),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Featured Medicines
                  const FeaturedSection(),
                  const SizedBox(height: 24),
                  
                  // All Medicines
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Medicines',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Medicine List Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: medicines.length,
                    itemBuilder: (context, index) {
                      final medicine = medicines[index];
                      return MedicineCard(
                        name: medicine.name,
                        description: medicine.description,
                        price: medicine.price,
                        category: medicine.category,
                        requiresPrescription: medicine.requiresPrescription,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            label: 'Consult',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}