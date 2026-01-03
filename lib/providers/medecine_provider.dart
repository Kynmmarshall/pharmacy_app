// lib/features/medicines/presentation/providers/medicine_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_app/data/providers/database_provider.dart';
import 'package:pharmacy_app/models/medicine_model.dart';

final medicinesProvider = FutureProvider<List<MedicineModel>>((ref) async {
  debugPrint('🔄 medicinesProvider: Fetching medicines...');
  final db = ref.read(databaseProvider);
  try {
    final medicines = await db.getAllMedicines();
    debugPrint('✅ medicinesProvider: Successfully fetched ${medicines.length} medicines');
    return medicines;
  } catch (e) {
    debugPrint('❌ medicinesProvider: Error fetching medicines: $e');
    rethrow;
  }
});

final searchMedicinesProvider = FutureProvider.family<List<MedicineModel>, String>((ref, query) async {
  debugPrint('🔍 searchMedicinesProvider: Searching for "$query"');
  final db = ref.read(databaseProvider);
  try {
    final results = await db.searchMedicines(query);
    debugPrint('✅ searchMedicinesProvider: Found ${results.length} results');
    return results;
  } catch (e) {
    debugPrint('❌ searchMedicinesProvider: Error searching: $e');
    rethrow;
  }
});

final categoryMedicinesProvider = FutureProvider.family<List<MedicineModel>, String>((ref, category) async {
  debugPrint('🏷️ categoryMedicinesProvider: Fetching $category medicines');
  final db = ref.read(databaseProvider);
  try {
    final medicines = await db.getMedicinesByCategory(category);
    debugPrint('✅ categoryMedicinesProvider: Found ${medicines.length} $category medicines');
    return medicines;
  } catch (e) {
    debugPrint('❌ categoryMedicinesProvider: Error: $e');
    rethrow;
  }
});