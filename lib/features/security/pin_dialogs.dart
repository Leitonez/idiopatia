import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/security_service.dart';
import '../../widgets/formatting.dart';

/// Pede um PIN novo duas vezes. Devolve o PIN ou nulo se cancelado.
Future<String?> promptNewPin(BuildContext context, {String? intro}) async {
  final l = context.l10n;
  final first = await _pinDialog(
    context,
    title: l.newPin,
    intro: intro,
    validate: (v) {
      if (!PinStore.isValidFormat(v)) return l.pinLength;
      return null;
    },
  );
  if (first == null || !context.mounted) return null;
  final second = await _pinDialog(
    context,
    title: l.confirmPin,
    validate: (v) {
      if (v != first) return l.pinMismatch;
      return null;
    },
  );
  return second;
}

/// Pede o PIN atual e o verifica. Devolve true se correto.
Future<bool> promptVerifyPin(
  BuildContext context,
  PinStore store, {
  String? title,
}) async {
  final l = context.l10n;
  var ok = false;
  await _pinDialog(
    context,
    title: title ?? l.enterPin,
    validateAsync: (v) async {
      ok = await store.verify(v);
      return ok ? null : l.wrongPin;
    },
  );
  return ok;
}

Future<String?> _pinDialog(
  BuildContext context, {
  required String title,
  String? intro,
  String? Function(String)? validate,
  Future<String?> Function(String)? validateAsync,
}) {
  final controller = TextEditingController();
  String? error;
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        Future<void> submit() async {
          final v = controller.text;
          var e = validate?.call(v);
          e ??= validateAsync == null ? null : await validateAsync(v);
          if (e != null) {
            setState(() => error = e);
            controller.clear();
            return;
          }
          if (ctx.mounted) Navigator.pop(ctx, v);
        }

        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (intro != null) ...[
                Text(intro, style: Theme.of(ctx).textTheme.bodyMedium),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: controller,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: InputDecoration(errorText: error),
                onSubmitted: (_) => submit(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ctx.l10n.cancel),
            ),
            FilledButton(onPressed: submit, child: Text(ctx.l10n.ok)),
          ],
        );
      },
    ),
  );
}
