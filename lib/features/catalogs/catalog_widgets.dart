import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/formatting.dart';

/// Diálogo para criar ou editar um medicamento (nome e dose padrão).
/// Devolve (nome, dose) ou nulo.
Future<(String, String?)?> promptMedication(
  BuildContext context, {
  String initialName = '',
  String? initialDose,
}) {
  final l = context.l10n;
  final name = TextEditingController(text: initialName);
  final dose = TextEditingController(text: initialDose ?? '');
  return showDialog<(String, String?)>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(initialName.isEmpty ? l.newMedication : l.edit),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l.name),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: dose,
            decoration: InputDecoration(
              labelText: l.defaultDose,
              hintText: l.doseHint,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
        FilledButton(
          onPressed: () {
            if (name.text.trim().isEmpty) return;
            Navigator.pop(ctx, (name.text.trim(), dose.text.trim()));
          },
          child: Text(l.ok),
        ),
      ],
    ),
  );
}

/// Cria um item de catálogo tratando nome duplicado. Devolve o item ou nulo.
Future<CatalogItem?> createCatalogItemOrWarn(
  BuildContext context,
  WidgetRef ref, {
  required String patientId,
  required CatalogKind kind,
  required String name,
  String? defaultDose,
}) async {
  try {
    final item = await ref
        .read(repositoryProvider)
        .createCatalogItem(
          patientId: patientId,
          kind: kind,
          name: name,
          defaultDose: defaultDose,
        );
    ref.read(dataVersionProvider.notifier).bump();
    return item;
  } on DuplicateNameException {
    if (context.mounted) showSnack(context, context.l10n.nameAlreadyExists);
    return null;
  }
}

List<String> suggestedTriggers(BuildContext context) {
  final l = context.l10n;
  return [
    l.suggestedTriggerHeat,
    l.suggestedTriggerCold,
    l.suggestedTriggerExercise,
    l.suggestedTriggerStress,
    l.suggestedTriggerFood,
    l.suggestedTriggerSleep,
    l.suggestedTriggerIllness,
    l.suggestedTriggerEmotion,
  ];
}
