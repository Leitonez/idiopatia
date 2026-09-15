import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/models.dart';
import 'csv_exporter.dart';
import 'report_strings.dart';
import 'stats.dart';

/// Relatório em PDF para levar ao médico: dados do paciente, resumo do
/// período e listas de crises e medicamentos.
class PdfReport {
  PdfReport._();

  static Future<Uint8List> build({
    required Patient patient,
    required DateTime? periodStart,
    required DateTime periodEnd,
    required List<Occurrence> occurrences,
    required List<MedicationUse> uses,
    required Map<String, CatalogItem> catalog,
    required ReportStrings s,
    DateTime? now,
    ByteData? regularFont,
    ByteData? boldFont,
  }) async {
    final generated = now ?? DateTime.now();
    final theme = regularFont == null
        ? null
        : pw.ThemeData.withFont(
            base: pw.Font.ttf(regularFont),
            bold: pw.Font.ttf(boldFont ?? regularFont),
          );
    final stats = SummaryStats.compute(
      occurrences: occurrences,
      uses: uses,
      now: generated,
    );
    final doc = pw.Document(
      title: s.reportTitle,
      author: 'Idiopatia',
      theme: theme,
    );

    const accent = PdfColor.fromInt(0xFF0D5C63);
    final h1 = pw.TextStyle(
      fontSize: 20,
      fontWeight: pw.FontWeight.bold,
      color: accent,
    );
    final h2 = pw.TextStyle(
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
      color: accent,
    );
    const body = pw.TextStyle(fontSize: 10);
    const small = pw.TextStyle(fontSize: 8, color: PdfColors.grey700);

    String periodLabel() {
      final end = s.formatDate(periodEnd);
      return periodStart == null
          ? '${s.period}: ${s.none} - $end'
          : '${s.period}: ${s.formatDate(periodStart)} - $end';
    }

    final sortedOcc = [...occurrences]
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    final sortedUses = [...uses]
      ..sort((a, b) => a.takenAt.compareTo(b.takenAt));

    pw.Widget kv(String k, String v) => pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 150,
          child: pw.Text(
            k,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(child: pw.Text(v, style: body)),
      ],
    );

    String dur(Duration? d) => d == null ? '-' : s.formatDuration(d);

    final intensityRows = Intensity.values
        .map((i) => [s.intensityLabel(i), '${stats.byIntensity[i]}'])
        .toList();

    final triggerRows = <List<String>>[
      for (final e in stats.triggerCounts)
        [catalog[e.key]?.name ?? e.key, '${e.value}'],
      if (stats.unknownTriggerCount > 0)
        [s.unknownTrigger, '${stats.unknownTriggerCount}'],
    ];

    pw.Widget table(
      List<String> headers,
      List<List<String>> rows, {
      Map<int, pw.TableColumnWidth>? widths,
    }) {
      if (rows.isEmpty) return pw.Text(s.none, style: body);
      return pw.TableHelper.fromTextArray(
        headers: headers,
        data: rows,
        headerStyle: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        headerDecoration: const pw.BoxDecoration(color: accent),
        cellStyle: const pw.TextStyle(fontSize: 9),
        cellAlignment: pw.Alignment.centerLeft,
        columnWidths: widths,
        oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Divider(color: PdfColors.grey400),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(child: pw.Text(s.privacyFooter, style: small)),
                pw.Text('${ctx.pageNumber}/${ctx.pagesCount}', style: small),
              ],
            ),
          ],
        ),
        build: (ctx) => [
          pw.Text(s.reportTitle, style: h1),
          pw.SizedBox(height: 4),
          pw.Text(
            '${s.generatedOn} ${s.formatDateTime(generated)}',
            style: small,
          ),
          pw.SizedBox(height: 16),
          pw.Text(s.patient, style: h2),
          pw.SizedBox(height: 6),
          kv(s.patient, patient.name),
          kv(
            s.age,
            '${s.yearsLabel(patient.ageInYears(generated))} (${s.formatDate(patient.birthDate)})',
          ),
          kv(s.sex, s.sexLabel(patient.sex)),
          kv(s.condition, patient.condition),
          pw.SizedBox(height: 16),
          pw.Text(s.summary, style: h2),
          pw.SizedBox(height: 4),
          pw.Text(periodLabel(), style: body),
          pw.SizedBox(height: 6),
          kv(s.crisesCount, '${stats.occurrenceCount}'),
          kv(s.averageDuration, dur(stats.averageDuration)),
          kv(s.maxDuration, dur(stats.maxDuration)),
          kv(
            s.daysSinceLast,
            stats.daysSinceLast == null ? '-' : '${stats.daysSinceLast}',
          ),
          kv(s.averageInterval, dur(stats.averageInterval)),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(s.byIntensity, style: h2),
                    pw.SizedBox(height: 4),
                    table([s.intensity, s.crisesCount], intensityRows),
                  ],
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(s.triggerRanking, style: h2),
                    pw.SizedBox(height: 4),
                    table([s.triggers, s.crisesCount], triggerRows),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(s.crises, style: h2),
          pw.SizedBox(height: 4),
          table(
            [s.start, s.end, s.duration, s.intensity, s.triggers, s.notes],
            [
              for (final o in sortedOcc)
                [
                  s.formatDateTime(o.startedAt),
                  o.endedAt == null ? s.ongoing : s.formatDateTime(o.endedAt!),
                  o.endedAt == null ? '' : s.formatDuration(o.duration()),
                  s.intensityLabel(o.intensity),
                  CsvExporter.triggerNames(o, catalog, s),
                  o.notes,
                ],
            ],
            widths: {
              0: const pw.FixedColumnWidth(78),
              1: const pw.FixedColumnWidth(78),
              2: const pw.FixedColumnWidth(50),
              3: const pw.FixedColumnWidth(55),
              4: const pw.FlexColumnWidth(1.2),
              5: const pw.FlexColumnWidth(1.6),
            },
          ),
          pw.SizedBox(height: 16),
          pw.Text(s.medicationUses, style: h2),
          pw.SizedBox(height: 4),
          table(
            [s.date, s.medication, s.dose, s.linkedCrisis, s.notes],
            [
              for (final u in sortedUses)
                [
                  s.formatDateTime(u.takenAt),
                  catalog[u.medicationId]?.name ?? u.medicationId,
                  u.dose,
                  _linkedStart(u, occurrences, s),
                  u.notes,
                ],
            ],
            widths: {
              0: const pw.FixedColumnWidth(78),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FixedColumnWidth(60),
              3: const pw.FixedColumnWidth(78),
              4: const pw.FlexColumnWidth(1.6),
            },
          ),
        ],
      ),
    );
    return doc.save();
  }

  static String _linkedStart(
    MedicationUse u,
    List<Occurrence> occurrences,
    ReportStrings s,
  ) {
    if (u.occurrenceId == null) return '';
    for (final o in occurrences) {
      if (o.id == u.occurrenceId) return s.formatDateTime(o.startedAt);
    }
    return '';
  }
}
