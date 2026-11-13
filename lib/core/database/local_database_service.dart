import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:gtc6/features/journal/domain/models/journal_note.dart';

/// Singleton service that manages the local SQLite database (`gtc6_local.db`).
class LocalDatabaseService {
  LocalDatabaseService._internal();
  static final LocalDatabaseService instance = LocalDatabaseService._internal();

  static const String _dbName = 'gtc6_local.db';
  static const int _dbVersion = 1;
  static const String journalNotesTable = 'journal_notes';

  Database? _db;

  /// Returns the open database instance, initializing it lazily if needed.
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = p.join(databasesPath, _dbName);

    return openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $journalNotesTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            mood TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE INDEX idx_journal_notes_updated_at
          ON $journalNotesTable (updated_at DESC)
        ''');
      },
    );
  }

  // ── Journal Notes CRUD ────────────────────────────────────────────────────

  Future<List<JournalNote>> getAllNotes() async {
    final db = await database;
    final rows = await db.query(journalNotesTable, orderBy: 'updated_at DESC');
    return rows.map(JournalNote.fromMap).toList();
  }

  Future<int> insertNote(JournalNote note) async {
    final db = await database;
    return db.insert(
      journalNotesTable,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateNote(JournalNote note) async {
    if (note.id == null) return 0;
    final db = await database;
    return db.update(
      journalNotesTable,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return db.delete(journalNotesTable, where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes all notes from the local journal table (full reset).
  Future<int> deleteAllNotes() async {
    final db = await database;
    return db.delete(journalNotesTable);
  }
}
