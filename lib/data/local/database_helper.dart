// lib/data/local/database_helper.dart
import 'package:flutter/foundation.dart';
import 'package:pharmacy_app/models/medicine_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
  try {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'pharmacy.db');
    
    debugPrint('📁 Database path: $dbPath');
    
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createTables,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
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
        password TEXT
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
        medicine_id INTEGER,
        quantity INTEGER,
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
  Future<int> addToCart(int medicineId, int quantity) async {
    final db = await database;
    return await db.insert('cart', {
      'medicine_id': medicineId,
      'quantity': quantity,
      'added_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT cart.*, medicines.name, medicines.price 
      FROM cart 
      JOIN medicines ON cart.medicine_id = medicines.id
    ''');
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
Future<int> registerUser(String name, String email, String phone, String password) async {
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
      'image_url': 'assets/medicines/paracetamol.jpg',
      'stock': 40,
    },
    {
      'name': 'Omeprazole 20mg',
      'description': 'Acid reflux medicine',
      'price': 4800,
      'category': 'Gastrointestinal',
      'requires_prescription': 0,
      'image_url': 'assets/medicines/paracetamol.jpg',
      'stock': 25,
    },
    {
      'name': 'Metformin 500mg',
      'description': 'Diabetes medication',
      'price': 2000,
      'category': 'Diabetes',
      'requires_prescription': 1,
      'image_url': 'assets/medicines/paracetamol.jpg',
      'stock': 15,
    },
    {
      'name': 'Aspirin 75mg',
      'description': 'Blood thinner and pain relief',
      'price': 2500,
      'category': 'Cardiac',
      'requires_prescription': 0,
      'image_url': 'assets/medicines/paracetamol.jpg',
      'stock': 35,
    },
    {
      'name': 'Ibuprofen 400mg',
      'description': 'Anti-inflammatory painkiller',
      'price': 1500,
      'category': 'Pain Relief',
      'requires_prescription': 0,
      'image_url': 'assets/medicines/paracetamol.jpg',
      'stock': 45,
    },
    {
      'name': 'Multivitamin Tablets',
      'description': 'Daily essential vitamins',
      'price': 1000,
      'category': 'Vitamins',
      'requires_prescription': 0,
      'image_url': 'assets/medicines/paracetamol.jpg',
      'stock': 60,
    },
    {
      'name': 'Diazepam 5mg',
      'description': 'For anxiety and muscle spasms',
      'price': 1000,
      'category': 'Neuro',
      'requires_prescription': 1,
      'image_url': 'assets/medicines/paracetamol.jpg',
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