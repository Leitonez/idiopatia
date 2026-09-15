import 'package:flutter_test/flutter_test.dart';
import 'package:idiopatia/data/database.dart';
import 'package:idiopatia/data/models.dart';
import 'package:idiopatia/data/repositories.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/open.dart';

import 'dart:ffi';

void main() {
  late AppDatabase db;
  late Repository repo;

  setUpAll(() {
    // Em Linux de desenvolvimento só existe libsqlite3.so.0, sem o link .so.
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
  });

  setUp(() async {
    db = await AppDatabase.open(inMemoryDatabasePath);
    repo = Repository(db);
  });

  tearDown(() => db.close());

  Future<Patient> newPatient([String name = 'Ana']) => repo.createPatient(
    name: name,
    birthDate: DateTime(2018, 5, 1),
    sex: Sex.female,
    condition: 'Hiperidrose craniofacial',
  );

  test('cria, lista, edita e exclui paciente', () async {
    final p = await newPatient();
    expect((await repo.listPatients()).map((e) => e.id), [p.id]);

    await repo.updatePatient(p.copyWith(name: 'Ana Maria'));
    expect((await repo.getPatient(p.id))!.name, 'Ana Maria');

    await repo.deletePatient(p.id);
    expect(await repo.listPatients(), isEmpty);
  });

  test('catálogo rejeita nome duplicado ignorando maiúsculas', () async {
    final p = await newPatient();
    await repo.createCatalogItem(
      patientId: p.id,
      kind: CatalogKind.trigger,
      name: 'Calor',
    );
    expect(
      () => repo.createCatalogItem(
        patientId: p.id,
        kind: CatalogKind.trigger,
        name: 'calor',
      ),
      throwsA(isA<DuplicateNameException>()),
    );
    // Mesmo nome em outro tipo é permitido.
    await repo.createCatalogItem(
      patientId: p.id,
      kind: CatalogKind.medication,
      name: 'Calor',
    );
    expect(await repo.listCatalog(p.id, CatalogKind.trigger), hasLength(1));
    expect(await repo.listCatalog(p.id, CatalogKind.medication), hasLength(1));
  });

  test('ocorrência guarda gatilhos e preserva hora local', () async {
    final p = await newPatient();
    final heat = await repo.createCatalogItem(
      patientId: p.id,
      kind: CatalogKind.trigger,
      name: 'Calor',
    );
    final start = DateTime(2026, 9, 10, 22, 30);
    final o = await repo.createOccurrence(
      patientId: p.id,
      startedAt: start,
      intensity: Intensity.moderate,
      triggerIds: [heat.id, heat.id],
    );
    final list = await repo.listOccurrences(p.id);
    expect(list.single.id, o.id);
    expect(list.single.startedAt, start);
    expect(list.single.triggerIds, [heat.id]);
    expect(list.single.isOngoing, isTrue);
    expect(await repo.listOngoingOccurrences(p.id), hasLength(1));

    final end = DateTime(2026, 9, 11, 10, 15);
    await repo.updateOccurrence(
      list.single.copyWith(
        endedAt: end,
        triggerIds: const [],
        intensity: Intensity.intense,
      ),
    );
    final updated = (await repo.getOccurrence(o.id))!;
    expect(updated.endedAt, end);
    expect(updated.duration(), const Duration(hours: 11, minutes: 45));
    expect(updated.triggerIds, isEmpty);
    expect(await repo.listOngoingOccurrences(p.id), isEmpty);
  });

  test('filtro por período usa o início da ocorrência', () async {
    final p = await newPatient();
    for (final day in [1, 10, 20]) {
      await repo.createOccurrence(
        patientId: p.id,
        startedAt: DateTime(2026, 9, day, 8),
        endedAt: DateTime(2026, 9, day, 20),
        intensity: Intensity.mild,
        triggerIds: const [],
      );
    }
    final mid = await repo.listOccurrences(
      p.id,
      from: DateTime(2026, 9, 5),
      to: DateTime(2026, 9, 15),
    );
    expect(mid.map((o) => o.startedAt.day), [10]);
  });

  test(
    'uso de medicamento vincula à crise e perde o vínculo se ela for excluída',
    () async {
      final p = await newPatient();
      final med = await repo.createCatalogItem(
        patientId: p.id,
        kind: CatalogKind.medication,
        name: 'Remédio',
        defaultDose: '10 mg',
      );
      final o = await repo.createOccurrence(
        patientId: p.id,
        startedAt: DateTime(2026, 9, 10, 22),
        intensity: Intensity.mild,
        triggerIds: const [],
      );
      final u = await repo.createMedicationUse(
        patientId: p.id,
        takenAt: DateTime(2026, 9, 10, 23),
        medicationId: med.id,
        dose: '10 mg',
        occurrenceId: o.id,
      );
      expect((await repo.listMedicationUses(p.id)).single.occurrenceId, o.id);
      expect(await repo.catalogItemUsageCount(med.id), 1);

      await repo.deleteOccurrence(o.id);
      final after = (await repo.listMedicationUses(p.id)).single;
      expect(after.id, u.id);
      expect(after.occurrenceId, isNull);
    },
  );

  test('linha do tempo mistura eventos em ordem decrescente', () async {
    final p = await newPatient();
    final med = await repo.createCatalogItem(
      patientId: p.id,
      kind: CatalogKind.medication,
      name: 'M',
    );
    await repo.createOccurrence(
      patientId: p.id,
      startedAt: DateTime(2026, 9, 1, 8),
      intensity: Intensity.mild,
      triggerIds: const [],
    );
    await repo.createMedicationUse(
      patientId: p.id,
      takenAt: DateTime(2026, 9, 2, 8),
      medicationId: med.id,
      dose: '1',
    );
    final t = await repo.timeline(p.id);
    expect(t.first, isA<MedicationEvent>());
    expect(t.last, isA<OccurrenceEvent>());
    expect(await repo.hasAnyData(), isTrue);
  });

  test('excluir paciente apaga tudo em cascata', () async {
    final p = await newPatient();
    final med = await repo.createCatalogItem(
      patientId: p.id,
      kind: CatalogKind.medication,
      name: 'M',
    );
    await repo.createOccurrence(
      patientId: p.id,
      startedAt: DateTime(2026, 9, 1, 8),
      intensity: Intensity.mild,
      triggerIds: const [],
    );
    await repo.createMedicationUse(
      patientId: p.id,
      takenAt: DateTime(2026, 9, 2, 8),
      medicationId: med.id,
      dose: '1',
    );
    await repo.deletePatient(p.id);
    expect(await repo.hasAnyData(), isFalse);
  });

  test('importação não duplica e só substitui se mais recente', () async {
    final p = await newPatient();
    final older = p.copyWith(
      name: 'Antigo',
      updatedAt: p.updatedAt.subtract(const Duration(days: 1)),
    );
    final newer = p.copyWith(
      name: 'Novo',
      updatedAt: p.updatedAt.add(const Duration(days: 1)),
    );

    var r = await repo.importAll(
      patients: [older],
      catalogKinds: const {},
      catalogItems: const [],
      occurrences: const [],
      uses: const [],
    );
    expect(r.skipped, 1);
    expect((await repo.getPatient(p.id))!.name, 'Ana');

    r = await repo.importAll(
      patients: [newer],
      catalogKinds: const {},
      catalogItems: const [],
      occurrences: const [],
      uses: const [],
    );
    expect(r.patients, 1);
    expect((await repo.getPatient(p.id))!.name, 'Novo');
    expect(await repo.listPatients(), hasLength(1));
  });
}
