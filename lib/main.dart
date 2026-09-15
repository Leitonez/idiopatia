import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'app.dart';
import 'data/database.dart';
import 'services/preferences.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbPath = p.join(await getDatabasesPath(), 'idiopatia.db');
  final db = await AppDatabase.open(dbPath);
  final prefs = await AppPreferences.load();
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        preferencesProvider.overrideWithValue(prefs),
      ],
      child: const IdiopatiaApp(),
    ),
  );
}
