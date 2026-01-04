
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_app/models/medicine_model.dart';
import 'package:pharmacy_app/providers/auth_provider.dart';
import '../local/database_helper.dart';

final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final medicinesProvider = FutureProvider<List<MedicineModel>>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.getAllMedicines();
});

final cartProvider = StateNotifierProvider<CartNotifier, List<Map<String, dynamic>>>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.user?['id'];
  return CartNotifier(ref.read(databaseProvider), userId ?? 0);
});

class CartNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final DatabaseHelper _db;
  final int _userId;

  CartNotifier(this._db, this._userId) : super([]) {
    if (_userId > 0) {
      _loadCart();
    }
  }

  Future<void> _loadCart() async {
    if (_userId <= 0) return;
    final items = await _db.getCartItems(_userId);
    state = items;
  }

  Future<void> addItem(int medicineId, int quantity) async {
    if (_userId <= 0) {
      throw Exception('Please login to add items to cart');
    }
    await _db.addToCart(_userId, medicineId, quantity);
    await _loadCart();
  }

  Future<void> removeItem(int cartId) async {
    if (_userId <= 0) return;
    await _db.removeFromCart(cartId);
    await _loadCart();
  }

  Future<void> updateQuantity(int cartId, int quantity) async {
    if (_userId <= 0) return;
    await _db.updateCartQuantity(cartId, quantity);
    await _loadCart();
  }

  Future<void> clearCart() async {
    if (_userId <= 0) return;
    await _db.clearUserCart(_userId);
    state = [];
  }

  Future<double> getTotal() async {
    if (_userId <= 0) return 0.0;
    return await _db.getCartTotal(_userId);
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