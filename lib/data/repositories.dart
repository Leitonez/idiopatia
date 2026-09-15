import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'database.dart';
import 'models.dart';
import 'time_codec.dart';

const _uuid = Uuid();

String newId() => _uuid.v4();

enum CatalogKind { trigger, medication }

class DuplicateNameException implements Exception {
  const DuplicateNameException();
}

/// Resultado de uma importação.
class ImportResult {
  int patients = 0;
  int catalogItems = 0;
  int occurrences = 0;
  int uses = 0;
  int skipped = 0;
}

/// Acesso a dados. Uma única classe para manter o app simples; os métodos
/// estão agrupados por entidade.
class Repository {
  Repository(this._appDb);

  final AppDatabase _appDb;
  Database get _db => _appDb.db;

  // ---------------------------------------------------------------- pacientes

  Future<List<Patient>> listPatients() async {
    final rows = await _db.query('patients', orderBy: 'name COLLATE NOCASE');
    return rows.map(Patient.fromMap).toList();
  }

  Future<Patient?> getPatient(String id) async {
    final rows = await _db.query('patients', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Patient.fromMap(rows.first);
  }

  Future<Patient> createPatient({
    required String name,
    required DateTime birthDate,
    required Sex sex,
    required String condition,
  }) async {
    final now = DateTime.now();
    final p = Patient(
      id: newId(),
      name: name.trim(),
      birthDate: birthDate,
      sex: sex,
      condition: condition.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _db.insert('patients', p.toMap());
    return p;
  }

  Future<void> updatePatient(Patient p) async {
    final updated = p.copyWith(updatedAt: DateTime.now());
    await _db.update(
      'patients',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );
  }

  Future<void> deletePatient(String id) async {
    await _db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------- catálogos

  Future<List<CatalogItem>> listCatalog(
    String patientId,
    CatalogKind kind, {
    bool onlyActive = false,
  }) async {
    final rows = await _db.query(
      'catalog_items',
      where:
          'patient_id = ? AND kind = ?${onlyActive ? ' AND active = 1' : ''}',
      whereArgs: [patientId, kind.name],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(CatalogItem.fromMap).toList();
  }

  Future<Map<String, CatalogItem>> catalogById(String patientId) async {
    final rows = await _db.query(
      'catalog_items',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
    return {for (final r in rows) r['id'] as String: CatalogItem.fromMap(r)};
  }

  Future<CatalogItem> createCatalogItem({
    required String patientId,
    required CatalogKind kind,
    required String name,
    String? defaultDose,
  }) async {
    final now = DateTime.now();
    final item = CatalogItem(
      id: newId(),
      patientId: patientId,
      name: name.trim(),
      active: true,
      defaultDose: _emptyToNull(defaultDose),
      createdAt: now,
      updatedAt: now,
    );
    try {
      await _db.insert('catalog_items', {...item.toMap(), 'kind': kind.name});
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) throw const DuplicateNameException();
      rethrow;
    }
    return item;
  }

  Future<void> updateCatalogItem(CatalogItem item) async {
    final updated = item.copyWith(updatedAt: DateTime.now());
    try {
      await _db.update(
        'catalog_items',
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) throw const DuplicateNameException();
      rethrow;
    }
  }

  /// Quantos registros referenciam o item. Itens usados não podem ser
  /// excluídos, apenas desativados.
  Future<int> catalogItemUsageCount(String itemId) async {
    final t = Sqflite.firstIntValue(
      await _db.rawQuery(
        'SELECT COUNT(*) FROM occurrence_triggers WHERE trigger_id = ?',
        [itemId],
      ),
    )!;
    final m = Sqflite.firstIntValue(
      await _db.rawQuery(
        'SELECT COUNT(*) FROM medication_uses WHERE medication_id = ?',
        [itemId],
      ),
    )!;
    return t + m;
  }

  Future<void> deleteCatalogItem(String itemId) async {
    await _db.delete('catalog_items', where: 'id = ?', whereArgs: [itemId]);
  }

  // -------------------------------------------------------------- ocorrências

  Future<List<Occurrence>> listOccurrences(
    String patientId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final where = StringBuffer('patient_id = ?');
    final args = <Object?>[patientId];
    if (from != null) {
      where.write(' AND started_at >= ?');
      args.add(TimeCodec.encode(from));
    }
    if (to != null) {
      where.write(' AND started_at < ?');
      args.add(TimeCodec.encode(to));
    }
    final rows = await _db.query(
      'occurrences',
      where: where.toString(),
      whereArgs: args,
      orderBy: 'started_at DESC',
    );
    return _attachTriggers(rows);
  }

  Future<List<Occurrence>> listOngoingOccurrences(String patientId) async {
    final rows = await _db.query(
      'occurrences',
      where: 'patient_id = ? AND ended_at IS NULL',
      whereArgs: [patientId],
      orderBy: 'started_at DESC',
    );
    return _attachTriggers(rows);
  }

  Future<Occurrence?> getOccurrence(String id) async {
    final rows = await _db.query(
      'occurrences',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return (await _attachTriggers(rows)).first;
  }

  Future<List<Occurrence>> _attachTriggers(
    List<Map<String, Object?>> rows,
  ) async {
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r['id'] as String).toList();
    final placeholders = List.filled(ids.length, '?').join(',');
    final links = await _db.query(
      'occurrence_triggers',
      where: 'occurrence_id IN ($placeholders)',
      whereArgs: ids,
    );
    final byOcc = <String, List<String>>{};
    for (final l in links) {
      byOcc
          .putIfAbsent(l['occurrence_id'] as String, () => [])
          .add(l['trigger_id'] as String);
    }
    return rows
        .map((r) => Occurrence.fromMap(r, byOcc[r['id'] as String] ?? const []))
        .toList();
  }

  Future<Occurrence> createOccurrence({
    required String patientId,
    required DateTime startedAt,
    DateTime? endedAt,
    required Intensity intensity,
    required List<String> triggerIds,
    String notes = '',
  }) async {
    final now = DateTime.now();
    final o = Occurrence(
      id: newId(),
      patientId: patientId,
      startedAt: startedAt,
      endedAt: endedAt,
      intensity: intensity,
      triggerIds: triggerIds,
      notes: notes.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _db.transaction((txn) async {
      await txn.insert('occurrences', o.toMap());
      await _writeTriggers(txn, o);
    });
    return o;
  }

  Future<void> updateOccurrence(Occurrence o) async {
    final updated = o.copyWith(updatedAt: DateTime.now());
    await _db.transaction((txn) async {
      await txn.update(
        'occurrences',
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [o.id],
      );
      await txn.delete(
        'occurrence_triggers',
        where: 'occurrence_id = ?',
        whereArgs: [o.id],
      );
      await _writeTriggers(txn, updated);
    });
  }

  Future<void> _writeTriggers(DatabaseExecutor txn, Occurrence o) async {
    for (final t in o.triggerIds.toSet()) {
      await txn.insert('occurrence_triggers', {
        'occurrence_id': o.id,
        'trigger_id': t,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> deleteOccurrence(String id) async {
    await _db.delete('occurrences', where: 'id = ?', whereArgs: [id]);
  }

  // -------------------------------------------------------------- medicamentos

  Future<List<MedicationUse>> listMedicationUses(
    String patientId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final where = StringBuffer('patient_id = ?');
    final args = <Object?>[patientId];
    if (from != null) {
      where.write(' AND taken_at >= ?');
      args.add(TimeCodec.encode(from));
    }
    if (to != null) {
      where.write(' AND taken_at < ?');
      args.add(TimeCodec.encode(to));
    }
    final rows = await _db.query(
      'medication_uses',
      where: where.toString(),
      whereArgs: args,
      orderBy: 'taken_at DESC',
    );
    return rows.map(MedicationUse.fromMap).toList();
  }

  Future<MedicationUse> createMedicationUse({
    required String patientId,
    required DateTime takenAt,
    required String medicationId,
    required String dose,
    String? occurrenceId,
    String notes = '',
  }) async {
    final now = DateTime.now();
    final u = MedicationUse(
      id: newId(),
      patientId: patientId,
      takenAt: takenAt,
      medicationId: medicationId,
      dose: dose.trim(),
      occurrenceId: occurrenceId,
      notes: notes.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _db.insert('medication_uses', u.toMap());
    return u;
  }

  Future<void> updateMedicationUse(MedicationUse u) async {
    final updated = u.copyWith(updatedAt: DateTime.now());
    await _db.update(
      'medication_uses',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [u.id],
    );
  }

  Future<void> deleteMedicationUse(String id) async {
    await _db.delete('medication_uses', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------------------------------------------------- linha do tempo

  Future<List<TimelineEvent>> timeline(
    String patientId, {
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    final occ = await listOccurrences(patientId, from: from, to: to);
    final uses = await listMedicationUses(patientId, from: from, to: to);
    final events = <TimelineEvent>[
      ...occ.map(OccurrenceEvent.new),
      ...uses.map(MedicationEvent.new),
    ]..sort((a, b) => b.at.compareTo(a.at));
    if (limit != null && events.length > limit) return events.sublist(0, limit);
    return events;
  }

  Future<bool> hasAnyData() async {
    final n = Sqflite.firstIntValue(
      await _db.rawQuery(
        'SELECT (SELECT COUNT(*) FROM occurrences) + (SELECT COUNT(*) FROM medication_uses)',
      ),
    )!;
    return n > 0;
  }

  // ------------------------------------------------------------- importação

  /// Insere ou atualiza registros vindos de um backup. Registros existentes
  /// só são substituídos se a versão importada for mais recente.
  Future<ImportResult> importAll({
    required List<Patient> patients,
    required Map<String, CatalogKind> catalogKinds,
    required List<CatalogItem> catalogItems,
    required List<Occurrence> occurrences,
    required List<MedicationUse> uses,
  }) async {
    final result = ImportResult();
    await _db.transaction((txn) async {
      for (final p in patients) {
        if (await _upsert(txn, 'patients', p.toMap(), p.updatedAt)) {
          result.patients++;
        } else {
          result.skipped++;
        }
      }
      for (final c in catalogItems) {
        final map = {...c.toMap(), 'kind': catalogKinds[c.id]!.name};
        if (await _upsert(txn, 'catalog_items', map, c.updatedAt)) {
          result.catalogItems++;
        } else {
          result.skipped++;
        }
      }
      for (final o in occurrences) {
        if (await _upsert(txn, 'occurrences', o.toMap(), o.updatedAt)) {
          await txn.delete(
            'occurrence_triggers',
            where: 'occurrence_id = ?',
            whereArgs: [o.id],
          );
          await _writeTriggers(txn, o);
          result.occurrences++;
        } else {
          result.skipped++;
        }
      }
      for (final u in uses) {
        if (await _upsert(txn, 'medication_uses', u.toMap(), u.updatedAt)) {
          result.uses++;
        } else {
          result.skipped++;
        }
      }
    });
    return result;
  }

  Future<bool> _upsert(
    DatabaseExecutor txn,
    String table,
    Map<String, Object?> map,
    DateTime updatedAt,
  ) async {
    final existing = await txn.query(
      table,
      columns: ['updated_at'],
      where: 'id = ?',
      whereArgs: [map['id']],
    );
    if (existing.isNotEmpty) {
      final current = TimeCodec.decode(existing.first['updated_at'] as String);
      if (!updatedAt.isAfter(current)) return false;
      await txn.update(table, map, where: 'id = ?', whereArgs: [map['id']]);
      return true;
    }
    await txn.insert(table, map);
    return true;
  }

  Future<void> eraseAll() => _appDb.eraseAll();
}

String? _emptyToNull(String? s) {
  final t = s?.trim();
  return t == null || t.isEmpty ? null : t;
}
