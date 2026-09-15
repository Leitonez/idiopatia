import 'package:shared_preferences/shared_preferences.dart';

enum SecurityMode { off, pin, biometric }

enum LockTimeout { immediately, oneMinute, fiveMinutes }

extension LockTimeoutDuration on LockTimeout {
  Duration get duration => switch (this) {
    LockTimeout.immediately => Duration.zero,
    LockTimeout.oneMinute => const Duration(minutes: 1),
    LockTimeout.fiveMinutes => const Duration(minutes: 5),
  };
}

/// Preferências simples do app, sem dados de saúde.
class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static Future<AppPreferences> load() async =>
      AppPreferences(await SharedPreferences.getInstance());

  static const _kSelectedPatient = 'selected_patient_id';
  static const _kSecurityMode = 'security_mode';
  static const _kLockTimeout = 'lock_timeout';
  static const _kLastExport = 'last_export_at';
  static const _kBackupSnoozedUntil = 'backup_snoozed_until';
  static const _kLocale = 'locale';

  String? get selectedPatientId => _prefs.getString(_kSelectedPatient);
  Future<void> setSelectedPatientId(String? id) async {
    if (id == null) {
      await _prefs.remove(_kSelectedPatient);
    } else {
      await _prefs.setString(_kSelectedPatient, id);
    }
  }

  SecurityMode get securityMode {
    final v = _prefs.getString(_kSecurityMode);
    return v == null ? SecurityMode.off : SecurityMode.values.byName(v);
  }

  Future<void> setSecurityMode(SecurityMode m) =>
      _prefs.setString(_kSecurityMode, m.name);

  LockTimeout get lockTimeout {
    final v = _prefs.getString(_kLockTimeout);
    return v == null ? LockTimeout.immediately : LockTimeout.values.byName(v);
  }

  Future<void> setLockTimeout(LockTimeout t) =>
      _prefs.setString(_kLockTimeout, t.name);

  DateTime? get lastExportAt {
    final v = _prefs.getString(_kLastExport);
    return v == null ? null : DateTime.parse(v);
  }

  Future<void> setLastExportAt(DateTime dt) =>
      _prefs.setString(_kLastExport, dt.toIso8601String());

  DateTime? get backupSnoozedUntil {
    final v = _prefs.getString(_kBackupSnoozedUntil);
    return v == null ? null : DateTime.parse(v);
  }

  Future<void> setBackupSnoozedUntil(DateTime dt) =>
      _prefs.setString(_kBackupSnoozedUntil, dt.toIso8601String());

  /// Código de idioma ("pt", "en") ou nulo para seguir o sistema.
  String? get localeCode => _prefs.getString(_kLocale);
  Future<void> setLocaleCode(String? code) async {
    if (code == null) {
      await _prefs.remove(_kLocale);
    } else {
      await _prefs.setString(_kLocale, code);
    }
  }

  Future<void> clearAll() => _prefs.clear();
}
