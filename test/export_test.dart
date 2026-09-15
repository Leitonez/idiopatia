import 'dart:io';

import 'package:flutter/services.dart' show ByteData;
import 'package:flutter_test/flutter_test.dart';
import 'package:idiopatia/data/models.dart';
import 'package:idiopatia/services/csv_exporter.dart';
import 'package:idiopatia/services/pdf_report.dart';
import 'package:idiopatia/services/report_strings.dart';

ReportStrings strings() => ReportStrings(
  reportTitle: 'Relatório de crises',
  patient: 'Paciente',
  age: 'Idade',
  sex: 'Sexo',
  condition: 'Idiopatia',
  period: 'Período',
  generatedOn: 'Gerado em',
  summary: 'Resumo',
  crisesCount: 'Crises',
  averageDuration: 'Duração média',
  maxDuration: 'Duração máxima',
  daysSinceLast: 'Dias desde a última',
  averageInterval: 'Intervalo médio',
  byIntensity: 'Por intensidade',
  triggerRanking: 'Gatilhos',
  crises: 'Crises',
  medicationUses: 'Medicamentos',
  type: 'Tipo',
  crisis: 'Crise',
  medication: 'Medicamento',
  date: 'Data',
  start: 'Início',
  end: 'Término',
  ongoing: 'Em andamento',
  duration: 'Duração',
  intensity: 'Intensidade',
  triggers: 'Gatilhos',
  unknownTrigger: 'Desconhecido',
  dose: 'Dose',
  linkedCrisis: 'Crise relacionada',
  notes: 'Observações',
  none: 'Nenhum',
  privacyFooter: 'Rodapé',
  intensityLabel: (i) => i.name,
  sexLabel: (s) => s.name,
  formatDate: (d) => '${d.day}/${d.month}/${d.year}',
  formatDateTime: (d) => '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute}',
  formatDuration: (d) => '${d.inHours}h',
  yearsLabel: (y) => '$y anos',
);

void main() {
  final created = DateTime(2026, 9, 1);
  final patient = Patient(
    id: 'p',
    name: 'Ana',
    birthDate: DateTime(2018, 5, 1),
    sex: Sex.female,
    condition: 'Hiperidrose',
    createdAt: created,
    updatedAt: created,
  );
  final catalog = {
    't': CatalogItem(
      id: 't',
      patientId: 'p',
      name: 'Calor',
      active: true,
      createdAt: created,
      updatedAt: created,
    ),
    'm': CatalogItem(
      id: 'm',
      patientId: 'p',
      name: 'Remédio; forte',
      active: true,
      createdAt: created,
      updatedAt: created,
    ),
  };
  final o = Occurrence(
    id: 'o',
    patientId: 'p',
    startedAt: DateTime(2026, 9, 10, 22),
    endedAt: DateTime(2026, 9, 11, 10),
    intensity: Intensity.mild,
    triggerIds: const ['t'],
    notes: 'obs',
    createdAt: created,
    updatedAt: created,
  );
  final u = MedicationUse(
    id: 'u',
    patientId: 'p',
    takenAt: DateTime(2026, 9, 10, 23),
    medicationId: 'm',
    dose: '10 mg',
    occurrenceId: 'o',
    notes: '',
    createdAt: created,
    updatedAt: created,
  );

  test('CSV tem BOM, separador ; e escapa campos', () {
    final csv = CsvExporter.build(
      occurrences: [o],
      uses: [u],
      catalog: catalog,
      s: strings(),
    );
    expect(csv.startsWith('﻿'), isTrue);
    final lines = csv.trimRight().split('\n');
    expect(lines, hasLength(3));
    expect(lines[0], startsWith('﻿Tipo;Início;Término'));
    expect(
      lines[1],
      startsWith('Crise;10/9/2026 22:0;11/9/2026 10:0;12h;mild;Calor'),
    );
    expect(lines[2], contains('"Remédio; forte"'));
    expect(lines[2], contains('10/9/2026 22:0')); // crise relacionada
  });

  test('PDF é gerado com conteúdo', () async {
    final bytes = await PdfReport.build(
      patient: patient,
      periodStart: DateTime(2026, 6, 1),
      periodEnd: DateTime(2026, 9, 14),
      occurrences: [o],
      uses: [u],
      catalog: catalog,
      s: strings(),
      now: DateTime(2026, 9, 14),
      regularFont: ByteData.sublistView(
        File('assets/fonts/LiberationSans-Regular.ttf').readAsBytesSync(),
      ),
      boldFont: ByteData.sublistView(
        File('assets/fonts/LiberationSans-Bold.ttf').readAsBytesSync(),
      ),
    );
    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
