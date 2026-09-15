import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../services/stats.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/formatting.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  SummaryPeriod _period = SummaryPeriod.last90Days;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final patient = ref.watch(selectedPatientProvider).value;
    if (patient == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.summary)),
        body: EmptyState(
          icon: Icons.person_off_outlined,
          text: l.noPatientSelected,
        ),
      );
    }
    final occAsync = ref.watch(occurrencesProvider(patient.id));
    final usesAsync = ref.watch(medicationUsesProvider(patient.id));
    final catalog = ref.watch(catalogByIdProvider(patient.id)).value ?? {};

    final now = DateTime.now();
    final from = _period.startFrom(now);
    final occ = (occAsync.value ?? const <Occurrence>[])
        .where((o) => from == null || !o.startedAt.isBefore(from))
        .toList();
    final uses = (usesAsync.value ?? const <MedicationUse>[])
        .where((u) => from == null || !u.takenAt.isBefore(from))
        .toList();
    final stats = SummaryStats.compute(occurrences: occ, uses: uses, now: now);

    return Scaffold(
      appBar: AppBar(title: Text('${l.summary} · ${patient.name}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SegmentedButton<SummaryPeriod>(
            segments: [
              for (final p in SummaryPeriod.values)
                ButtonSegment(value: p, label: Text(Fmt.period(context, p))),
            ],
            selected: {_period},
            onSelectionChanged: (s) => setState(() => _period = s.first),
          ),
          const SizedBox(height: 16),
          if (occAsync.isLoading || usesAsync.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (occ.isEmpty && uses.isEmpty)
            EmptyState(icon: Icons.insights_outlined, text: l.noDataPeriod)
          else ...[
            _StatGrid(
              children: [
                _Stat(
                  label: l.crisesCount,
                  value: '${stats.occurrenceCount}',
                  hint: stats.ongoingCount > 0
                      ? l.ongoingCount(stats.ongoingCount)
                      : null,
                ),
                _Stat(
                  label: l.daysSinceLast,
                  value: stats.daysSinceLast == null
                      ? '–'
                      : '${stats.daysSinceLast}',
                ),
                _Stat(
                  label: l.averageDuration,
                  value: stats.averageDuration == null
                      ? '–'
                      : Fmt.duration(context, stats.averageDuration!),
                ),
                _Stat(
                  label: l.maxDuration,
                  value: stats.maxDuration == null
                      ? '–'
                      : Fmt.duration(context, stats.maxDuration!),
                ),
                _Stat(
                  label: l.averageInterval,
                  value: stats.averageInterval == null
                      ? '–'
                      : l.daysCount(stats.averageInterval!.inDays),
                ),
              ],
            ),
            SectionTitle(l.byIntensity),
            for (final i in Intensity.values)
              _BarRow(
                label: Fmt.intensity(context, i),
                value: stats.byIntensity[i]!,
                max: stats.occurrenceCount,
                color: Fmt.intensityColor(i, Theme.of(context).colorScheme),
              ),
            SectionTitle(l.triggerRanking),
            if (stats.triggerCounts.isEmpty && stats.unknownTriggerCount == 0)
              Text(l.none)
            else ...[
              for (final e in stats.triggerCounts)
                _BarRow(
                  label: catalog[e.key]?.name ?? '?',
                  value: e.value,
                  max: stats.occurrenceCount,
                ),
              if (stats.unknownTriggerCount > 0)
                _BarRow(
                  label: l.unknownTrigger,
                  value: stats.unknownTriggerCount,
                  max: stats.occurrenceCount,
                  muted: true,
                ),
            ],
            SectionTitle(l.byHourOfDay),
            _ColumnChart(
              values: stats.byHourOfDay,
              labels: [
                for (var h = 0; h < 24; h++) h % 6 == 0 ? l.hourLabel(h) : '',
              ],
            ),
            SectionTitle(l.byWeekday),
            _ColumnChart(
              values: stats.byWeekday,
              labels: Fmt.weekdays(context),
            ),
            SectionTitle(l.medicationUses),
            if (stats.medicationUseCounts.isEmpty)
              Text(l.none)
            else
              for (final e in stats.medicationUseCounts)
                _BarRow(
                  label: catalog[e.key]?.name ?? '?',
                  value: e.value,
                  max: uses.length,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
          ],
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    childAspectRatio: 1.9,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    children: children,
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.hint});
  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (hint != null)
              Text(hint!, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.value,
    required this.max,
    this.color,
    this.muted = false,
  });
  final String label;
  final int value;
  final int max;
  final Color? color;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fraction = max == 0 ? 0.0 : value / max;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: muted ? scheme.outline : null),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 14,
                color: muted ? scheme.outline : (color ?? scheme.primary),
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 32, child: Text('$value', textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _ColumnChart extends StatelessWidget {
  const _ColumnChart({required this.values, required this.labels});
  final List<int> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final max = values.fold<int>(0, (m, v) => v > m ? v : m);
    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (values[i] > 0)
                      Text(
                        '${values[i]}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    Container(
                      height: max == 0 ? 2 : 2 + 70 * values[i] / max,
                      decoration: BoxDecoration(
                        color: values[i] > 0
                            ? scheme.primary
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      labels[i],
                      style: Theme.of(context).textTheme.labelSmall,
                      overflow: TextOverflow.visible,
                      softWrap: false,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
