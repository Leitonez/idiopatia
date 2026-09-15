import 'package:flutter/material.dart';

import '../data/models.dart';
import '../features/medications/medication_use_form_screen.dart';
import '../features/occurrences/occurrence_form_screen.dart';
import 'formatting.dart';

/// Linha da linha do tempo para uma crise ou um uso de medicamento.
/// Toque abre a edição.
class EventTile extends StatelessWidget {
  const EventTile({
    super.key,
    required this.event,
    required this.patient,
    required this.catalog,
  });

  final TimelineEvent event;
  final Patient patient;
  final Map<String, CatalogItem> catalog;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    switch (event) {
      case OccurrenceEvent(:final occurrence):
        final o = occurrence;
        final color = Fmt.intensityColor(o.intensity, scheme);
        final triggers = o.triggerIds.isEmpty
            ? l.unknownTrigger
            : o.triggerIds.map((id) => catalog[id]?.name ?? '?').join(', ');
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.18),
            child: Icon(Icons.local_fire_department, color: color),
          ),
          title: Text(
            '${l.crisis} · ${Fmt.intensity(context, o.intensity)}'
            '${o.isOngoing ? ' · ${l.ongoing}' : ''}',
          ),
          subtitle: Text(
            '${Fmt.dateTime(context, o.startedAt)}'
            '${o.isOngoing ? '' : ' → ${Fmt.duration(context, o.duration())}'}'
            '\n${l.triggers}: $triggers',
          ),
          isThreeLine: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  OccurrenceFormScreen(patient: patient, occurrence: o),
            ),
          ),
        );
      case MedicationEvent(:final use):
        final u = use;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: scheme.secondaryContainer,
            child: Icon(Icons.medication, color: scheme.onSecondaryContainer),
          ),
          title: Text(catalog[u.medicationId]?.name ?? l.medication),
          subtitle: Text('${Fmt.dateTime(context, u.takenAt)} · ${u.dose}'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MedicationUseFormScreen(patient: patient, use: u),
            ),
          ),
        );
    }
  }
}
