import 'dart:ffi' show DynamicLibrary;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idiopatia/app.dart';
import 'package:idiopatia/data/database.dart';
import 'package:idiopatia/services/preferences.dart';
import 'package:idiopatia/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/open.dart';

/// Fluxo ponta a ponta: primeiro uso, cadastro do paciente, registro de uma
/// crise com gatilho novo, encerramento e registro de medicamento.
void main() {
  setUpAll(() {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlite3.so.0'),
    );
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
  });

  testWidgets('primeiro uso até o resumo', (tester) async {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({'locale': 'pt'});
    final db = await AppDatabase.open(inMemoryDatabasePath);
    addTearDown(db.close);
    final prefs = await AppPreferences.load();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesProvider.overrideWithValue(prefs),
        ],
        child: const IdiopatiaApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Primeiro uso: formulário do paciente com a promessa de privacidade.
    expect(find.text('Bem-vindo'), findsOneWidget);
    expect(find.textContaining('apenas neste aparelho'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Ana');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Idiopatia'),
      'Hiperidrose',
    );
    await tester.tap(find.text('Selecionar data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Feminino'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // Tela inicial.
    expect(find.text('Registrar crise'), findsOneWidget);
    expect(find.textContaining('Nenhum registro ainda'), findsOneWidget);

    // Registra uma crise em andamento com um gatilho sugerido.
    await tester.tap(find.text('Registrar crise'));
    await tester.pumpAndSettle();
    expect(find.text('Nova crise'), findsOneWidget);
    await tester.tap(find.text('Calor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Intensa'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Crise em andamento'), findsOneWidget);
    expect(find.textContaining('Gatilhos: Calor'), findsOneWidget);

    // Encerra a crise.
    await tester.tap(find.text('Encerrar crise'));
    await tester.pumpAndSettle();
    expect(find.text('Editar crise'), findsOneWidget);
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Crise em andamento'), findsNothing);

    // Registra um medicamento novo.
    await tester.tap(find.text('Registrar medicamento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Novo medicamento'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Nome'), 'Remédio');
    await tester.enterText(
      find.widgetWithText(TextField, 'Dose padrão'),
      '10 mg',
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Dose'), findsOneWidget);
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('10 mg'), findsOneWidget);

    // Resumo mostra a crise e o gatilho.
    await tester.tap(find.text('Resumo'));
    await tester.pumpAndSettle();
    expect(find.text('Gatilhos mais frequentes'), findsOneWidget);
    expect(find.text('Calor'), findsOneWidget);

    // Calendário marca o dia de hoje.
    await tester.tap(find.text('Calendário'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2 eventos'), findsOneWidget);
  });
}
