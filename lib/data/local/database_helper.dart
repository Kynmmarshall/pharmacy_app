// lib/data/local/database_helper.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pharmacy_app/models/medicine_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  bool _isFirstRun = false;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final path = await getDatabasesPath();

    // Check if this is first run after install
    final isFirstRun = prefs.getBool('first_run') ?? true;
    _isFirstRun = isFirstRun;

    if (isFirstRun) {
      debugPrint('🆕 First run detected - Creating fresh database');
      
      // Delete all existing pharmacy databases
      await _deleteAllDatabases(path);
      
      // Mark as not first run anymore
      await prefs.setBool('first_run', false);
      
      // Store install version
      final packageInfo = await PackageInfo.fromPlatform();
      await prefs.setString('install_version', packageInfo.version);
    }

    final dbPath = join(path, 'pharmacy.db');
    debugPrint('📁 Database path: $dbPath');
    
    return await openDatabase(
      dbPath,
      version: 6,
      onCreate: _createTables,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onUpgrade: _onUpgrade,
    );
  } catch (e) {
    debugPrint('❌ Database initialization error: $e');
    rethrow;
  }
}

  Future<void> _createTables(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        phone TEXT,
        password TEXT,
        role TEXT DEFAULT 'user'
      )
    ''');

    // Medicines table
    await db.execute('''
      CREATE TABLE medicines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        price REAL,
        category TEXT,
        stock INTEGER,
        manufacturer TEXT,
        image_url TEXT,
        requires_prescription INTEGER DEFAULT 0
      )
    ''');

    // Cart table
    await db.execute('''
      CREATE TABLE cart(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        medicine_id INTEGER,
        quantity INTEGER DEFAULT 1,
        added_at TEXT
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        items TEXT,
        total REAL,
        status TEXT,
        created_at TEXT
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  // Add migration function
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('🔄 Migrating database from version $oldVersion to $newVersion');
    
    if (oldVersion < 5) {
      // Add role column to users table
      await db.execute('ALTER TABLE users ADD COLUMN role TEXT DEFAULT "user"');
      debugPrint('✅ Added role column to users table');
    }
    
  }

   Future<void> _deleteAllDatabases(String path) async {
    final dir = Directory(path);
    
    if (await dir.exists()) {
      final entities = dir.listSync();
      
      for (var entity in entities) {
        if (entity is File && 
            (entity.path.endsWith('.db') || 
             entity.path.endsWith('.db-shm') || 
             entity.path.endsWith('.db-wal'))) {
          try {
            await entity.delete();
            debugPrint('🗑️ Deleted: ${basename(entity.path)}');
          } catch (e) {
            debugPrint('❌ Error deleting ${basename(entity.path)}: $e');
          }
        }
      }
    }
  }
  
  // Reset database for testing
  Future<void> resetDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_run', true);
    
    final path = await getDatabasesPath();
    await _deleteAllDatabases(path);
    
    debugPrint('🔄 Database reset complete');
  }

  // User methods
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUser(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Cart methods
  Future<int> addToCart(int userId, int medicineId, int quantity) async {
    final db = await database;
    
    // Check if item already in cart
    final existing = await db.query(
      'cart',
      where: 'user_id = ? AND medicine_id = ?',
      whereArgs: [userId, medicineId],
    );
    
    if (existing.isNotEmpty) {
      // Update quantity if exists
      final currentQty = existing.first['quantity'] as int;
      return await db.update(
        'cart',
        {'quantity': currentQty + quantity},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      // Insert new item
      return await db.insert('cart', {
        'user_id': userId,
        'medicine_id': medicineId,
        'quantity': quantity,
        'added_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Get cart items for specific user
  Future<List<Map<String, dynamic>>> getCartItems(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT cart.*, medicines.name, medicines.price, medicines.image_url, medicines.stock
      FROM cart 
      JOIN medicines ON cart.medicine_id = medicines.id
      WHERE cart.user_id = ?
      ORDER BY cart.added_at DESC
    ''', [userId]);
  }

  // Remove from cart
Future<int> removeFromCart(int cartId) async {
  final db = await database;
  return await db.delete(
    'cart',
    where: 'id = ?',
    whereArgs: [cartId],
  );
}

// Update cart quantity
Future<int> updateCartQuantity(int cartId, int quantity) async {
  final db = await database;
  return await db.update(
    'cart',
    {'quantity': quantity},
    where: 'id = ?',
    whereArgs: [cartId],
  );
}

// Clear user's cart
Future<void> clearUserCart(int userId) async {
  final db = await database;
  await db.delete(
    'cart',
    where: 'user_id = ?',
    whereArgs: [userId],
  );
}

// Get cart total
Future<double> getCartTotal(int userId) async {
  final db = await database;
  final result = await db.rawQuery('''
    SELECT SUM(medicines.price * cart.quantity) as total
    FROM cart 
    JOIN medicines ON cart.medicine_id = medicines.id
    WHERE cart.user_id = ?
  ''', [userId]);
  
  return result.first['total'] as double? ?? 0.0;
}

  // Order methods
  Future<int> createOrder(List<Map<String, dynamic>> items, double total) async {
    final db = await database;
    return await db.insert('orders', {
      'items': items.map((item) => item['id']).join(','),
      'total': total,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Add to DatabaseHelper class
Future<int> registerUser(String name, String email, String phone, String password, String role) async {
  final db = await database;
  
  // Check if user exists
  final existing = await db.query(
    'users',
    where: 'email = ?',
    whereArgs: [email],
  );
  
  if (existing.isNotEmpty) {
    throw Exception('User already exists');
  }
  
  // Insert new user
  return await db.insert('users', {
    'name': name,
    'email': email,
    'phone': phone,
    'password': password, // In production, hash this!
    'role': role,
  });
}

Future<Map<String, dynamic>?> loginUser(String email, String password) async {
  final db = await database;
  
  final result = await db.query(
    'users',
    where: 'email = ? AND password = ?',
    whereArgs: [email, password],
    limit: 1,
  );
  
  if (result.isEmpty) {
    return null;
  }
  
  return result.first;
}

Future<void> updateUser(int userId, Map<String, dynamic> updates) async {
  final db = await database;
  await db.update(
    'users',
    updates,
    where: 'id = ?',
    whereArgs: [userId],
  );
}

Future<void> deleteUser(int userId) async {
  final db = await database;
  await db.delete(
    'users',
    where: 'id = ?',
    whereArgs: [userId],
  );
}

// In database_helper.dart, update _insertSampleData method:
Future<void> _insertSampleData(Database db) async {
  debugPrint('📦 Inserting sample medicine data...');
  
  final medicines = [
    {
      'name': 'Paracetamol 500mg',
      'description': 'For headache and fever relief',
      'price': 2500,
      'category': 'Pain Relief',
      'requires_prescription': 0,
      'image_url': 'assets/medicines/paracetamol.jpg',
      'stock': 50,
    },
    {
      'name': 'Vitamin C 1000mg',
      'description': 'Immune system booster',
      'price': 1000,
      'category': 'Vitamins',
      'requires_prescription': 0,
      'image_url': 'assets/medicines/vitamin c.jpg',
      'stock': 30,
    },
    {
      'name': 'Amoxicillin 500mg',
      'description': 'Antibiotic for bacterial infections',
      'price': 1200,
      'category': 'Antibiotics',
      'requires_prescription': 1,
      'image_url': 'assets/medicines/amoxicillin.jpg',
      'stock': 20,
    },
    {
      'name': 'Cetirizine 10mg',
      'description': 'Anti-allergy tablets',
      'price': 1500,
      'category': 'Allergy',
      'requires_prescription': 0,
      'image_url': 'assets/medicines/cetrizine.jpg',
      'stock': 40,
    },
    {
      'name': 'Omeprazole 20mg',
      'description': 'Acid reflux medicine',
      'price': 4800,
      'category': 'Gastrointestinal',
      'requires_prescription': 0,
      'image_url': 'assets/medicines/omeprazole.jpg',
      'stock': 25,
    },
    {
      'name': 'Metformin 500mg',
      'description': 'Diabetes medication',
      'price': 2000,
      'category': 'Diabetes',
      'requires_prescription': 1,
      'image_url': 'assets/medicines/metformin.jpg',
      'stock': 15,
    },
    {
      'name': 'Aspirin 75mg',
      'description': 'Blood thinner and pain relief',
      'price': 2500,
      'category': 'Cardiac',
      'requires_prescription': 0,
      'image_url': 'assets/medicines/aspirin.jpg',
      'stock': 35,
    },
    {
      'name': 'Ibuprofen 400mg',
      'description': 'Anti-inflammatory painkiller',
      'price': 1500,
      'category': 'Pain Relief',
      'requires_prescription': 0,
      'image_url': 'assets/medicines/ibuprofen.jpg',
      'stock': 45,
    },
    {
      'name': 'Multivitamin Tablets',
      'description': 'Daily essential vitamins',
      'price': 1000,
      'category': 'Vitamins',
      'requires_prescription': 0,
      'image_url': 'assets/medicines/multivitamin.jpg',
      'stock': 60,
    },
    {
      'name': 'Diazepam 5mg',
      'description': 'For anxiety and muscle spasms',
      'price': 1000,
      'category': 'Neuro',
      'requires_prescription': 1,
      'image_url': 'assets/medicines/diazepam.jpg',
      'stock': 10,
    },
  ];
  
  for (final medicine in medicines) {
    try {
      await db.insert('medicines', medicine);
      debugPrint('✅ Added: ${medicine['name']}');
    } catch (e) {
      debugPrint('❌ Error adding ${medicine['name']}: $e');
    }
  }
  
  debugPrint('📦 Total medicines inserted: ${medicines.length}');
}

// Add to DatabaseHelper class:
Future<List<MedicineModel>> getAllMedicines() async {
  debugPrint('🔄 Fetching all medicines from database');
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('medicines');
  debugPrint('📊 Found ${maps.length} medicines in database');
  
  return List.generate(maps.length, (i) {
    return MedicineModel.fromMap(maps[i]);
  });
}

Future<List<MedicineModel>> searchMedicines(String query) async {
  debugPrint('🔍 Database search for: $query');
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'medicines',
    where: 'name LIKE ? OR description LIKE ? OR category LIKE ?',
    whereArgs: ['%$query%', '%$query%', '%$query%'],
  );
  
  debugPrint('📊 Found ${maps.length} results in database');
  return List.generate(maps.length, (i) => MedicineModel.fromMap(maps[i]));
}

Future<List<MedicineModel>> getMedicinesByCategory(String category) async {
  debugPrint('🏷️ Fetching medicines for category: $category');
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'medicines',
    where: 'category = ?',
    whereArgs: [category],
  );
  debugPrint('🏷️ Category results: ${maps.length} medicines found');
  
  return List.generate(maps.length, (i) {
    return MedicineModel.fromMap(maps[i]);
  });
}

Future<MedicineModel?> getMedicineById(int id) async {
  debugPrint('🔎 Fetching medicine by ID: $id');
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    'medicines',
    where: 'id = ?',
    whereArgs: [id],
    limit: 1,
  );
  
  if (maps.isEmpty) {
    debugPrint('❌ No medicine found with ID: $id');
    return null;
  }
  
  debugPrint('✅ Found medicine: ${maps.first['name']}');
  return MedicineModel.fromMap(maps.first);
}

}