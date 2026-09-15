// Gera capturas de tela em design/screenshots. Executar com:
//   flutter test --tags screenshots --run-skipped --update-goldens
@Tags(['screenshots'])
library;

import 'dart:ffi' show DynamicLibrary;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idiopatia/app.dart';
import 'package:idiopatia/data/database.dart';
import 'package:idiopatia/data/models.dart';
import 'package:idiopatia/data/repositories.dart';
import 'package:idiopatia/features/security/lock_screen.dart';
import 'package:idiopatia/l10n/generated/app_localizations.dart';
import 'package:idiopatia/services/preferences.dart';
import 'package:idiopatia/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/open.dart';

Future<void> _loadFonts() async {
  final flutterRoot =
      Platform.environment['FLUTTER_ROOT'] ??
      '${Platform.environment['HOME']}/development/flutter';
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      _ttf(
        '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
      ),
    );
  await icons.load();
  for (final family in ['Roboto', 'packages/flutter/Roboto']) {
    final loader = FontLoader(family)
      ..addFont(_ttf('assets/fonts/LiberationSans-Regular.ttf'))
      ..addFont(_ttf('assets/fonts/LiberationSans-Bold.ttf'));
    await loader.load();
  }
}

Future<ByteData> _ttf(String path) async =>
    ByteData.sublistView(await File(path).readAsBytes());

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp).first,
    matchesGoldenFile('../design/screenshots/$name.png'),
  );
}

void main() {
  setUpAll(() async {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    await _loadFonts();
  });

  Future<(AppDatabase, AppPreferences)> boot(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
  }) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'locale': 'pt', ...prefs});
    final db = await AppDatabase.open(inMemoryDatabasePath);
    addTearDown(db.close);
    return (db, await AppPreferences.load());
  }

  Widget app(AppDatabase db, AppPreferences prefs, {Widget? home}) =>
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesProvider.overrideWithValue(prefs),
        ],
        child: home == null
            ? const IdiopatiaApp()
            : MaterialApp(
                locale: const Locale('pt'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF14958A),
                  ),
                ),
                home: home,
              ),
      );

  testWidgets('capturas', (tester) async {
    final (db, prefs) = await boot(tester);
    await tester.pumpWidget(app(db, prefs));
    await _shot(tester, '01-primeiro-uso');

    // Dados de exemplo.
    final repo = Repository(db);
    final p = await repo.createPatient(
      name: 'Pedro',
      birthDate: DateTime(2019, 3, 12),
      sex: Sex.male,
      condition: 'Hiperidrose craniofacial',
    );
    final heat = await repo.createCatalogItem(
      patientId: p.id,
      kind: CatalogKind.trigger,
      name: 'Calor',
    );
    final exercise = await repo.createCatalogItem(
      patientId: p.id,
      kind: CatalogKind.trigger,
      name: 'Exercício',
    );
    await repo.createCatalogItem(
      patientId: p.id,
      kind: CatalogKind.trigger,
      name: 'Sono ruim',
    );
    final med = await repo.createCatalogItem(
      patientId: p.id,
      kind: CatalogKind.medication,
      name: 'Oxibutinina',
      defaultDose: '2,5 mg',
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final samples = [
      (32, 12, Intensity.moderate, [heat.id]),
      (25, 11, Intensity.intense, [heat.id, exercise.id]),
      (17, 13, Intensity.mild, <String>[]),
      (10, 12, Intensity.moderate, [exercise.id]),
      (4, 11, Intensity.intense, [heat.id]),
    ];
    for (final (daysAgo, hours, intensity, triggers) in samples) {
      final start = today
          .subtract(Duration(days: daysAgo))
          .add(const Duration(hours: 21));
      final o = await repo.createOccurrence(
        patientId: p.id,
        startedAt: start,
        endedAt: start.add(Duration(hours: hours)),
        intensity: intensity,
        triggerIds: triggers,
        notes: daysAgo == 4 ? 'Dia muito quente, brincou no sol.' : '',
      );
      await repo.createMedicationUse(
        patientId: p.id,
        takenAt: start.add(const Duration(minutes: 40)),
        medicationId: med.id,
        dose: '2,5 mg',
        occurrenceId: o.id,
      );
    }
    await repo.createOccurrence(
      patientId: p.id,
      startedAt: now.subtract(const Duration(hours: 3, minutes: 20)),
      intensity: Intensity.moderate,
      triggerIds: [heat.id],
    );
    await prefs.setLastExportAt(now.subtract(const Duration(days: 40)));

    await tester.pumpWidget(app(db, prefs));
    await tester.pumpAndSettle();
    await _shot(tester, '02-inicio');

    await tester.tap(find.text('Editar'));
    await _shot(tester, '03-editar-crise');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Registrar medicamento'));
    await _shot(tester, '04-registrar-medicamento');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calendário'));
    await _shot(tester, '05-calendario');
    await tester.tap(find.text('Resumo'));
    await _shot(tester, '06-resumo');
    await tester.drag(find.byType(ListView).last, const Offset(0, -900));
    await _shot(tester, '07-resumo-graficos');
    await tester.tap(find.text('Configurações'));
    await _shot(tester, '08-configuracoes');
    await tester.tap(find.text('Exportar e importar'));
    await _shot(tester, '09-exportar');
  });

  testWidgets('bloqueio', (tester) async {
    final (db, prefs) = await boot(tester, prefs: {'security_mode': 'pin'});
    await tester.pumpWidget(app(db, prefs, home: const LockScreen()));
    await tester.tap(find.text('1'));
    await tester.tap(find.text('2'));
    await _shot(tester, '10-bloqueio');
  });
}
