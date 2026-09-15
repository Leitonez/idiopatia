import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/event_tile.dart';
import '../../widgets/formatting.dart';

/// Linha do tempo completa do paciente, agrupada por mês.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key, required this.patient});
  final Patient patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final occ = ref.watch(occurrencesProvider(patient.id));
    final uses = ref.watch(medicationUsesProvider(patient.id));
    final catalog = ref.watch(catalogByIdProvider(patient.id)).value ?? {};

    return Scaffold(
      appBar: AppBar(title: Text('${l.history} · ${patient.name}')),
      body: (occ.isLoading || uses.isLoading)
          ? const Center(child: CircularProgressIndicator())
          : Builder(
              builder: (context) {
                final events = <TimelineEvent>[
                  ...?occ.value?.map(OccurrenceEvent.new),
                  ...?uses.value?.map(MedicationEvent.new),
                ]..sort((a, b) => b.at.compareTo(a.at));
                if (events.isEmpty) {
                  return EmptyState(
                    icon: Icons.event_note_outlined,
                    text: l.noEvents,
                  );
                }
                final children = <Widget>[];
                String? currentMonth;
                for (final e in events) {
                  final month = Fmt.monthYear(context, e.at);
                  if (month != currentMonth) {
                    currentMonth = month;
                    children.add(SectionTitle(month));
                  }
                  children.add(
                    EventTile(event: e, patient: patient, catalog: catalog),
                  );
                }
                return ListView(children: children);
              },
            ),
    );
  }
}
