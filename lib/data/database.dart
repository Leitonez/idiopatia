import 'package:sqflite/sqflite.dart';

/// Abre e migra o banco SQLite local. Todo o dado do app vive aqui.
class AppDatabase {
  AppDatabase._(this.db);

  final Database db;

  static const int schemaVersion = 1;

  static Future<AppDatabase> open(String path) async {
    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _create,
      ),
    );
    return AppDatabase._(db);
  }

  static Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        birth_date TEXT NOT NULL,
        sex TEXT NOT NULL,
        condition TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE catalog_items (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
        kind TEXT NOT NULL,
        name TEXT NOT NULL,
        active INTEGER NOT NULL DEFAULT 1,
        default_dose TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE (patient_id, kind, name COLLATE NOCASE)
      )''');
    await db.execute('''
      CREATE TABLE occurrences (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
        started_at TEXT NOT NULL,
        started_at_offset INTEGER NOT NULL,
        ended_at TEXT,
        ended_at_offset INTEGER,
        intensity TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )''');
    await db.execute(
      'CREATE INDEX idx_occurrences_patient_start ON occurrences(patient_id, started_at)',
    );
    await db.execute('''
      CREATE TABLE occurrence_triggers (
        occurrence_id TEXT NOT NULL REFERENCES occurrences(id) ON DELETE CASCADE,
        trigger_id TEXT NOT NULL REFERENCES catalog_items(id) ON DELETE CASCADE,
        PRIMARY KEY (occurrence_id, trigger_id)
      )''');
    await db.execute('''
      CREATE TABLE medication_uses (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
        taken_at TEXT NOT NULL,
        taken_at_offset INTEGER NOT NULL,
        medication_id TEXT NOT NULL REFERENCES catalog_items(id),
        dose TEXT NOT NULL DEFAULT '',
        occurrence_id TEXT REFERENCES occurrences(id) ON DELETE SET NULL,
        notes TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )''');
    await db.execute(
      'CREATE INDEX idx_uses_patient_taken ON medication_uses(patient_id, taken_at)',
    );
  }

  /// Apaga todos os dados, mantendo o esquema.
  Future<void> eraseAll() async {
    await db.transaction((txn) async {
      await txn.delete('medication_uses');
      await txn.delete('occurrence_triggers');
      await txn.delete('occurrences');
      await txn.delete('catalog_items');
      await txn.delete('patients');
    });
  }

  Future<void> close() => db.close();
}
