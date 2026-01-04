// lib/features/search/presentation/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_app/models/medicine_model.dart';
import 'package:pharmacy_app/providers/medecine_provider.dart';
import 'package:pharmacy_app/providers/auth_provider.dart';
import 'package:pharmacy_app/data/providers/database_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchMedicinesProvider(_searchQuery));
    final authState = ref.read(authProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search medicines...',
            border: InputBorder.none,
          ),
          autofocus: true,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
        ],
      ),
      body: _searchQuery.isEmpty
          ? _buildInitialState()
          : searchResults.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (medicines) => _buildSearchResults(medicines, authState, cartNotifier),
            ),
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Search for medicines',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<MedicineModel> medicines, AuthState authState, CartNotifier cartNotifier) {
    if (medicines.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No medicines found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        final medicine = medicines[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(medicine.category),
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              medicine.name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              '${medicine.price.toStringAsFixed(0)} Fcfa • ${medicine.category}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            trailing: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  _addToCart(medicine, authState, cartNotifier, context);
                },
                padding: EdgeInsets.zero,
              ),
            ),
            onTap: () => context.go('/medicine/${medicine.id}'),
          ),
        );
      },
    );
  }

  void _addToCart(MedicineModel medicine, AuthState authState, CartNotifier cartNotifier, BuildContext context) {
    if (!authState.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add to cart'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if prescription is required
    if (medicine.requiresPrescription) {
      _showPrescriptionRequiredDialog(medicine, context);
      return;
    }

    // Check stock availability
    if (!medicine.isInStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medicine.name} is out of stock'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      cartNotifier.addItem(medicine.id, 1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${medicine.name} to cart'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () => context.go('/cart'),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showPrescriptionRequiredDialog(MedicineModel medicine, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.medical_services, color: Colors.orange),
            SizedBox(width: 8),
            Text('Prescription Required'),
          ],
        ),
        content: Text(
          '${medicine.name} requires a doctor\'s prescription. '
          'Please upload your prescription to purchase this medicine.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to prescription upload screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prescription upload feature coming soon!'),
                ),
              );
            },
            child: const Text('Upload Prescription'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'pain relief':
        return Icons.health_and_safety;
      case 'vitamins':
        return Icons.local_hospital;
      case 'antibiotics':
        return Icons.medical_services;
      case 'allergy':
        return Icons.air;
      case 'gastrointestinal':
        return Icons.sick;
      case 'diabetes':
        return Icons.monitor_heart;
      case 'cardiac':
        return Icons.favorite;
      case 'neuro':
        return Icons.psychology;
      default:
        return Icons.medication;
    }
  }
}