import 'time_codec.dart';

enum Sex { female, male, other }

enum Intensity { mild, moderate, intense }

/// Identificador reservado do gatilho "Desconhecido". Não é armazenado no
/// catálogo: uma ocorrência sem gatilhos equivale a "Desconhecido".
const String unknownTriggerId = 'unknown';

abstract class Entity {
  String get id;
  DateTime get createdAt;
  DateTime get updatedAt;
}

class Patient implements Entity {
  const Patient({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.sex,
    required this.condition,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  final String id;
  final String name;
  final DateTime birthDate;
  final Sex sex;
  final String condition;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  int ageInYears([DateTime? now]) {
    final today = now ?? DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  Patient copyWith({
    String? name,
    DateTime? birthDate,
    Sex? sex,
    String? condition,
    DateTime? updatedAt,
  }) => Patient(
    id: id,
    name: name ?? this.name,
    birthDate: birthDate ?? this.birthDate,
    sex: sex ?? this.sex,
    condition: condition ?? this.condition,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'birth_date': TimeCodec.encodeDate(birthDate),
    'sex': sex.name,
    'condition': condition,
    'created_at': TimeCodec.encode(createdAt),
    'updated_at': TimeCodec.encode(updatedAt),
  };

  static Patient fromMap(Map<String, Object?> m) => Patient(
    id: m['id'] as String,
    name: m['name'] as String,
    birthDate: TimeCodec.decodeDate(m['birth_date'] as String),
    sex: Sex.values.byName(m['sex'] as String),
    condition: m['condition'] as String,
    createdAt: TimeCodec.decode(m['created_at'] as String),
    updatedAt: TimeCodec.decode(m['updated_at'] as String),
  );
}

/// Item de catálogo por paciente: gatilho ou medicamento.
class CatalogItem implements Entity {
  const CatalogItem({
    required this.id,
    required this.patientId,
    required this.name,
    required this.active,
    this.defaultDose,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  final String id;
  final String patientId;
  final String name;
  final bool active;

  /// Apenas para medicamentos.
  final String? defaultDose;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  CatalogItem copyWith({
    String? name,
    bool? active,
    String? defaultDose,
    bool clearDefaultDose = false,
    DateTime? updatedAt,
  }) => CatalogItem(
    id: id,
    patientId: patientId,
    name: name ?? this.name,
    active: active ?? this.active,
    defaultDose: clearDefaultDose ? null : (defaultDose ?? this.defaultDose),
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'patient_id': patientId,
    'name': name,
    'active': active ? 1 : 0,
    'default_dose': defaultDose,
    'created_at': TimeCodec.encode(createdAt),
    'updated_at': TimeCodec.encode(updatedAt),
  };

  static CatalogItem fromMap(Map<String, Object?> m) => CatalogItem(
    id: m['id'] as String,
    patientId: m['patient_id'] as String,
    name: m['name'] as String,
    active: (m['active'] as int) == 1,
    defaultDose: m['default_dose'] as String?,
    createdAt: TimeCodec.decode(m['created_at'] as String),
    updatedAt: TimeCodec.decode(m['updated_at'] as String),
  );
}

class Occurrence implements Entity {
  const Occurrence({
    required this.id,
    required this.patientId,
    required this.startedAt,
    this.endedAt,
    required this.intensity,
    required this.triggerIds,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  final String id;
  final String patientId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final Intensity intensity;
  final List<String> triggerIds;
  final String notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  bool get isOngoing => endedAt == null;

  /// Duração até o término ou, se em andamento, até [now].
  Duration duration([DateTime? now]) =>
      (endedAt ?? now ?? DateTime.now()).difference(startedAt);

  Occurrence copyWith({
    DateTime? startedAt,
    DateTime? endedAt,
    bool clearEnd = false,
    Intensity? intensity,
    List<String>? triggerIds,
    String? notes,
    DateTime? updatedAt,
  }) => Occurrence(
    id: id,
    patientId: patientId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: clearEnd ? null : (endedAt ?? this.endedAt),
    intensity: intensity ?? this.intensity,
    triggerIds: triggerIds ?? this.triggerIds,
    notes: notes ?? this.notes,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'patient_id': patientId,
    'started_at': TimeCodec.encode(startedAt),
    'started_at_offset': TimeCodec.offsetMinutes(startedAt),
    'ended_at': endedAt == null ? null : TimeCodec.encode(endedAt!),
    'ended_at_offset': endedAt == null
        ? null
        : TimeCodec.offsetMinutes(endedAt!),
    'intensity': intensity.name,
    'notes': notes,
    'created_at': TimeCodec.encode(createdAt),
    'updated_at': TimeCodec.encode(updatedAt),
  };

  static Occurrence fromMap(Map<String, Object?> m, List<String> triggerIds) =>
      Occurrence(
        id: m['id'] as String,
        patientId: m['patient_id'] as String,
        startedAt: TimeCodec.decode(m['started_at'] as String),
        endedAt: TimeCodec.decodeNullable(m['ended_at'] as String?),
        intensity: Intensity.values.byName(m['intensity'] as String),
        triggerIds: triggerIds,
        notes: (m['notes'] as String?) ?? '',
        createdAt: TimeCodec.decode(m['created_at'] as String),
        updatedAt: TimeCodec.decode(m['updated_at'] as String),
      );
}

class MedicationUse implements Entity {
  const MedicationUse({
    required this.id,
    required this.patientId,
    required this.takenAt,
    required this.medicationId,
    required this.dose,
    this.occurrenceId,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  final String id;
  final String patientId;
  final DateTime takenAt;
  final String medicationId;
  final String dose;
  final String? occurrenceId;
  final String notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  MedicationUse copyWith({
    DateTime? takenAt,
    String? medicationId,
    String? dose,
    String? occurrenceId,
    bool clearOccurrence = false,
    String? notes,
    DateTime? updatedAt,
  }) => MedicationUse(
    id: id,
    patientId: patientId,
    takenAt: takenAt ?? this.takenAt,
    medicationId: medicationId ?? this.medicationId,
    dose: dose ?? this.dose,
    occurrenceId: clearOccurrence ? null : (occurrenceId ?? this.occurrenceId),
    notes: notes ?? this.notes,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'patient_id': patientId,
    'taken_at': TimeCodec.encode(takenAt),
    'taken_at_offset': TimeCodec.offsetMinutes(takenAt),
    'medication_id': medicationId,
    'dose': dose,
    'occurrence_id': occurrenceId,
    'notes': notes,
    'created_at': TimeCodec.encode(createdAt),
    'updated_at': TimeCodec.encode(updatedAt),
  };

  static MedicationUse fromMap(Map<String, Object?> m) => MedicationUse(
    id: m['id'] as String,
    patientId: m['patient_id'] as String,
    takenAt: TimeCodec.decode(m['taken_at'] as String),
    medicationId: m['medication_id'] as String,
    dose: (m['dose'] as String?) ?? '',
    occurrenceId: m['occurrence_id'] as String?,
    notes: (m['notes'] as String?) ?? '',
    createdAt: TimeCodec.decode(m['created_at'] as String),
    updatedAt: TimeCodec.decode(m['updated_at'] as String),
  );
}

/// Evento genérico para a linha do tempo e o calendário.
sealed class TimelineEvent {
  DateTime get at;
}

class OccurrenceEvent extends TimelineEvent {
  OccurrenceEvent(this.occurrence);
  final Occurrence occurrence;
  @override
  DateTime get at => occurrence.startedAt;
}

class MedicationEvent extends TimelineEvent {
  MedicationEvent(this.use);
  final MedicationUse use;
  @override
  DateTime get at => use.takenAt;
}
