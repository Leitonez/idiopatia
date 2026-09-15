import '../data/models.dart';
import 'report_strings.dart';

/// Gera CSV com separador ";" e BOM UTF-8, para abrir direto no Excel em
/// português. Uma linha por evento (crise ou medicamento).
class CsvExporter {
  CsvExporter._();

  static String build({
    required List<Occurrence> occurrences,
    required List<MedicationUse> uses,
    required Map<String, CatalogItem> catalog,
    required ReportStrings s,
  }) {
    final rows = <List<String>>[
      [
        s.type,
        s.start,
        s.end,
        s.duration,
        s.intensity,
        s.triggers,
        s.medication,
        s.dose,
        s.linkedCrisis,
        s.notes,
      ],
    ];
    final events = <TimelineEvent>[
      ...occurrences.map(OccurrenceEvent.new),
      ...uses.map(MedicationEvent.new),
    ]..sort((a, b) => a.at.compareTo(b.at));

    for (final e in events) {
      switch (e) {
        case OccurrenceEvent(:final occurrence):
          final o = occurrence;
          rows.add([
            s.crisis,
            s.formatDateTime(o.startedAt),
            o.endedAt == null ? s.ongoing : s.formatDateTime(o.endedAt!),
            o.endedAt == null ? '' : s.formatDuration(o.duration()),
            s.intensityLabel(o.intensity),
            triggerNames(o, catalog, s),
            '',
            '',
            '',
            o.notes,
          ]);
        case MedicationEvent(:final use):
          final u = use;
          rows.add([
            s.medication,
            s.formatDateTime(u.takenAt),
            '',
            '',
            '',
            '',
            catalog[u.medicationId]?.name ?? u.medicationId,
            u.dose,
            u.occurrenceId == null ? '' : _linkedLabel(u, occurrences, s),
            u.notes,
          ]);
      }
    }
    final buf = StringBuffer('﻿');
    for (final r in rows) {
      buf.writeln(r.map(_escape).join(';'));
    }
    return buf.toString();
  }

  static String triggerNames(
    Occurrence o,
    Map<String, CatalogItem> catalog,
    ReportStrings s,
  ) {
    if (o.triggerIds.isEmpty) return s.unknownTrigger;
    return o.triggerIds.map((id) => catalog[id]?.name ?? id).join(', ');
  }

  static String _linkedLabel(
    MedicationUse u,
    List<Occurrence> occurrences,
    ReportStrings s,
  ) {
    for (final o in occurrences) {
      if (o.id == u.occurrenceId) return s.formatDateTime(o.startedAt);
    }
    return '';
  }

  static String _escape(String v) {
    if (v.contains(';') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }
}
