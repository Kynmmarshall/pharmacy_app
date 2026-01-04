import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_app/themes/app_theme.dart';
import 'package:pharmacy_app/models/medicine_model.dart';
import 'package:pharmacy_app/providers/auth_provider.dart';
import 'package:pharmacy_app/data/providers/database_provider.dart';
import 'package:pharmacy_app/widgets/custom_button.dart';

final medicineByIdProvider = FutureProvider.family<MedicineModel?, int>((ref, id) async {
  final db = ref.read(databaseProvider);
  return await db.getMedicineById(id);
});

class MedicineDetailScreen extends ConsumerStatefulWidget {
  final int medicineId;
  
  const MedicineDetailScreen({super.key, required this.medicineId});
  
  @override
  ConsumerState<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends ConsumerState<MedicineDetailScreen> {
  int _quantity = 1;
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    final medicineAsync = ref.watch(medicineByIdProvider(widget.medicineId));
    final authState = ref.watch(authProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareMedicine,
          ),
        ],
      ),
      body: medicineAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Error loading medicine'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
        data: (medicine) {
          if (medicine == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.medication_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Medicine not found'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }
          
          return _buildMedicineDetails(medicine, authState, cartNotifier);
        },
      ),
    );
  }
  
  Widget _buildMedicineDetails(MedicineModel medicine, AuthState authState, CartNotifier cartNotifier) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medicine Image
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
            child: Center(
              child: Hero(
                tag: 'medicine-${medicine.id}',
                child: Image.asset(
                  medicine.imageUrl,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Medicine Name and Prescription Badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        medicine.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (medicine.requiresPrescription)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.medical_services, size: 16, color: Colors.orange),
                            SizedBox(width: 4),
                            Text(
                              'Rx',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Category
                Text(
                  medicine.category,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Price
                Text(
                  '${medicine.price.toStringAsFixed(0)} Fcfa',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Stock Status
                Row(
                  children: [
                    Icon(
                      Icons.inventory,
                      color: medicine.stockColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      medicine.stockStatus,
                      style: TextStyle(
                        fontSize: 16,
                        color: medicine.stockColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${medicine.stock} units available',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  medicine.description,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Manufacturer
                if (medicine.manufacturer.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Manufacturer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        medicine.manufacturer,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                
                if (medicine.manufacturer.isNotEmpty) const SizedBox(height: 16),
                
                // Dosage
                if (medicine.dosage.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recommended Dosage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        medicine.dosage,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 32),
                
                // Quantity Selector
                const Text(
                  'Quantity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primaryColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _quantity.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _quantity < medicine.stock
                            ? () => setState(() => _quantity++)
                            : null,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Total: ${(medicine.price * _quantity).toStringAsFixed(0)} Fcfa',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Action Buttons
                Column(
                  children: [
                    CustomButton(
                      onPressed: _isLoading ? null : () => _addToCart(medicine, authState, cartNotifier),
                      isLoading: _isLoading,
                      text: medicine.requiresPrescription
                          ? 'Upload Prescription'
                          : 'Add to Cart',
                      width: double.infinity,
                      backgroundColor: medicine.requiresPrescription
                          ? Colors.orange
                          : AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    if (medicine.requiresPrescription)
                      CustomButton(
                        onPressed: _isLoading ? null : () => _addToCart(medicine, authState, cartNotifier),
                        isLoading: false,
                        text: 'Add to Cart Anyway',
                        width: double.infinity,
                        backgroundColor: Colors.grey[300],
                        textColor: Colors.black,
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _addToFavorites(medicine),
                      icon: const Icon(Icons.favorite_border),
                      label: const Text('Add to Favorites'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(color: AppTheme.primaryColor),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Safety Information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Safety Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Consult a doctor before use\n'
                        '• Follow prescribed dosage\n'
                        '• Keep out of reach of children\n'
                        '• Store in a cool, dry place\n'
                        '• Check expiry date before use',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _addToCart(MedicineModel medicine, AuthState authState, CartNotifier cartNotifier) async {
    if (!authState.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add to cart'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (medicine.requiresPrescription) {
      _showPrescriptionDialog(medicine);
      return;
    }
    
    if (!medicine.isInStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medicine.name} is out of stock'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_quantity > medicine.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only ${medicine.stock} units available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      await cartNotifier.addItem(medicine.id, _quantity);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $_quantity ${medicine.name} to cart'),
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
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _showPrescriptionDialog(MedicineModel medicine) {
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
          '${medicine.name} requires a valid doctor\'s prescription. '
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
              // Navigate to prescription upload
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
  
  void _addToFavorites(MedicineModel medicine) {
    // TODO: Implement favorites functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${medicine.name} to favorites'),
        backgroundColor: Colors.pink,
      ),
    );
  }
  
  void _shareMedicine() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon!'),
      ),
    );
  }
}