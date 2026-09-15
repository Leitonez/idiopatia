import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/formatting.dart';
import 'catalog_widgets.dart';

/// Gestão dos catálogos de gatilhos e medicamentos do paciente.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key, required this.patient});
  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${l.catalogs} · ${patient.name}'),
          bottom: TabBar(
            tabs: [
              Tab(text: l.manageTriggers),
              Tab(text: l.manageMedications),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CatalogList(patient: patient, kind: CatalogKind.trigger),
            _CatalogList(patient: patient, kind: CatalogKind.medication),
          ],
        ),
      ),
    );
  }
}

class _CatalogList extends ConsumerWidget {
  const _CatalogList({required this.patient, required this.kind});
  final Patient patient;
  final CatalogKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final items = ref.watch(
      catalogProvider((patientId: patient.id, kind: kind, onlyActive: false)),
    );
    return Scaffold(
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorBox(e),
        data: (list) => list.isEmpty
            ? EmptyState(
                icon: kind == CatalogKind.trigger
                    ? Icons.bolt_outlined
                    : Icons.medication_outlined,
                text: l.noCatalogItems,
              )
            : ListView(
                padding: const EdgeInsets.only(bottom: 88),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      l.inactiveItemsHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  for (final item in list)
                    ListTile(
                      title: Text(
                        item.name,
                        style: item.active
                            ? null
                            : TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                      ),
                      subtitle:
                          kind == CatalogKind.medication &&
                              (item.defaultDose?.isNotEmpty ?? false)
                          ? Text(item.defaultDose!)
                          : null,
                      trailing: Switch(
                        value: item.active,
                        onChanged: (v) =>
                            _update(ref, item.copyWith(active: v)),
                      ),
                      onTap: () => _edit(context, ref, item),
                      onLongPress: () => _delete(context, ref, item),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_${kind.name}',
        onPressed: () => _add(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _update(WidgetRef ref, CatalogItem item) async {
    try {
      await ref.read(repositoryProvider).updateCatalogItem(item);
      ref.read(dataVersionProvider.notifier).bump();
    } on DuplicateNameException {
      if (ref.context.mounted) {
        showSnack(ref.context, ref.context.l10n.nameAlreadyExists);
      }
    }
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    if (kind == CatalogKind.trigger) {
      final name = await promptText(
        context,
        title: l.newTrigger,
        label: l.name,
      );
      if (name == null || name.isEmpty || !context.mounted) return;
      await createCatalogItemOrWarn(
        context,
        ref,
        patientId: patient.id,
        kind: kind,
        name: name,
      );
    } else {
      final r = await promptMedication(context);
      if (r == null || !context.mounted) return;
      await createCatalogItemOrWarn(
        context,
        ref,
        patientId: patient.id,
        kind: kind,
        name: r.$1,
        defaultDose: r.$2,
      );
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    CatalogItem item,
  ) async {
    final l = context.l10n;
    if (kind == CatalogKind.trigger) {
      final name = await promptText(
        context,
        title: l.rename,
        label: l.name,
        initial: item.name,
      );
      if (name == null || name.isEmpty) return;
      await _update(ref, item.copyWith(name: name));
    } else {
      final r = await promptMedication(
        context,
        initialName: item.name,
        initialDose: item.defaultDose,
      );
      if (r == null) return;
      await _update(
        ref,
        item.copyWith(
          name: r.$1,
          defaultDose: r.$2,
          clearDefaultDose: r.$2 == null || r.$2!.isEmpty,
        ),
      );
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    CatalogItem item,
  ) async {
    final l = context.l10n;
    final repo = ref.read(repositoryProvider);
    final used = await repo.catalogItemUsageCount(item.id);
    if (!context.mounted) return;
    if (used > 0) {
      showSnack(context, l.cannotDeleteUsedItem);
      return;
    }
    final ok = await confirmDialog(
      context,
      title: '${l.delete} "${item.name}"?',
      message: l.deleteConfirmGeneric,
      confirmLabel: l.delete,
      destructive: true,
    );
    if (!ok) return;
    await repo.deleteCatalogItem(item.id);
    ref.read(dataVersionProvider.notifier).bump();
  }
}
