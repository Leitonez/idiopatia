import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/event_tile.dart';
import '../../widgets/formatting.dart';
import '../medications/medication_use_form_screen.dart';
import '../occurrences/occurrence_form_screen.dart';
import '../patients/patients_screen.dart';
import '../settings/export_screen.dart';
import 'history_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final patient = ref.watch(selectedPatientProvider).value;
    return Scaffold(
      appBar: AppBar(titleSpacing: 0, title: const PatientSelectorButton()),
      body: patient == null
          ? EmptyState(
              icon: Icons.person_off_outlined,
              text: l.noPatientSelected,
            )
          : _HomeBody(patient: patient),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.patient});
  final Patient patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final ongoing = ref.watch(ongoingOccurrencesProvider(patient.id));
    final timeline = ref.watch(timelineProvider(patient.id));
    final catalog = ref.watch(catalogByIdProvider(patient.id)).value ?? {};
    final reminder = ref.watch(backupReminderProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (reminder != null) _BackupBanner(reminder: reminder),
        ...?ongoing.value?.map(
          (o) => _OngoingCard(patient: patient, occurrence: o),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: _BigButton(
                  icon: Icons.local_fire_department,
                  label: l.registerCrisis,
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OccurrenceFormScreen(patient: patient),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BigButton(
                  icon: Icons.medication,
                  label: l.registerMedication,
                  color: Theme.of(context).colorScheme.tertiary,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MedicationUseFormScreen(patient: patient),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SectionTitle(
          l.recentEvents,
          trailing: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HistoryScreen(patient: patient),
              ),
            ),
            child: Text(l.showAll),
          ),
        ),
        timeline.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorBox(e),
          data: (events) => events.isEmpty
              ? EmptyState(icon: Icons.event_note_outlined, text: l.noEvents)
              : Column(
                  children: [
                    for (final e in events.take(15))
                      EventTile(event: e, patient: patient, catalog: catalog),
                  ],
                ),
        ),
      ],
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Cartão de crise em andamento com o tempo decorrido atualizado por minuto.
class _OngoingCard extends StatefulWidget {
  const _OngoingCard({required this.patient, required this.occurrence});
  final Patient patient;
  final Occurrence occurrence;

  @override
  State<_OngoingCard> createState() => _OngoingCardState();
}

class _OngoingCardState extends State<_OngoingCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final o = widget.occurrence;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: scheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  l.ongoingCrisis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${l.startedAgo(Fmt.duration(context, o.duration()))} · '
              '${Fmt.dateTime(context, o.startedAt)} · '
              '${Fmt.intensity(context, o.intensity)}',
              style: TextStyle(color: scheme.onErrorContainer),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: Text(l.endCrisis),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OccurrenceFormScreen(
                        patient: widget.patient,
                        occurrence: o,
                        endNow: true,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OccurrenceFormScreen(
                        patient: widget.patient,
                        occurrence: o,
                      ),
                    ),
                  ),
                  child: Text(l.edit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupBanner extends ConsumerWidget {
  const _BackupBanner({required this.reminder});
  final BackupReminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return MaterialBanner(
      leading: const Icon(Icons.backup_outlined),
      content: Text(
        reminder == BackupReminder.never
            ? l.backupReminderNever
            : l.backupReminderStale,
      ),
      actions: [
        TextButton(
          onPressed: () => ref.read(backupReminderProvider.notifier).snooze(),
          child: Text(l.later),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExportScreen()),
          ),
          child: Text(l.exportNow),
        ),
      ],
    );
  }
}
