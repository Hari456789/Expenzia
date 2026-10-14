
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TransactionDatabase {
  TransactionDatabase._();

  static final TransactionDatabase instance =
  TransactionDatabase._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expenzia.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  // CREATE: Add a transaction
  Future<int> insertTransaction(
      Map<String, dynamic> transaction,
      ) async {
    final db = await database;

    return db.insert(
      'transactions',
      transaction,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ: Get all transactions
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;

    return db.query(
      'transactions',
      orderBy: 'id DESC',
    );
  }

  // UPDATE: Edit a transaction
  Future<int> updateTransaction(
      int id,
      Map<String, dynamic> transaction,
      ) async {
    final db = await database;

    return db.update(
      'transactions',
      transaction,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE: Remove a transaction
  Future<int> deleteTransaction(int id) async {
    final db = await database;

    return db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
