// lib/data/local/database_helper.dart
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
    final path = await getDatabasesPath();
    final dbPath = join(path, 'pharmacy.db');
    
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createTables,
    );
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

  Future<void> _insertSampleData(Database db) async {
    // Sample medicines
    await db.insert('medicines', {
      'name': 'Paracetamol',
      'description': 'Pain reliever',
      'price': 120.0,
      'category': 'Pain Relief',
      'requires_prescription': 0,
    });
    
    await db.insert('medicines', {
      'name': 'Vitamin C',
      'description': 'Immune booster',
      'price': 250.0,
      'category': 'Vitamins',
      'requires_prescription': 0,
    });
    
    await db.insert('medicines', {
      'name': 'Amoxicillin',
      'description': 'Antibiotic',
      'price': 180.0,
      'category': 'Antibiotics',
      'requires_prescription': 1,
    });
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

  // Medicine methods
  Future<List<Map<String, dynamic>>> getMedicines() async {
    final db = await database;
    return await db.query('medicines');
  }

  Future<List<Map<String, dynamic>>> searchMedicines(String query) async {
    final db = await database;
    return await db.query(
      'medicines',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );
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
}