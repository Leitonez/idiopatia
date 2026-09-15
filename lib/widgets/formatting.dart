import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/preferences.dart';
import '../services/stats.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String get localeTag => Localizations.localeOf(this).toString();
}

/// Formatação de datas, durações e enumerações conforme o idioma.
class Fmt {
  Fmt._();

  static String date(BuildContext c, DateTime d) =>
      DateFormat.yMd(c.localeTag).format(d);

  static String dateTime(BuildContext c, DateTime d) =>
      DateFormat.yMd(c.localeTag).add_Hm().format(d);

  static String time(BuildContext c, DateTime d) =>
      DateFormat.Hm(c.localeTag).format(d);

  static String monthYear(BuildContext c, DateTime d) =>
      DateFormat.yMMMM(c.localeTag).format(d);

  static String dayMonth(BuildContext c, DateTime d) =>
      DateFormat.MMMEd(c.localeTag).format(d);

  static String duration(BuildContext c, Duration d) {
    final l = c.l10n;
    if (d.isNegative) d = Duration.zero;
    if (d.inDays >= 1) return l.durationDaysHours(d.inDays, d.inHours % 24);
    return l.durationHoursMinutes(d.inHours, d.inMinutes % 60);
  }

  static String intensity(BuildContext c, Intensity i) => switch (i) {
    Intensity.mild => c.l10n.intensityMild,
    Intensity.moderate => c.l10n.intensityModerate,
    Intensity.intense => c.l10n.intensityIntense,
  };

  static String sex(BuildContext c, Sex s) => switch (s) {
    Sex.female => c.l10n.sexFemale,
    Sex.male => c.l10n.sexMale,
    Sex.other => c.l10n.sexOther,
  };

  static String period(BuildContext c, SummaryPeriod p) => switch (p) {
    SummaryPeriod.last30Days => c.l10n.last30Days,
    SummaryPeriod.last90Days => c.l10n.last90Days,
    SummaryPeriod.last12Months => c.l10n.last12Months,
    SummaryPeriod.allTime => c.l10n.allTime,
  };

  static String securityMode(BuildContext c, SecurityMode m) => switch (m) {
    SecurityMode.off => c.l10n.securityOff,
    SecurityMode.pin => c.l10n.securityPin,
    SecurityMode.biometric => c.l10n.securityBiometric,
  };

  static String lockTimeout(BuildContext c, LockTimeout t) => switch (t) {
    LockTimeout.immediately => c.l10n.lockImmediately,
    LockTimeout.oneMinute => c.l10n.lockAfter1Min,
    LockTimeout.fiveMinutes => c.l10n.lockAfter5Min,
  };

  static List<String> weekdays(BuildContext c) => [
    c.l10n.weekdayMon,
    c.l10n.weekdayTue,
    c.l10n.weekdayWed,
    c.l10n.weekdayThu,
    c.l10n.weekdayFri,
    c.l10n.weekdaySat,
    c.l10n.weekdaySun,
  ];

  static Color intensityColor(Intensity i, ColorScheme scheme) => switch (i) {
    Intensity.mild => const Color(0xFF4CAF50),
    Intensity.moderate => const Color(0xFFFFA000),
    Intensity.intense => const Color(0xFFE53935),
  };
}
