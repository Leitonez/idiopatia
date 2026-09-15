import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/formatting.dart';
import '../catalogs/catalog_widgets.dart';

/// Registra ou edita um uso de medicamento.
class MedicationUseFormScreen extends ConsumerStatefulWidget {
  const MedicationUseFormScreen({super.key, required this.patient, this.use});

  final Patient patient;
  final MedicationUse? use;

  @override
  ConsumerState<MedicationUseFormScreen> createState() =>
      _MedicationUseFormScreenState();
}

class _MedicationUseFormScreenState
    extends ConsumerState<MedicationUseFormScreen> {
  late DateTime _takenAt;
  String? _medicationId;
  String? _occurrenceId;
  bool _occurrenceInitialized = false;
  late final TextEditingController _dose;
  late final TextEditingController _notes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.use;
    final now = DateTime.now();
    _takenAt =
        u?.takenAt ??
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    _medicationId = u?.medicationId;
    _occurrenceId = u?.occurrenceId;
    _occurrenceInitialized = u != null;
    _dose = TextEditingController(text: u?.dose ?? '');
    _notes = TextEditingController(text: u?.notes ?? '');
  }

  @override
  void dispose() {
    _dose.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _addMedication() async {
    final r = await promptMedication(context);
    if (r == null || !mounted) return;
    final item = await createCatalogItemOrWarn(
      context,
      ref,
      patientId: widget.patient.id,
      kind: CatalogKind.medication,
      name: r.$1,
      defaultDose: r.$2,
    );
    if (item != null) _select(item);
  }

  void _select(CatalogItem item) {
    setState(() {
      _medicationId = item.id;
      if (_dose.text.trim().isEmpty &&
          (item.defaultDose?.isNotEmpty ?? false)) {
        _dose.text = item.defaultDose!;
      }
    });
  }

  Future<void> _save() async {
    final l = context.l10n;
    if (_medicationId == null) {
      showSnack(context, l.selectMedication);
      return;
    }
    if (_dose.text.trim().isEmpty) {
      showSnack(context, '${l.dose}: ${l.requiredField}');
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(repositoryProvider);
    if (widget.use == null) {
      await repo.createMedicationUse(
        patientId: widget.patient.id,
        takenAt: _takenAt,
        medicationId: _medicationId!,
        dose: _dose.text,
        occurrenceId: _occurrenceId,
        notes: _notes.text,
      );
    } else {
      await repo.updateMedicationUse(
        widget.use!.copyWith(
          takenAt: _takenAt,
          medicationId: _medicationId,
          dose: _dose.text.trim(),
          occurrenceId: _occurrenceId,
          clearOccurrence: _occurrenceId == null,
          notes: _notes.text.trim(),
        ),
      );
    }
    ref.read(dataVersionProvider.notifier).bump();
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final ok = await confirmDialog(
      context,
      title: l.deleteMedicationUseTitle,
      message: l.deleteConfirmGeneric,
      confirmLabel: l.delete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await ref.read(repositoryProvider).deleteMedicationUse(widget.use!.id);
    ref.read(dataVersionProvider.notifier).bump();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final editing = widget.use != null;
    final meds = ref.watch(
      catalogProvider((
        patientId: widget.patient.id,
        kind: CatalogKind.medication,
        onlyActive: false,
      )),
    );
    final occurrences = ref.watch(occurrencesProvider(widget.patient.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? l.editMedicationUse : l.registerMedication),
        actions: [
          if (editing)
            IconButton(
              tooltip: l.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          DateTimeField(
            label: l.dateTime,
            value: _takenAt,
            onChanged: (v) => setState(() => _takenAt = v),
          ),
          const SizedBox(height: 16),
          Text(l.medication, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          meds.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => ErrorBox(e),
            data: (list) {
              final visible = list
                  .where((m) => m.active || m.id == _medicationId)
                  .toList();
              return Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final m in visible)
                    ChoiceChip(
                      label: Text(m.name),
                      selected: _medicationId == m.id,
                      onSelected: (_) => _select(m),
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18),
                    label: Text(l.newMedication),
                    onPressed: _addMedication,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _dose,
            decoration: InputDecoration(
              labelText: l.dose,
              hintText: l.doseHint,
            ),
          ),
          const SizedBox(height: 16),
          occurrences.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => ErrorBox(e),
            data: (list) {
              final ongoing = list.where((o) => o.isOngoing).toList();
              if (!_occurrenceInitialized) {
                _occurrenceInitialized = true;
                if (ongoing.isNotEmpty) _occurrenceId = ongoing.first.id;
              }
              final candidates = <Occurrence>[
                ...ongoing,
                ...list.where((o) => !o.isOngoing).take(10),
              ];
              if (_occurrenceId != null &&
                  !candidates.any((o) => o.id == _occurrenceId)) {
                final extra = list.where((o) => o.id == _occurrenceId);
                candidates.addAll(extra);
              }
              return DropdownButtonFormField<String?>(
                value: _occurrenceId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l.linkedCrisis),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l.noLinkedCrisis),
                  ),
                  for (final o in candidates)
                    DropdownMenuItem<String?>(
                      value: o.id,
                      child: Text(
                        '${l.crisisStartedAt(Fmt.dateTime(context, o.startedAt))}'
                        '${o.isOngoing ? ' · ${l.ongoing}' : ''}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _occurrenceId = v),
              );
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notes,
            maxLines: 3,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l.notes),
          ),
          const SizedBox(height: 28),
          FilledButton(onPressed: _saving ? null : _save, child: Text(l.save)),
        ],
      ),
    );
  }
}
