import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/preferences.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/formatting.dart';
import 'pin_dialogs.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final mode = ref.watch(securityModeProvider);
    final timeout = ref.watch(lockTimeoutProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.security)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l.securityExplanation),
          ),
          for (final m in SecurityMode.values)
            RadioListTile<SecurityMode>(
              value: m,
              groupValue: mode,
              title: Text(Fmt.securityMode(context, m)),
              secondary: Icon(switch (m) {
                SecurityMode.off => Icons.lock_open,
                SecurityMode.pin => Icons.pin_outlined,
                SecurityMode.biometric => Icons.fingerprint,
              }),
              onChanged: (v) => _changeMode(context, ref, v!),
            ),
          if (mode != SecurityMode.off) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.password),
              title: Text(l.changePin),
              onTap: () => _changePin(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: Text(l.lockTimeout),
              subtitle: Text(Fmt.lockTimeout(context, timeout)),
              onTap: () => _chooseTimeout(context, ref, timeout),
            ),
          ],
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l.forgotPinWarning,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  /// Exige a autenticação vigente antes de qualquer mudança.
  Future<bool> _authorize(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final current = ref.read(securityModeProvider);
    if (current == SecurityMode.off) return true;
    if (current == SecurityMode.biometric) {
      final ok = await ref
          .read(biometricServiceProvider)
          .authenticate(l.authenticateToChange);
      if (ok) return true;
      if (!context.mounted) return false;
    }
    return promptVerifyPin(
      context,
      ref.read(pinStoreProvider),
      title: l.authenticateToChange,
    );
  }

  Future<void> _changeMode(
    BuildContext context,
    WidgetRef ref,
    SecurityMode target,
  ) async {
    final l = context.l10n;
    final current = ref.read(securityModeProvider);
    if (target == current) return;
    if (!await _authorize(context, ref)) return;
    if (!context.mounted) return;

    final pinStore = ref.read(pinStoreProvider);
    switch (target) {
      case SecurityMode.off:
        await pinStore.clear();
      case SecurityMode.pin:
        if (!await pinStore.hasPin()) {
          if (!context.mounted) return;
          final pin = await promptNewPin(context, intro: l.forgotPinWarning);
          if (pin == null) return;
          await pinStore.setPin(pin);
        }
      case SecurityMode.biometric:
        final available = await ref
            .read(biometricServiceProvider)
            .isAvailable();
        if (!context.mounted) return;
        if (!available) {
          showSnack(context, l.biometricUnavailable);
          return;
        }
        if (!await pinStore.hasPin()) {
          if (!context.mounted) return;
          final pin = await promptNewPin(
            context,
            intro: '${l.recoveryPinInfo}\n\n${l.forgotPinWarning}',
          );
          if (pin == null) return;
          await pinStore.setPin(pin);
        }
        final ok = await ref
            .read(biometricServiceProvider)
            .authenticate(context.mounted ? context.l10n.biometricPrompt : '');
        if (!ok) return;
    }
    await ref.read(securityModeProvider.notifier).set(target);
  }

  Future<void> _changePin(BuildContext context, WidgetRef ref) async {
    if (!await _authorize(context, ref)) return;
    if (!context.mounted) return;
    final pin = await promptNewPin(context);
    if (pin == null) return;
    await ref.read(pinStoreProvider).setPin(pin);
    if (context.mounted) showSnack(context, context.l10n.savedGeneric);
  }

  Future<void> _chooseTimeout(
    BuildContext context,
    WidgetRef ref,
    LockTimeout current,
  ) async {
    final chosen = await showDialog<LockTimeout>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(ctx.l10n.lockTimeout),
        children: [
          for (final t in LockTimeout.values)
            RadioListTile<LockTimeout>(
              value: t,
              groupValue: current,
              title: Text(Fmt.lockTimeout(ctx, t)),
              onChanged: (v) => Navigator.pop(ctx, v),
            ),
        ],
      ),
    );
    if (chosen != null) {
      await ref.read(lockTimeoutProvider.notifier).set(chosen);
    }
  }
}
