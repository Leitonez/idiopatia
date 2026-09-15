import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/preferences.dart';
import '../../state/providers.dart';
import '../../widgets/formatting.dart';

/// Tela exibida enquanto o app está bloqueado. Teclado numérico para o PIN
/// e, no modo biometria, tenta a biometria automaticamente ao abrir.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _pin = '';
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (ref.read(securityModeProvider) == SecurityMode.biometric) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _biometric());
    }
  }

  Future<void> _biometric() async {
    if (_busy || !mounted) return;
    setState(() => _busy = true);
    final ok = await ref
        .read(biometricServiceProvider)
        .authenticate(context.l10n.biometricPrompt);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) ref.read(lockStateProvider.notifier).unlock();
  }

  Future<void> _submit() async {
    if (_pin.length < 4) return;
    final ok = await ref.read(pinStoreProvider).verify(_pin);
    if (!mounted) return;
    if (ok) {
      ref.read(lockStateProvider.notifier).unlock();
    } else {
      setState(() {
        _error = context.l10n.wrongPin;
        _pin = '';
      });
    }
  }

  void _tap(String digit) {
    if (_pin.length >= 6) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length >= 4) {
      // Envia automaticamente ao atingir 6 dígitos; com 4 ou 5 o usuário
      // confirma no botão.
      if (_pin.length == 6) _submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final biometric = ref.watch(securityModeProvider) == SecurityMode.biometric;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 48, color: scheme.primary),
                const SizedBox(height: 12),
                Text(
                  l.appTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Text(l.enterPin),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 6; i++)
                      Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _pin.length ? scheme.primary : null,
                          border: Border.all(color: scheme.primary),
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: 24,
                  child: _error == null
                      ? null
                      : Text(_error!, style: TextStyle(color: scheme.error)),
                ),
                for (final row in const [
                  ['1', '2', '3'],
                  ['4', '5', '6'],
                  ['7', '8', '9'],
                ])
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [for (final d in row) _key(d, () => _tap(d))],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _key(
                      null,
                      biometric ? _biometric : null,
                      icon: biometric ? Icons.fingerprint : null,
                    ),
                    _key('0', () => _tap('0')),
                    _key(
                      null,
                      () => setState(
                        () => _pin = _pin.isEmpty
                            ? ''
                            : _pin.substring(0, _pin.length - 1),
                      ),
                      icon: Icons.backspace_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _pin.length >= 4 ? _submit : null,
                  child: Text(l.unlock),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _key(String? digit, VoidCallback? onTap, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: 72,
        height: 60,
        child: onTap == null && digit == null
            ? null
            : OutlinedButton(
                onPressed: onTap,
                child: icon != null
                    ? Icon(icon)
                    : Text(digit!, style: const TextStyle(fontSize: 22)),
              ),
      ),
    );
  }
}
