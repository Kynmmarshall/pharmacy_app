import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_app/themes/app_theme.dart';
import 'package:pharmacy_app/models/medicine_model.dart';
import 'package:pharmacy_app/data/providers/database_provider.dart';
import 'package:pharmacy_app/providers/auth_provider.dart';

class MedicineCard extends ConsumerWidget {
  final MedicineModel medicine;
  final VoidCallback? onAddToCart;
  
  const MedicineCard({
    super.key,
    required this.medicine,
    this.onAddToCart,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return GestureDetector( 
     onTap: () => context.go('/medicine/${medicine.id}'),
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (medicine.requiresPrescription)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.medical_services, size: 12, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        'Rx',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Image.asset(
                  medicine.imageUrl,
                  width: 200,
                  height: 200,
                )
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              medicine.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            Text(
              medicine.category,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              medicine.description,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const Spacer(),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${medicine.price.toStringAsFixed(0)} Fcfa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (!authState.isAuthenticated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please login to add to cart'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    try {
                      await cartNotifier.addItem(medicine.id, 1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${medicine.name} to cart'),
                          backgroundColor: Colors.green,
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
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.add_circle,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
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