import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../services/preferences.dart';
import '../services/security_service.dart';

// Infraestrutura, sobrescrita em main() após a inicialização.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError(),
);
final preferencesProvider = Provider<AppPreferences>(
  (ref) => throw UnimplementedError(),
);
final pinStoreProvider = Provider<PinStore>((ref) => PinStore());
final biometricServiceProvider = Provider<BiometricService>(
  (ref) => BiometricService(),
);
final repositoryProvider = Provider<Repository>(
  (ref) => Repository(ref.watch(databaseProvider)),
);

/// Contador incrementado a cada escrita no banco. Todas as consultas o
/// observam, então qualquer gravação atualiza todas as telas.
class DataVersion extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

final dataVersionProvider = NotifierProvider<DataVersion, int>(DataVersion.new);

final patientsProvider = FutureProvider<List<Patient>>((ref) {
  ref.watch(dataVersionProvider);
  return ref.watch(repositoryProvider).listPatients();
});

class SelectedPatientId extends Notifier<String?> {
  @override
  String? build() => ref.watch(preferencesProvider).selectedPatientId;

  Future<void> select(String? id) async {
    state = id;
    await ref.read(preferencesProvider).setSelectedPatientId(id);
  }
}

final selectedPatientIdProvider = NotifierProvider<SelectedPatientId, String?>(
  SelectedPatientId.new,
);

/// Paciente selecionado. Se o id guardado não existir mais, usa o primeiro.
final selectedPatientProvider = FutureProvider<Patient?>((ref) async {
  final patients = await ref.watch(patientsProvider.future);
  if (patients.isEmpty) return null;
  final id = ref.watch(selectedPatientIdProvider);
  for (final p in patients) {
    if (p.id == id) return p;
  }
  return patients.first;
});

final ongoingOccurrencesProvider =
    FutureProvider.family<List<Occurrence>, String>((ref, patientId) {
      ref.watch(dataVersionProvider);
      return ref.watch(repositoryProvider).listOngoingOccurrences(patientId);
    });

final timelineProvider = FutureProvider.family<List<TimelineEvent>, String>((
  ref,
  patientId,
) {
  ref.watch(dataVersionProvider);
  return ref.watch(repositoryProvider).timeline(patientId, limit: 60);
});

final occurrencesProvider = FutureProvider.family<List<Occurrence>, String>((
  ref,
  patientId,
) {
  ref.watch(dataVersionProvider);
  return ref.watch(repositoryProvider).listOccurrences(patientId);
});

final medicationUsesProvider =
    FutureProvider.family<List<MedicationUse>, String>((ref, patientId) {
      ref.watch(dataVersionProvider);
      return ref.watch(repositoryProvider).listMedicationUses(patientId);
    });

typedef CatalogKey = ({String patientId, CatalogKind kind, bool onlyActive});

final catalogProvider = FutureProvider.family<List<CatalogItem>, CatalogKey>((
  ref,
  key,
) {
  ref.watch(dataVersionProvider);
  return ref
      .watch(repositoryProvider)
      .listCatalog(key.patientId, key.kind, onlyActive: key.onlyActive);
});

final catalogByIdProvider =
    FutureProvider.family<Map<String, CatalogItem>, String>((ref, patientId) {
      ref.watch(dataVersionProvider);
      return ref.watch(repositoryProvider).catalogById(patientId);
    });

final hasAnyDataProvider = FutureProvider<bool>((ref) {
  ref.watch(dataVersionProvider);
  return ref.watch(repositoryProvider).hasAnyData();
});

// ------------------------------------------------------------- segurança

class SecurityModeNotifier extends Notifier<SecurityMode> {
  @override
  SecurityMode build() => ref.watch(preferencesProvider).securityMode;

  Future<void> set(SecurityMode m) async {
    state = m;
    await ref.read(preferencesProvider).setSecurityMode(m);
  }
}

final securityModeProvider =
    NotifierProvider<SecurityModeNotifier, SecurityMode>(
      SecurityModeNotifier.new,
    );

class LockTimeoutNotifier extends Notifier<LockTimeout> {
  @override
  LockTimeout build() => ref.watch(preferencesProvider).lockTimeout;

  Future<void> set(LockTimeout t) async {
    state = t;
    await ref.read(preferencesProvider).setLockTimeout(t);
  }
}

final lockTimeoutProvider = NotifierProvider<LockTimeoutNotifier, LockTimeout>(
  LockTimeoutNotifier.new,
);

/// Se o app está bloqueado aguardando PIN ou biometria.
class LockState extends Notifier<bool> {
  @override
  bool build() => ref.read(securityModeProvider) != SecurityMode.off;

  void lock() => state = true;
  void unlock() => state = false;
}

final lockStateProvider = NotifierProvider<LockState, bool>(LockState.new);

// ------------------------------------------------------------- idioma

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final code = ref.watch(preferencesProvider).localeCode;
    return code == null ? null : Locale(code);
  }

  Future<void> set(Locale? locale) async {
    state = locale;
    await ref.read(preferencesProvider).setLocaleCode(locale?.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

// ------------------------------------------------------------- backup

/// Estado do lembrete de backup: nulo se não deve ser exibido.
enum BackupReminder { never, stale }

class BackupReminderNotifier extends Notifier<BackupReminder?> {
  @override
  BackupReminder? build() {
    ref.watch(dataVersionProvider);
    final hasData = ref.watch(hasAnyDataProvider).value ?? false;
    if (!hasData) return null;
    final prefs = ref.watch(preferencesProvider);
    final now = DateTime.now();
    final snoozed = prefs.backupSnoozedUntil;
    if (snoozed != null && snoozed.isAfter(now)) return null;
    final last = prefs.lastExportAt;
    if (last == null) return BackupReminder.never;
    if (now.difference(last).inDays >= 30) return BackupReminder.stale;
    return null;
  }

  Future<void> snooze() async {
    await ref
        .read(preferencesProvider)
        .setBackupSnoozedUntil(DateTime.now().add(const Duration(days: 7)));
    state = null;
  }

  Future<void> markExported() async {
    await ref.read(preferencesProvider).setLastExportAt(DateTime.now());
    state = null;
  }
}

final backupReminderProvider =
    NotifierProvider<BackupReminderNotifier, BackupReminder?>(
      BackupReminderNotifier.new,
    );
