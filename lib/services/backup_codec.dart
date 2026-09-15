import 'dart:convert';

import '../data/models.dart';
import '../data/repositories.dart';
import '../data/time_codec.dart';

/// Conteúdo de um backup, já decodificado em objetos de domínio.
class BackupData {
  BackupData({
    required this.patients,
    required this.catalogItems,
    required this.catalogKinds,
    required this.occurrences,
    required this.uses,
  });

  final List<Patient> patients;
  final List<CatalogItem> catalogItems;
  final Map<String, CatalogKind> catalogKinds;
  final List<Occurrence> occurrences;
  final List<MedicationUse> uses;
}

class BackupFormatException implements Exception {
  const BackupFormatException(this.message);
  final String message;
  @override
  String toString() => 'BackupFormatException: $message';
}

/// Codifica e decodifica o backup JSON. Formato descrito em
/// docs/FORMATO-EXPORTACAO.md.
class BackupCodec {
  BackupCodec._();

  static const String format = 'idiopatia-backup';
  static const int version = 1;

  static String encode({
    required List<Patient> patients,
    required Map<String, List<CatalogItem>> triggersByPatient,
    required Map<String, List<CatalogItem>> medicationsByPatient,
    required Map<String, List<Occurrence>> occurrencesByPatient,
    required Map<String, List<MedicationUse>> usesByPatient,
    required String appVersion,
    DateTime? exportedAt,
  }) {
    final now = exportedAt ?? DateTime.now();
    final doc = {
      'format': format,
      'version': version,
      'exportedAt': TimeCodec.encode(now),
      'exportedAtOffsetMinutes': TimeCodec.offsetMinutes(now),
      'app': {'name': 'Idiopatia', 'version': appVersion},
      'patients': [
        for (final p in patients)
          {
            'id': p.id,
            'name': p.name,
            'birthDate': TimeCodec.encodeDate(p.birthDate),
            'sex': p.sex.name,
            'condition': p.condition,
            'createdAt': TimeCodec.encode(p.createdAt),
            'updatedAt': TimeCodec.encode(p.updatedAt),
            'triggers': [
              for (final t in triggersByPatient[p.id] ?? const <CatalogItem>[])
                {
                  'id': t.id,
                  'name': t.name,
                  'active': t.active,
                  'createdAt': TimeCodec.encode(t.createdAt),
                  'updatedAt': TimeCodec.encode(t.updatedAt),
                },
            ],
            'medications': [
              for (final m
                  in medicationsByPatient[p.id] ?? const <CatalogItem>[])
                {
                  'id': m.id,
                  'name': m.name,
                  'defaultDose': m.defaultDose,
                  'active': m.active,
                  'createdAt': TimeCodec.encode(m.createdAt),
                  'updatedAt': TimeCodec.encode(m.updatedAt),
                },
            ],
            'occurrences': [
              for (final o
                  in occurrencesByPatient[p.id] ?? const <Occurrence>[])
                {
                  'id': o.id,
                  'startedAt': TimeCodec.encode(o.startedAt),
                  'startedAtOffsetMinutes': TimeCodec.offsetMinutes(
                    o.startedAt,
                  ),
                  'endedAt': o.endedAt == null
                      ? null
                      : TimeCodec.encode(o.endedAt!),
                  'endedAtOffsetMinutes': o.endedAt == null
                      ? null
                      : TimeCodec.offsetMinutes(o.endedAt!),
                  'intensity': o.intensity.name,
                  'triggerIds': o.triggerIds,
                  'notes': o.notes,
                  'createdAt': TimeCodec.encode(o.createdAt),
                  'updatedAt': TimeCodec.encode(o.updatedAt),
                },
            ],
            'medicationUses': [
              for (final u in usesByPatient[p.id] ?? const <MedicationUse>[])
                {
                  'id': u.id,
                  'takenAt': TimeCodec.encode(u.takenAt),
                  'takenAtOffsetMinutes': TimeCodec.offsetMinutes(u.takenAt),
                  'medicationId': u.medicationId,
                  'dose': u.dose,
                  'occurrenceId': u.occurrenceId,
                  'notes': u.notes,
                  'createdAt': TimeCodec.encode(u.createdAt),
                  'updatedAt': TimeCodec.encode(u.updatedAt),
                },
            ],
          },
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(doc);
  }

  static BackupData decode(String json) {
    final Object? root;
    try {
      root = jsonDecode(json);
    } on FormatException {
      throw const BackupFormatException('JSON inválido');
    }
    if (root is! Map<String, dynamic>) {
      throw const BackupFormatException('Raiz não é um objeto');
    }
    if (root['format'] != format) {
      throw const BackupFormatException('Não é um backup do Idiopatia');
    }
    final v = root['version'];
    if (v is! int || v > version) {
      throw BackupFormatException('Versão não suportada: $v');
    }
    final patientsRaw = root['patients'];
    if (patientsRaw is! List) {
      throw const BackupFormatException('Lista de pacientes ausente');
    }

    final patients = <Patient>[];
    final items = <CatalogItem>[];
    final kinds = <String, CatalogKind>{};
    final occurrences = <Occurrence>[];
    final uses = <MedicationUse>[];

    try {
      for (final pr in patientsRaw.cast<Map<String, dynamic>>()) {
        final pid = pr['id'] as String;
        patients.add(
          Patient(
            id: pid,
            name: pr['name'] as String,
            birthDate: TimeCodec.decodeDate(pr['birthDate'] as String),
            sex: Sex.values.byName(pr['sex'] as String),
            condition: pr['condition'] as String,
            createdAt: TimeCodec.decode(pr['createdAt'] as String),
            updatedAt: TimeCodec.decode(pr['updatedAt'] as String),
          ),
        );
        for (final tr
            in (pr['triggers'] as List? ?? const [])
                .cast<Map<String, dynamic>>()) {
          final id = tr['id'] as String;
          kinds[id] = CatalogKind.trigger;
          items.add(
            CatalogItem(
              id: id,
              patientId: pid,
              name: tr['name'] as String,
              active: tr['active'] as bool? ?? true,
              createdAt: TimeCodec.decode(tr['createdAt'] as String),
              updatedAt: TimeCodec.decode(tr['updatedAt'] as String),
            ),
          );
        }
        for (final mr
            in (pr['medications'] as List? ?? const [])
                .cast<Map<String, dynamic>>()) {
          final id = mr['id'] as String;
          kinds[id] = CatalogKind.medication;
          items.add(
            CatalogItem(
              id: id,
              patientId: pid,
              name: mr['name'] as String,
              active: mr['active'] as bool? ?? true,
              defaultDose: mr['defaultDose'] as String?,
              createdAt: TimeCodec.decode(mr['createdAt'] as String),
              updatedAt: TimeCodec.decode(mr['updatedAt'] as String),
            ),
          );
        }
        for (final orr
            in (pr['occurrences'] as List? ?? const [])
                .cast<Map<String, dynamic>>()) {
          occurrences.add(
            Occurrence(
              id: orr['id'] as String,
              patientId: pid,
              startedAt: TimeCodec.decode(orr['startedAt'] as String),
              endedAt: TimeCodec.decodeNullable(orr['endedAt'] as String?),
              intensity: Intensity.values.byName(orr['intensity'] as String),
              triggerIds: (orr['triggerIds'] as List? ?? const [])
                  .cast<String>(),
              notes: orr['notes'] as String? ?? '',
              createdAt: TimeCodec.decode(orr['createdAt'] as String),
              updatedAt: TimeCodec.decode(orr['updatedAt'] as String),
            ),
          );
        }
        for (final ur
            in (pr['medicationUses'] as List? ?? const [])
                .cast<Map<String, dynamic>>()) {
          uses.add(
            MedicationUse(
              id: ur['id'] as String,
              patientId: pid,
              takenAt: TimeCodec.decode(ur['takenAt'] as String),
              medicationId: ur['medicationId'] as String,
              dose: ur['dose'] as String? ?? '',
              occurrenceId: ur['occurrenceId'] as String?,
              notes: ur['notes'] as String? ?? '',
              createdAt: TimeCodec.decode(ur['createdAt'] as String),
              updatedAt: TimeCodec.decode(ur['updatedAt'] as String),
            ),
          );
        }
      }
    } catch (e) {
      if (e is BackupFormatException) rethrow;
      throw BackupFormatException('Campo inválido: $e');
    }

    return BackupData(
      patients: patients,
      catalogItems: items,
      catalogKinds: kinds,
      occurrences: occurrences,
      uses: uses,
    );
  }
}
