import 'package:flutter_test/flutter_test.dart';
import 'package:idiopatia/data/models.dart';
import 'package:idiopatia/services/stats.dart';

Occurrence occ(
  String id,
  DateTime start, {
  DateTime? end,
  Intensity intensity = Intensity.moderate,
  List<String> triggers = const [],
}) => Occurrence(
  id: id,
  patientId: 'p',
  startedAt: start,
  endedAt: end,
  intensity: intensity,
  triggerIds: triggers,
  notes: '',
  createdAt: start,
  updatedAt: start,
);

void main() {
  test('resumo vazio', () {
    final s = SummaryStats.compute(occurrences: const [], uses: const []);
    expect(s.occurrenceCount, 0);
    expect(s.averageDuration, isNull);
    expect(s.daysSinceLast, isNull);
    expect(s.averageInterval, isNull);
    expect(s.triggerCounts, isEmpty);
  });

  test('calcula durações, intervalos, gatilhos e distribuições', () {
    final now = DateTime(2026, 9, 14, 12);
    final list = [
      occ(
        'a',
        DateTime(2026, 9, 1, 22),
        end: DateTime(2026, 9, 2, 10),
        intensity: Intensity.intense,
        triggers: ['heat'],
      ),
      occ(
        'b',
        DateTime(2026, 9, 5, 22),
        end: DateTime(2026, 9, 6, 6),
        intensity: Intensity.mild,
        triggers: ['heat', 'stress'],
      ),
      occ('c', DateTime(2026, 9, 13, 8)), // em andamento, gatilho desconhecido
    ];
    final s = SummaryStats.compute(occurrences: list, uses: const [], now: now);
    expect(s.occurrenceCount, 3);
    expect(s.ongoingCount, 1);
    expect(s.averageDuration, const Duration(hours: 10));
    expect(s.maxDuration, const Duration(hours: 12));
    expect(s.daysSinceLast, 1);
    // De 1/9 22h a 13/9 8h = 11 dias e 10 h, dividido por 2 intervalos.
    expect(s.averageInterval, const Duration(hours: (11 * 24 + 10) ~/ 2));
    expect(s.byIntensity[Intensity.intense], 1);
    expect(s.byIntensity[Intensity.mild], 1);
    expect(s.byIntensity[Intensity.moderate], 1);
    expect(s.triggerCounts.first.key, 'heat');
    expect(s.triggerCounts.first.value, 2);
    expect(s.unknownTriggerCount, 1);
    expect(s.byHourOfDay[22], 2);
    expect(s.byHourOfDay[8], 1);
    // 1/9/2026 é terça-feira (índice 1).
    expect(s.byWeekday[DateTime(2026, 9, 1).weekday - 1], 1);
  });

  test('períodos começam no dia certo', () {
    final now = DateTime(2026, 9, 14, 15, 30);
    expect(SummaryPeriod.last30Days.startFrom(now), DateTime(2026, 8, 16));
    expect(SummaryPeriod.last90Days.startFrom(now), DateTime(2026, 6, 17));
    expect(SummaryPeriod.last12Months.startFrom(now), DateTime(2025, 9, 14));
    expect(SummaryPeriod.allTime.startFrom(now), isNull);
  });
}
