import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_info.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../data/time_codec.dart';
import '../../services/backup_codec.dart';
import '../../services/csv_exporter.dart';
import '../../services/file_share.dart';
import '../../services/pdf_report.dart';
import '../../services/report_strings.dart';
import '../../services/stats.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/formatting.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final patient = ref.watch(selectedPatientProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l.exportImport)),
      body: Stack(
        children: [
          ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l.localDataNotice),
              ),
              ListTile(
                leading: const Icon(Icons.backup_outlined),
                title: Text(l.backupJson),
                subtitle: Text(l.backupJsonSubtitle),
                onTap: _busy ? null : () => _exportJson(patient),
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: Text(l.restoreJson),
                subtitle: Text(l.restoreJsonSubtitle),
                onTap: _busy ? null : _importJson,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: Text(l.doctorReport),
                subtitle: Text(patient?.name ?? l.noPatientSelected),
                enabled: patient != null,
                onTap: _busy || patient == null
                    ? null
                    : () => _exportReport(patient, pdf: true),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_outlined),
                title: Text(l.spreadsheet),
                subtitle: Text(patient?.name ?? l.noPatientSelected),
                enabled: patient != null,
                onTap: _busy || patient == null
                    ? null
                    : () => _exportReport(patient, pdf: false),
              ),
            ],
          ),
          if (_busy)
            const ColoredBox(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Future<T> _run<T>(Future<T> Function() body) async {
    setState(() => _busy = true);
    try {
      return await body();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportJson(Patient? current) async {
    final l = context.l10n;
    final repo = ref.read(repositoryProvider);
    final all = await repo.listPatients();
    if (!mounted || all.isEmpty) return;

    List<Patient> chosen = all;
    if (current != null && all.length > 1) {
      final onlyCurrent = await showDialog<bool>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: Text(l.whichPatients),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.allPatients),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.onlyThisPatient(current.name)),
            ),
          ],
        ),
      );
      if (onlyCurrent == null) return;
      if (onlyCurrent) chosen = [current];
    }

    await _run(() async {
      final triggers = <String, List<CatalogItem>>{};
      final meds = <String, List<CatalogItem>>{};
      final occ = <String, List<Occurrence>>{};
      final uses = <String, List<MedicationUse>>{};
      for (final p in chosen) {
        triggers[p.id] = await repo.listCatalog(p.id, CatalogKind.trigger);
        meds[p.id] = await repo.listCatalog(p.id, CatalogKind.medication);
        occ[p.id] = await repo.listOccurrences(p.id);
        uses[p.id] = await repo.listMedicationUses(p.id);
      }
      final json = BackupCodec.encode(
        patients: chosen,
        triggersByPatient: triggers,
        medicationsByPatient: meds,
        occurrencesByPatient: occ,
        usesByPatient: uses,
        appVersion: appVersion,
      );
      final date = TimeCodec.encodeDate(DateTime.now());
      await FileShare.shareBytes(
        fileName: 'idiopatia-backup-$date.json',
        bytes: Uint8List.fromList(utf8.encode(json)),
        mimeType: 'application/json',
        subject: l.backupJson,
      );
      await ref.read(backupReminderProvider.notifier).markExported();
      if (mounted) showSnack(context, l.exportDone);
    });
  }

  Future<void> _importJson() async {
    final l = context.l10n;
    final text = await FileShare.pickTextFile();
    if (text == null || !mounted) return;
    final BackupData data;
    try {
      data = BackupCodec.decode(text);
    } on BackupFormatException catch (e) {
      showSnack(context, l.importError(e.message));
      return;
    }
    final ok = await confirmDialog(
      context,
      title: l.importConfirmTitle,
      message: l.importConfirmMessage,
    );
    if (!ok) return;
    await _run(() async {
      final result = await ref
          .read(repositoryProvider)
          .importAll(
            patients: data.patients,
            catalogKinds: data.catalogKinds,
            catalogItems: data.catalogItems,
            occurrences: data.occurrences,
            uses: data.uses,
          );
      ref.read(dataVersionProvider.notifier).bump();
      if (mounted) {
        showSnack(
          context,
          l.importSuccess(
            result.patients,
            result.occurrences,
            result.uses,
            result.skipped,
          ),
        );
      }
    });
  }

  Future<void> _exportReport(Patient patient, {required bool pdf}) async {
    final l = context.l10n;
    final period = await showDialog<SummaryPeriod>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.period),
        children: [
          for (final p in SummaryPeriod.values)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, p),
              child: Text(Fmt.period(ctx, p)),
            ),
        ],
      ),
    );
    if (period == null || !mounted) return;

    await _run(() async {
      final repo = ref.read(repositoryProvider);
      final now = DateTime.now();
      final from = period.startFrom(now);
      final occ = await repo.listOccurrences(patient.id, from: from);
      final uses = await repo.listMedicationUses(patient.id, from: from);
      final catalog = await repo.catalogById(patient.id);
      if (!mounted) return;
      final strings = _reportStrings(context);
      final slug = _slug(patient.name);
      final periodTag = period.name;
      if (pdf) {
        final regular = await rootBundle.load(
          'assets/fonts/LiberationSans-Regular.ttf',
        );
        final bold = await rootBundle.load(
          'assets/fonts/LiberationSans-Bold.ttf',
        );
        final bytes = await PdfReport.build(
          patient: patient,
          periodStart: from,
          periodEnd: now,
          occurrences: occ,
          uses: uses,
          catalog: catalog,
          s: strings,
          now: now,
          regularFont: regular,
          boldFont: bold,
        );
        await FileShare.shareBytes(
          fileName: 'idiopatia-$slug-$periodTag.pdf',
          bytes: bytes,
          mimeType: 'application/pdf',
          subject: l.doctorReport,
        );
      } else {
        final csv = CsvExporter.build(
          occurrences: occ,
          uses: uses,
          catalog: catalog,
          s: strings,
        );
        await FileShare.shareBytes(
          fileName: 'idiopatia-$slug-$periodTag.csv',
          bytes: Uint8List.fromList(utf8.encode(csv)),
          mimeType: 'text/csv',
          subject: l.spreadsheet,
        );
      }
      if (mounted) showSnack(context, l.exportDone);
    });
  }

  static String _slug(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

ReportStrings _reportStrings(BuildContext context) {
  final l = context.l10n;
  return ReportStrings(
    reportTitle: l.reportTitle,
    patient: l.patient,
    age: l.age,
    sex: l.sex,
    condition: l.condition,
    period: l.period,
    generatedOn: l.generatedOn,
    summary: l.summary,
    crisesCount: l.crisesCount,
    averageDuration: l.averageDuration,
    maxDuration: l.maxDuration,
    daysSinceLast: l.daysSinceLast,
    averageInterval: l.averageInterval,
    byIntensity: l.byIntensity,
    triggerRanking: l.triggerRanking,
    crises: l.crises,
    medicationUses: l.medicationUses,
    type: l.type,
    crisis: l.crisis,
    medication: l.medication,
    date: l.date,
    start: l.start,
    end: l.end,
    ongoing: l.ongoing,
    duration: l.duration,
    intensity: l.intensity,
    triggers: l.triggers,
    unknownTrigger: l.unknownTrigger,
    dose: l.dose,
    linkedCrisis: l.linkedCrisis,
    notes: l.notes,
    none: l.none,
    privacyFooter: l.privacyFooter,
    intensityLabel: (i) => Fmt.intensity(context, i),
    sexLabel: (s) => Fmt.sex(context, s),
    formatDate: (d) => Fmt.date(context, d),
    formatDateTime: (d) => Fmt.dateTime(context, d),
    formatDuration: (d) => Fmt.duration(context, d),
    yearsLabel: (y) => l.ageYears(y),
  );
}
