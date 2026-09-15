import 'package:flutter_test/flutter_test.dart';
import 'package:idiopatia/data/models.dart';
import 'package:idiopatia/data/repositories.dart';
import 'package:idiopatia/services/backup_codec.dart';

void main() {
  final created = DateTime(2026, 9, 1, 10);
  final patient = Patient(
    id: 'p1',
    name: 'João',
    birthDate: DateTime(2018, 5, 1),
    sex: Sex.male,
    condition: 'Hiperidrose',
    createdAt: created,
    updatedAt: created,
  );
  final heat = CatalogItem(
    id: 't1',
    patientId: 'p1',
    name: 'Calor',
    active: true,
    createdAt: created,
    updatedAt: created,
  );
  final med = CatalogItem(
    id: 'm1',
    patientId: 'p1',
    name: 'Remédio',
    active: false,
    defaultDose: '10 mg',
    createdAt: created,
    updatedAt: created,
  );
  final o = Occurrence(
    id: 'o1',
    patientId: 'p1',
    startedAt: DateTime(2026, 9, 10, 22, 30),
    endedAt: DateTime(2026, 9, 11, 10, 15),
    intensity: Intensity.intense,
    triggerIds: const ['t1'],
    notes: 'Noite quente; "aspas" e\nquebra de linha',
    createdAt: created,
    updatedAt: created,
  );
  final u = MedicationUse(
    id: 'u1',
    patientId: 'p1',
    takenAt: DateTime(2026, 9, 10, 23),
    medicationId: 'm1',
    dose: '10 mg',
    occurrenceId: 'o1',
    notes: '',
    createdAt: created,
    updatedAt: created,
  );

  test('ida e volta preserva todos os campos', () {
    final json = BackupCodec.encode(
      patients: [patient],
      triggersByPatient: {
        'p1': [heat],
      },
      medicationsByPatient: {
        'p1': [med],
      },
      occurrencesByPatient: {
        'p1': [o],
      },
      usesByPatient: {
        'p1': [u],
      },
      appVersion: '1.0.0',
      exportedAt: DateTime(2026, 9, 14, 21),
    );
    expect(json, contains('"format": "idiopatia-backup"'));
    final data = BackupCodec.decode(json);

    expect(data.patients.single.name, 'João');
    expect(data.patients.single.birthDate, DateTime(2018, 5, 1));
    expect(data.patients.single.sex, Sex.male);
    expect(data.catalogKinds, {
      't1': CatalogKind.trigger,
      'm1': CatalogKind.medication,
    });
    final m = data.catalogItems.firstWhere((c) => c.id == 'm1');
    expect(m.defaultDose, '10 mg');
    expect(m.active, isFalse);
    final oo = data.occurrences.single;
    expect(oo.startedAt, o.startedAt);
    expect(oo.endedAt, o.endedAt);
    expect(oo.intensity, Intensity.intense);
    expect(oo.triggerIds, ['t1']);
    expect(oo.notes, o.notes);
    final uu = data.uses.single;
    expect(uu.occurrenceId, 'o1');
    expect(uu.medicationId, 'm1');
  });

  test('rejeita arquivos que não são backup', () {
    expect(
      () => BackupCodec.decode('{}'),
      throwsA(isA<BackupFormatException>()),
    );
    expect(
      () => BackupCodec.decode('não é json'),
      throwsA(isA<BackupFormatException>()),
    );
    expect(
      () => BackupCodec.decode(
        '{"format":"idiopatia-backup","version":99,"patients":[]}',
      ),
      throwsA(isA<BackupFormatException>()),
    );
  });
}
