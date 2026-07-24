import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    String path = join(await getDatabasesPath(), 'products.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price TEXT NOT NULL,
        image TEXT
      )
    ''');
  }

  Future<int> insertProduct(Map<String, dynamic> product) async {
    var dbClient = await db;
    return await dbClient.insert('products', product);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    var dbClient = await db;
    return await dbClient.query('products'); // fetch all products
  }
}
