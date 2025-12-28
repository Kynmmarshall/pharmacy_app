// lib/features/medicines/presentation/widgets/medicine_card.dart
import 'package:flutter/material.dart';
import 'package:pharmacy_app/core/themes/app_theme.dart';

class MedicineCard extends StatelessWidget {
  final String name;
  final String description;
  final double price;
  final String category;
  final bool requiresPrescription;
  final VoidCallback? onAddToCart;
  
  const MedicineCard({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.requiresPrescription,
    this.onAddToCart,
  });
  
  @override
  Widget build(BuildContext context) {
    debugPrint('💊 Building MedicineCard for: $name');
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prescription badge
            if (requiresPrescription)
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
            
            // Medicine image placeholder
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(category),
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Medicine name
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Category
            Text(
              category,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const Spacer(),
            
            // Price and add button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: onAddToCart,
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