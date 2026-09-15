import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/formatting.dart';
import 'patient_form_screen.dart';

class PatientsScreen extends ConsumerWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final patients = ref.watch(patientsProvider);
    final selectedId = ref.watch(selectedPatientProvider).value?.id;
    return Scaffold(
      appBar: AppBar(title: Text(l.patients)),
      body: patients.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorBox(e),
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, i) {
            final p = list[i];
            return ListTile(
              leading: CircleAvatar(child: Text(_initials(p.name))),
              title: Text(p.name),
              subtitle: Text('${p.condition} · ${l.ageYears(p.ageInYears())}'),
              trailing: p.id == selectedId
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () async {
                await ref.read(selectedPatientIdProvider.notifier).select(p.id);
                if (context.mounted) Navigator.pop(context);
              },
              onLongPress: () => _showActions(context, ref, p),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PatientFormScreen()),
        ),
        icon: const Icon(Icons.person_add),
        label: Text(l.newPatient),
      ),
    );
  }

  void _showActions(BuildContext context, WidgetRef ref, Patient p) {
    final l = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l.edit),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PatientFormScreen(patient: p),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(ctx).colorScheme.error,
              ),
              title: Text(l.delete),
              onTap: () async {
                Navigator.pop(ctx);
                final ok = await confirmDialog(
                  context,
                  title: l.deletePatientTitle,
                  message: l.deletePatientMessage(p.name),
                  confirmLabel: l.delete,
                  destructive: true,
                );
                if (!ok) return;
                await ref.read(repositoryProvider).deletePatient(p.id);
                ref.read(dataVersionProvider.notifier).bump();
              },
            ),
          ],
        ),
      ),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

/// Botão do cabeçalho que mostra o paciente atual e abre a troca rápida.
class PatientSelectorButton extends ConsumerWidget {
  const PatientSelectorButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final patient = ref.watch(selectedPatientProvider).value;
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      icon: const Icon(Icons.person_outline),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              patient?.name ?? l.selectPatient,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
      onPressed: () => _openSelector(context, ref),
    );
  }

  Future<void> _openSelector(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final patients = await ref.read(patientsProvider.future);
    if (!context.mounted) return;
    final current = ref.read(selectedPatientProvider).value?.id;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                l.selectPatient,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            for (final p in patients)
              ListTile(
                leading: CircleAvatar(child: Text(_initials(p.name))),
                title: Text(p.name),
                subtitle: Text(p.condition),
                selected: p.id == current,
                onTap: () async {
                  Navigator.pop(ctx);
                  await ref
                      .read(selectedPatientIdProvider.notifier)
                      .select(p.id);
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.manage_accounts_outlined),
              title: Text(l.managePatients),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PatientsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
