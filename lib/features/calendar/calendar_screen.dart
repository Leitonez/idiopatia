import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/event_tile.dart';
import '../../widgets/formatting.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _month;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selected = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final patient = ref.watch(selectedPatientProvider).value;
    if (patient == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.calendar)),
        body: EmptyState(
          icon: Icons.person_off_outlined,
          text: l.noPatientSelected,
        ),
      );
    }
    final occ = ref.watch(occurrencesProvider(patient.id)).value ?? const [];
    final uses =
        ref.watch(medicationUsesProvider(patient.id)).value ?? const [];
    final catalog = ref.watch(catalogByIdProvider(patient.id)).value ?? {};

    // Intensidade máxima por dia coberto por uma crise, e dias com medicamento.
    final dayIntensity = <DateTime, Intensity>{};
    for (final o in occ) {
      var d = _dateOnly(o.startedAt);
      final end = _dateOnly(o.endedAt ?? DateTime.now());
      while (!d.isAfter(end)) {
        final cur = dayIntensity[d];
        if (cur == null || o.intensity.index > cur.index) {
          dayIntensity[d] = o.intensity;
        }
        d = d.add(const Duration(days: 1));
      }
    }
    final medDays = {for (final u in uses) _dateOnly(u.takenAt)};

    final dayEvents = <TimelineEvent>[
      ...occ
          .where((o) => _dateOnly(o.startedAt) == _selected)
          .map(OccurrenceEvent.new),
      ...uses
          .where((u) => _dateOnly(u.takenAt) == _selected)
          .map(MedicationEvent.new),
    ]..sort((a, b) => a.at.compareTo(b.at));

    return Scaffold(
      appBar: AppBar(
        title: Text('${l.calendar} · ${patient.name}'),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              final now = DateTime.now();
              _month = DateTime(now.year, now.month);
              _selected = _dateOnly(now);
            }),
            child: Text(l.today),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: l.previousMonth,
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(
                  () => _month = DateTime(_month.year, _month.month - 1),
                ),
              ),
              Expanded(
                child: Text(
                  Fmt.monthYear(context, _month),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: l.nextMonth,
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(
                  () => _month = DateTime(_month.year, _month.month + 1),
                ),
              ),
            ],
          ),
          _MonthGrid(
            month: _month,
            selected: _selected,
            dayIntensity: dayIntensity,
            medDays: medDays,
            onSelect: (d) => setState(() => _selected = d),
          ),
          const Divider(height: 1),
          Expanded(
            child: dayEvents.isEmpty
                ? EmptyState(
                    icon: Icons.event_available_outlined,
                    text: l.noEventsOnDay,
                  )
                : ListView(
                    children: [
                      SectionTitle(
                        '${Fmt.dayMonth(context, _selected)} · ${l.eventsCount(dayEvents.length)}',
                      ),
                      for (final e in dayEvents)
                        EventTile(event: e, patient: patient, catalog: catalog),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.dayIntensity,
    required this.medDays,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final Map<DateTime, Intensity> dayIntensity;
  final Set<DateTime> medDays;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final weekdays = Fmt.weekdays(context);
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday - 1; // segunda = 0
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final cells = <Widget>[];
    for (final w in weekdays) {
      cells.add(
        Center(
          child: Text(
            w,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      );
    }
    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      final intensity = dayIntensity[date];
      final isSelected = date == selected;
      final isToday = date == todayDate;
      cells.add(
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onSelect(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: intensity != null
                  ? Fmt.intensityColor(
                      intensity,
                      scheme,
                    ).withValues(alpha: 0.22)
                  : null,
              border: isSelected
                  ? Border.all(color: scheme.primary, width: 2)
                  : isToday
                  ? Border.all(color: scheme.outline)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$d',
                  style: TextStyle(
                    fontWeight: isToday || intensity != null
                        ? FontWeight.bold
                        : null,
                  ),
                ),
                if (medDays.contains(date))
                  Positioned(
                    bottom: 3,
                    child: Icon(Icons.circle, size: 6, color: scheme.tertiary),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.15,
        children: cells,
      ),
    );
  }
}
