import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/formatting.dart';

/// Cria ou edita um paciente. Devolve o paciente salvo.
class PatientFormScreen extends ConsumerStatefulWidget {
  const PatientFormScreen({super.key, this.patient, this.onboarding = false});

  final Patient? patient;
  final bool onboarding;

  @override
  ConsumerState<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends ConsumerState<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _condition;
  DateTime? _birthDate;
  Sex? _sex;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.patient?.name ?? '');
    _condition = TextEditingController(text: widget.patient?.condition ?? '');
    _birthDate = widget.patient?.birthDate;
    _sex = widget.patient?.sex;
  }

  @override
  void dispose() {
    _name.dispose();
    _condition.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 10, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (d != null) setState(() => _birthDate = d);
  }

  Future<void> _save() async {
    final l = context.l10n;
    final valid = _formKey.currentState!.validate();
    if (_birthDate == null || _sex == null) {
      setState(() {});
      if (!valid) return;
      showSnack(context, l.requiredField);
      return;
    }
    if (!valid) return;
    setState(() => _saving = true);
    final repo = ref.read(repositoryProvider);
    Patient saved;
    if (widget.patient == null) {
      saved = await repo.createPatient(
        name: _name.text,
        birthDate: _birthDate!,
        sex: _sex!,
        condition: _condition.text,
      );
      await ref.read(selectedPatientIdProvider.notifier).select(saved.id);
    } else {
      saved = widget.patient!.copyWith(
        name: _name.text.trim(),
        birthDate: _birthDate,
        sex: _sex,
        condition: _condition.text.trim(),
      );
      await repo.updatePatient(saved);
    }
    ref.read(dataVersionProvider.notifier).bump();
    // No primeiro uso esta tela é a raiz: a lista de pacientes deixa de estar
    // vazia e o app troca sozinho para a interface principal.
    if (mounted && !widget.onboarding) Navigator.pop(context, saved);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final editing = widget.patient != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.onboarding
              ? l.onboardingTitle
              : (editing ? l.editPatient : l.newPatient),
        ),
        automaticallyImplyLeading: !widget.onboarding,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.onboarding) ...[
              Text(
                l.onboardingSubtitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l.privacyPromise)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l.name),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l.requiredField : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: InputDecoration(
                labelText: l.birthDate,
                errorText: _birthDate == null && _formKey.currentState != null
                    ? l.requiredField
                    : null,
              ),
              child: InkWell(
                onTap: _pickBirthDate,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.cake_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _birthDate == null
                            ? l.selectDate
                            : '${Fmt.date(context, _birthDate!)}  ·  ${l.ageYears(_ageOf(_birthDate!))}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: InputDecoration(
                labelText: l.sex,
                border: InputBorder.none,
                errorText: _sex == null && _formKey.currentState != null
                    ? l.requiredField
                    : null,
              ),
              child: Wrap(
                spacing: 8,
                children: [
                  for (final s in Sex.values)
                    ChoiceChip(
                      label: Text(Fmt.sex(context, s)),
                      selected: _sex == s,
                      onSelected: (_) => setState(() => _sex = s),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _condition,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l.condition,
                hintText: l.conditionHint,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l.requiredField : null,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(widget.onboarding ? l.continueLabel : l.save),
            ),
          ],
        ),
      ),
    );
  }

  static int _ageOf(DateTime birth) {
    final now = DateTime.now();
    var age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }
}
