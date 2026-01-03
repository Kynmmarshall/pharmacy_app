
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_app/models/medicine_model.dart';
import '../local/database_helper.dart';

final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final medicinesProvider = FutureProvider<List<MedicineModel>>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.getAllMedicines();
});

final cartProvider = StateNotifierProvider<CartNotifier, List<Map<String, dynamic>>>((ref) {
  return CartNotifier(ref.read(databaseProvider));
});

class CartNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final DatabaseHelper _db;
  CartNotifier(this._db) : super([]) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    final items = await _db.getCartItems();
    state = items;
  }

  Future<void> addItem(int medicineId, int quantity) async {
    await _db.addToCart(medicineId, quantity);
    await _loadCart();
  }

  Future<void> clearCart() async {
    await _db.clearCart();
    state = [];
  }

  final searchMedicinesProvider = FutureProvider.family<List<MedicineModel>, String>((ref, query) async {
  debugPrint('🔍 Searching medicines for: $query');
  final db = ref.read(databaseProvider);
  try {
    final results = await db.searchMedicines(query);
    debugPrint('✅ Found ${results.length} results');
    return results;
  } catch (e) {
    debugPrint('❌ Search error: $e');
    return [];
  }
});
}