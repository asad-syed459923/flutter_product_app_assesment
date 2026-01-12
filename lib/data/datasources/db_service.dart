import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';

class DbService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const boolType = 'INTEGER NOT NULL'; // 0 for false, 1 for true

    // Products Table
    await db.execute('''
    CREATE TABLE ${AppConstants.tableNameProducts} (
      id $intType,
      title $textType,
      description $textType,
      category $textType,
      price $realType,
      discountPercentage $realType,
      rating $realType,
      stock $intType,
      brand $textType,
      thumbnail $textType,
      images $textType,
      availabilityStatus $textType,
      warrantyInformation $textType,
      updatedAt $textType,
      isFavorite $boolType
    )
    ''');
    
    await db.execute('''
    CREATE TABLE ${AppConstants.tableNameFavorites} (
      id $intType PRIMARY KEY,
      title $textType,
      description $textType,
      category $textType,
      price $realType,
      discountPercentage $realType,
      rating $realType,
      stock $intType,
      brand $textType,
      thumbnail $textType,
      images $textType,
      availabilityStatus $textType,
      warrantyInformation $textType,
      updatedAt $textType
    )
    ''');

    // Settings Table for Localization and Theming
    await db.execute('''
    CREATE TABLE settings (
      key $textType PRIMARY KEY,
      value $textType
    )
    ''');
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }
}
