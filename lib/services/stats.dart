import '../data/models.dart';

/// Resumo estatístico de um período. Cálculo puro, sem acesso a banco.
class SummaryStats {
  SummaryStats({
    required this.occurrenceCount,
    required this.averageDuration,
    required this.maxDuration,
    required this.daysSinceLast,
    required this.averageInterval,
    required this.byIntensity,
    required this.triggerCounts,
    required this.unknownTriggerCount,
    required this.byHourOfDay,
    required this.byWeekday,
    required this.medicationUseCounts,
    required this.ongoingCount,
  });

  final int occurrenceCount;

  /// Média das crises encerradas. Nulo se nenhuma foi encerrada.
  final Duration? averageDuration;
  final Duration? maxDuration;

  /// Dias desde o início da crise mais recente. Nulo sem crises.
  final int? daysSinceLast;

  /// Intervalo médio entre inícios de crises consecutivas.
  final Duration? averageInterval;
  final Map<Intensity, int> byIntensity;

  /// Contagem por id de gatilho, em ordem decrescente.
  final List<MapEntry<String, int>> triggerCounts;
  final int unknownTriggerCount;

  /// 24 posições.
  final List<int> byHourOfDay;

  /// 7 posições, índice 0 = segunda-feira (DateTime.monday - 1).
  final List<int> byWeekday;

  /// Contagem por id de medicamento, em ordem decrescente.
  final List<MapEntry<String, int>> medicationUseCounts;
  final int ongoingCount;

  static SummaryStats compute({
    required List<Occurrence> occurrences,
    required List<MedicationUse> uses,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final sorted = [...occurrences]
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

    final ended = sorted.where((o) => !o.isOngoing).toList();
    Duration? avg;
    Duration? max;
    if (ended.isNotEmpty) {
      var total = Duration.zero;
      for (final o in ended) {
        final d = o.duration();
        total += d;
        if (max == null || d > max) max = d;
      }
      avg = Duration(microseconds: total.inMicroseconds ~/ ended.length);
    }

    int? daysSinceLast;
    if (sorted.isNotEmpty) {
      final last = sorted.last.startedAt;
      daysSinceLast = DateTime(
        today.year,
        today.month,
        today.day,
      ).difference(DateTime(last.year, last.month, last.day)).inDays;
    }

    Duration? avgInterval;
    if (sorted.length >= 2) {
      final span = sorted.last.startedAt.difference(sorted.first.startedAt);
      avgInterval = Duration(
        microseconds: span.inMicroseconds ~/ (sorted.length - 1),
      );
    }

    final byIntensity = {for (final i in Intensity.values) i: 0};
    final triggers = <String, int>{};
    var unknown = 0;
    final byHour = List<int>.filled(24, 0);
    final byWeekday = List<int>.filled(7, 0);
    var ongoing = 0;
    for (final o in sorted) {
      byIntensity[o.intensity] = byIntensity[o.intensity]! + 1;
      if (o.triggerIds.isEmpty) {
        unknown++;
      } else {
        for (final t in o.triggerIds) {
          triggers[t] = (triggers[t] ?? 0) + 1;
        }
      }
      byHour[o.startedAt.hour]++;
      byWeekday[o.startedAt.weekday - 1]++;
      if (o.isOngoing) ongoing++;
    }

    final meds = <String, int>{};
    for (final u in uses) {
      meds[u.medicationId] = (meds[u.medicationId] ?? 0) + 1;
    }

    List<MapEntry<String, int>> ranked(Map<String, int> m) =>
        m.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return SummaryStats(
      occurrenceCount: sorted.length,
      averageDuration: avg,
      maxDuration: max,
      daysSinceLast: daysSinceLast,
      averageInterval: avgInterval,
      byIntensity: byIntensity,
      triggerCounts: ranked(triggers),
      unknownTriggerCount: unknown,
      byHourOfDay: byHour,
      byWeekday: byWeekday,
      medicationUseCounts: ranked(meds),
      ongoingCount: ongoing,
    );
  }
}

/// Períodos de resumo disponíveis.
enum SummaryPeriod { last30Days, last90Days, last12Months, allTime }

extension SummaryPeriodRange on SummaryPeriod {
  /// Início do período (inclusive) ou nulo para "tudo".
  DateTime? startFrom(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (this) {
      SummaryPeriod.last30Days => today.subtract(const Duration(days: 29)),
      SummaryPeriod.last90Days => today.subtract(const Duration(days: 89)),
      SummaryPeriod.last12Months => DateTime(
        today.year - 1,
        today.month,
        today.day,
      ),
      SummaryPeriod.allTime => null,
    };
  }
}
