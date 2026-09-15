import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/formatting.dart';
import '../catalogs/catalog_widgets.dart';

/// Cria ou edita uma crise.
class OccurrenceFormScreen extends ConsumerStatefulWidget {
  const OccurrenceFormScreen({
    super.key,
    required this.patient,
    this.occurrence,
    this.endNow = false,
  });

  final Patient patient;
  final Occurrence? occurrence;

  /// Abre o formulário já com o término preenchido com agora.
  final bool endNow;

  @override
  ConsumerState<OccurrenceFormScreen> createState() =>
      _OccurrenceFormScreenState();
}

class _OccurrenceFormScreenState extends ConsumerState<OccurrenceFormScreen> {
  late DateTime _start;
  DateTime? _end;
  Intensity _intensity = Intensity.moderate;
  late Set<String> _triggers;
  late final TextEditingController _notes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final o = widget.occurrence;
    final now = _roundToMinute(DateTime.now());
    _start = o?.startedAt ?? now;
    // Ao encerrar, garante término posterior ao início mesmo que a crise
    // tenha sido registrada há menos de um minuto.
    final endNow = now.isAfter(_start)
        ? now
        : _start.add(const Duration(minutes: 1));
    _end = o?.endedAt ?? (widget.endNow ? endNow : null);
    _intensity = o?.intensity ?? Intensity.moderate;
    _triggers = {...?o?.triggerIds};
    _notes = TextEditingController(text: o?.notes ?? '');
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  static DateTime _roundToMinute(DateTime d) =>
      DateTime(d.year, d.month, d.day, d.hour, d.minute);

  Future<void> _save() async {
    final l = context.l10n;
    if (_end != null && !_end!.isAfter(_start)) {
      showSnack(context, l.endMustBeAfterStart);
      return;
    }
    final repo = ref.read(repositoryProvider);
    if (widget.occurrence == null && _end == null) {
      final ongoing = await repo.listOngoingOccurrences(widget.patient.id);
      if (ongoing.isNotEmpty && mounted) {
        final ok = await confirmDialog(
          context,
          title: l.anotherOngoingTitle,
          message: l.anotherOngoingMessage,
          confirmLabel: l.registerAnyway,
        );
        if (!ok) return;
      }
    }
    if (!mounted) return;
    setState(() => _saving = true);
    if (widget.occurrence == null) {
      await repo.createOccurrence(
        patientId: widget.patient.id,
        startedAt: _start,
        endedAt: _end,
        intensity: _intensity,
        triggerIds: _triggers.toList(),
        notes: _notes.text,
      );
    } else {
      await repo.updateOccurrence(
        widget.occurrence!.copyWith(
          startedAt: _start,
          endedAt: _end,
          clearEnd: _end == null,
          intensity: _intensity,
          triggerIds: _triggers.toList(),
          notes: _notes.text.trim(),
        ),
      );
    }
    ref.read(dataVersionProvider.notifier).bump();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final ok = await confirmDialog(
      context,
      title: l.deleteCrisisTitle,
      message: l.deleteConfirmGeneric,
      confirmLabel: l.delete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await ref.read(repositoryProvider).deleteOccurrence(widget.occurrence!.id);
    ref.read(dataVersionProvider.notifier).bump();
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _addTrigger([String? preset]) async {
    final l = context.l10n;
    final name =
        preset ?? await promptText(context, title: l.newTrigger, label: l.name);
    if (name == null || name.isEmpty || !mounted) return;
    final item = await createCatalogItemOrWarn(
      context,
      ref,
      patientId: widget.patient.id,
      kind: CatalogKind.trigger,
      name: name,
    );
    if (item != null) setState(() => _triggers.add(item.id));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final editing = widget.occurrence != null;
    final triggers = ref.watch(
      catalogProvider((
        patientId: widget.patient.id,
        kind: CatalogKind.trigger,
        onlyActive: false,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? l.editCrisis : l.newCrisis),
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
            label: l.start,
            value: _start,
            onChanged: (v) => setState(() => _start = v),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.setEnd),
            subtitle: _end == null
                ? Text(l.ongoing)
                : Text(
                    '${l.duration}: ${Fmt.duration(context, _end!.difference(_start))}',
                  ),
            value: _end != null,
            onChanged: (v) => setState(() {
              _end = v
                  ? _roundToMinute(DateTime.now()).isAfter(_start)
                        ? _roundToMinute(DateTime.now())
                        : _start.add(const Duration(hours: 1))
                  : null;
            }),
          ),
          if (_end != null)
            DateTimeField(
              label: l.end,
              value: _end!,
              onChanged: (v) => setState(() => _end = v),
            ),
          const SizedBox(height: 16),
          Text(l.intensity, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<Intensity>(
            segments: [
              for (final i in Intensity.values)
                ButtonSegment(
                  value: i,
                  label: Text(Fmt.intensity(context, i)),
                  icon: Icon(
                    Icons.circle,
                    size: 12,
                    color: Fmt.intensityColor(i, scheme),
                  ),
                ),
            ],
            selected: {_intensity},
            onSelectionChanged: (s) => setState(() => _intensity = s.first),
          ),
          const SizedBox(height: 20),
          Text(l.triggers, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          triggers.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => ErrorBox(e),
            data: (list) {
              final visible = list
                  .where((t) => t.active || _triggers.contains(t.id))
                  .toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      FilterChip(
                        label: Text(l.unknownTrigger),
                        selected: _triggers.isEmpty,
                        onSelected: (_) => setState(_triggers.clear),
                      ),
                      for (final t in visible)
                        FilterChip(
                          label: Text(t.name),
                          selected: _triggers.contains(t.id),
                          onSelected: (v) => setState(() {
                            if (v) {
                              _triggers.add(t.id);
                            } else {
                              _triggers.remove(t.id);
                            }
                          }),
                        ),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 18),
                        label: Text(l.newTrigger),
                        onPressed: () => _addTrigger(),
                      ),
                    ],
                  ),
                  if (list.isEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      l.triggerSuggestions,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final s in suggestedTriggers(context))
                          ActionChip(
                            label: Text(s),
                            onPressed: () => _addTrigger(s),
                          ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _notes,
            maxLines: 4,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l.notes,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(onPressed: _saving ? null : _save, child: Text(l.save)),
        ],
      ),
    );
  }
}
