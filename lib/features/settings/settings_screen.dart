import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/formatting.dart';
import '../catalogs/catalog_screen.dart';
import '../patients/patients_screen.dart';
import '../security/security_screen.dart';
import 'about_screen.dart';
import 'export_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final patient = ref.watch(selectedPatientProvider).value;
    final mode = ref.watch(securityModeProvider);
    final locale = ref.watch(localeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: Text(l.patients),
            subtitle: Text(patient?.name ?? l.noPatientSelected),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PatientsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: Text(l.catalogs),
            subtitle: Text(l.catalogsSubtitle),
            enabled: patient != null,
            onTap: patient == null
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CatalogScreen(patient: patient),
                    ),
                  ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: Text(l.exportImport),
            subtitle: Text(l.exportImportSubtitle),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExportScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l.security),
            subtitle: Text(Fmt.securityMode(context, mode)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SecurityScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.language),
            subtitle: Text(_localeLabel(context, locale)),
            onTap: () => _chooseLanguage(context, ref, locale),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.delete_forever_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              l.eraseAllData,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => _eraseAll(context, ref),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.about),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
        ],
      ),
    );
  }

  static String _localeLabel(BuildContext context, Locale? locale) =>
      switch (locale?.languageCode) {
        null => context.l10n.languageSystem,
        'pt' => 'Português',
        'en' => 'English',
        final other => other,
      };

  Future<void> _chooseLanguage(
    BuildContext context,
    WidgetRef ref,
    Locale? current,
  ) async {
    final options = <Locale?>[null, const Locale('pt'), const Locale('en')];
    final chosen = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(ctx.l10n.language),
        children: [
          for (var i = 0; i < options.length; i++)
            RadioListTile<int>(
              value: i,
              groupValue: options.indexOf(current),
              title: Text(_localeLabel(ctx, options[i])),
              onChanged: (v) => Navigator.pop(ctx, v),
            ),
        ],
      ),
    );
    if (chosen != null) {
      await ref.read(localeProvider.notifier).set(options[chosen]);
    }
  }

  Future<void> _eraseAll(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final first = await confirmDialog(
      context,
      title: l.eraseAllTitle,
      message: l.eraseAllMessage,
      confirmLabel: l.continueLabel,
      destructive: true,
    );
    if (!first || !context.mounted) return;
    final typed = await promptText(
      context,
      title: l.eraseAllSecondTitle,
      hint: l.eraseAllSecondMessage,
    );
    if (typed == null || typed.trim().toUpperCase() != l.eraseKeyword) return;
    if (!context.mounted) return;
    await ref.read(repositoryProvider).eraseAll();
    await ref.read(pinStoreProvider).clear();
    final prefs = ref.read(preferencesProvider);
    await prefs.clearAll();
    ref.read(dataVersionProvider.notifier).bump();
    ref.invalidate(securityModeProvider);
    ref.invalidate(lockTimeoutProvider);
    ref.invalidate(selectedPatientIdProvider);
    ref.invalidate(localeProvider);
    if (context.mounted) {
      showSnack(context, l.eraseDone);
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }
}
