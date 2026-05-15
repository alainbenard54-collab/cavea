// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/config_service.dart';
import '../../core/locale_formatting.dart';
import '../../data/database.dart';
import '../../services/sync_service.dart';
import '../../data/providers.dart';
import '../../l10n/l10n.dart';
import 'bulk_add_controller.dart';
import 'widgets/repartition_row.dart';

const _uuid = Uuid();

class BulkAddScreen extends ConsumerStatefulWidget {
  const BulkAddScreen({super.key});

  @override
  ConsumerState<BulkAddScreen> createState() => _BulkAddScreenState();
}

class _BulkAddScreenState extends ConsumerState<BulkAddScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  List<String> _emplacements = [];
  List<String> _couleurs = [];
  List<String> _domaines = [];
  List<String> _appellations = [];
  List<String> _fournisseurs = [];
  List<String> _contenances = [];
  List<String> _crus = [];
  late final TextEditingController _qtCtrl;

  @override
  void initState() {
    super.initState();
    _qtCtrl = TextEditingController(text: '1');
    // Listes pré-remplies depuis la config pour éviter dropdowns vides sur cave neuve
    _couleurs = configService.refCouleurs;
    _contenances = configService.refContenances;
    _crus = configService.refCrus;
    _loadLists();
  }

  @override
  void dispose() {
    _qtCtrl.dispose();
    super.dispose();
  }

  // Ref list items en premier, puis valeurs DB non encore présentes.
  List<String> _mergeWithRef(List<String> dbValues, List<String> refValues) {
    final seen = <String>{};
    final result = <String>[];
    for (final v in refValues) {
      if (seen.add(v)) result.add(v);
    }
    for (final v in dbValues) {
      if (v.isNotEmpty && seen.add(v)) result.add(v);
    }
    return result;
  }

  Future<void> _loadLists() async {
    final dao = ref.read(bouteillesDaoProvider);
    final results = await Future.wait([
      dao.getDistinctEmplacements(),
      dao.getAllDistinctCouleurs(),
      dao.getDistinctDomaines(),
      dao.getAllDistinctAppellations(),
      dao.getDistinctFournisseurs(),
      dao.getAllDistinctContenances(),
      dao.getAllDistinctCrus(),
    ]);
    if (mounted) {
      setState(() {
        _emplacements = results[0];
        _couleurs = _mergeWithRef(results[1], configService.refCouleurs);
        _domaines = results[2];
        _appellations = results[3];
        _fournisseurs = results[4];
        _contenances = _mergeWithRef(results[5], configService.refContenances);
        _crus = _mergeWithRef(results[6], configService.refCrus);
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = context.l10n;
    final state = ref.read(bulkAddProvider);
    if (!state.isValid) return;

    final gardeMinVal = int.tryParse(state.gardeMin.trim());
    final gardeMaxVal = int.tryParse(state.gardeMax.trim());
    if (gardeMinVal != null && gardeMaxVal != null && gardeMinVal > gardeMaxVal) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bulkAddGardeError),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (state.gardeMin.trim().isEmpty || state.gardeMax.trim().isEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final dl10n = ctx.l10n;
          return AlertDialog(
            title: Text(dl10n.bulkAddGardeDialogTitle),
            content: Text(dl10n.bulkAddGardeDialogBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(dl10n.bulkAddRetourGarde),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(dl10n.bulkAddConfirmerSansGarde),
              ),
            ],
          );
        },
      );
      if (confirm != true) return;
    }

    setState(() => _submitting = true);

    final dateStr =
        '${state.dateEntree.year.toString().padLeft(4, '0')}-'
        '${state.dateEntree.month.toString().padLeft(2, '0')}-'
        '${state.dateEntree.day.toString().padLeft(2, '0')}';
    final now = DateTime.now().toIso8601String();

    final bouteilles = <BouteillesCompanion>[];
    for (final groupe in state.groupes) {
      for (var i = 0; i < groupe.quantite; i++) {
        bouteilles.add(BouteillesCompanion(
          id: Value(_uuid.v4()),
          domaine: Value(state.domaine.trim()),
          appellation: Value(state.appellation.trim()),
          millesime: Value(int.tryParse(state.millesime) ?? 0),
          couleur: Value(state.couleur.trim()),
          cru: Value(state.cru.trim().isNotEmpty ? state.cru.trim() : null),
          contenance: Value(state.contenance.trim()),
          prixAchat: Value(double.tryParse(state.prixAchat.replaceAll(',', '.'))),
          gardeMin: Value(int.tryParse(state.gardeMin)),
          gardeMax: Value(int.tryParse(state.gardeMax)),
          commentaireEntree: Value(state.commentaireEntree.trim().isNotEmpty
              ? state.commentaireEntree.trim()
              : null),
          fournisseurNom: Value(state.fournisseurNom.trim().isNotEmpty
              ? state.fournisseurNom.trim()
              : null),
          fournisseurInfos: Value(state.fournisseurInfos.trim().isNotEmpty
              ? state.fournisseurInfos.trim()
              : null),
          producteur: Value(state.producteur.trim().isNotEmpty
              ? state.producteur.trim()
              : null),
          dateEntree: Value(dateStr),
          updatedAt: Value(now),
          emplacement: Value(groupe.emplacement.trim()),
        ));
      }
    }

    try {
      await ref.read(bouteillesDaoProvider).insertBouteilles(bouteilles);
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorGeneric(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fermer l'écran si le mode passe en lecture seule pendant la saisie
    final l10n = context.l10n;

    ref.listen<SyncState>(syncServiceProvider, (prev, next) {
      if (next is SyncReadOnly && prev is! SyncReadOnly && mounted) {
        context.go('/');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.bulkAddCancelled),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final state = ref.watch(bulkAddProvider);
    final notifier = ref.read(bulkAddProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bulkAddTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(l10n.bulkAddSectionIdentite),
            _AutocompleteField(
              label: l10n.bulkAddFieldDomaine,
              initialValue: state.domaine,
              suggestions: _domaines,
              onChanged: (v) => notifier.set((s) => s.copyWith(domaine: v)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.validationObligatoire : null,
            ),
            const SizedBox(height: 10),
            _AutocompleteField(
              label: l10n.bulkAddFieldAppellation,
              initialValue: state.appellation,
              suggestions: _appellations,
              onChanged: (v) => notifier.set((s) => s.copyWith(appellation: v)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.validationObligatoire : null,
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: _field(
                  label: l10n.bulkAddFieldMillesime,
                  initialValue: state.millesime,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) =>
                      notifier.set((s) => s.copyWith(millesime: v)),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.validationObligatoire : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _CouleurField(couleurs: _couleurs)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: _DropdownOptionalField(
                  label: l10n.bulkAddFieldCru,
                  choices: _crus,
                  initialValue: state.cru,
                  onChanged: (v) => notifier.set((s) => s.copyWith(cru: v)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DropdownOptionalField(
                  label: l10n.bulkAddFieldContenance,
                  choices: _contenances,
                  initialValue: state.contenance,
                  onChanged: (v) =>
                      notifier.set((s) => s.copyWith(contenance: v)),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            _SectionHeader(l10n.bulkAddSectionGarde),
            Row(children: [
              Expanded(
                child: _field(
                  label: l10n.bulkAddFieldGardeMin,
                  initialValue: state.gardeMin,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) =>
                      notifier.set((s) => s.copyWith(gardeMin: v)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  label: l10n.bulkAddFieldGardeMax,
                  initialValue: state.gardeMax,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (v) =>
                      notifier.set((s) => s.copyWith(gardeMax: v)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  label: l10n.bulkAddFieldPrix,
                  initialValue: state.prixAchat,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) =>
                      notifier.set((s) => s.copyWith(prixAchat: v)),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            _SectionHeader(l10n.bulkAddSectionFournisseur),
            _AutocompleteField(
              label: l10n.bulkAddFieldFournisseur,
              initialValue: state.fournisseurNom,
              suggestions: _fournisseurs,
              onChanged: (v) =>
                  notifier.set((s) => s.copyWith(fournisseurNom: v)),
            ),
            const SizedBox(height: 10),
            _field(
              label: l10n.bulkAddFieldFournisseurInfos,
              initialValue: state.fournisseurInfos,
              onChanged: (v) =>
                  notifier.set((s) => s.copyWith(fournisseurInfos: v)),
            ),
            const SizedBox(height: 10),
            _field(
              label: l10n.bulkAddFieldProducteur,
              initialValue: state.producteur,
              onChanged: (v) =>
                  notifier.set((s) => s.copyWith(producteur: v)),
            ),
            const SizedBox(height: 16),

            _SectionHeader(l10n.bulkAddSectionCommentaire),
            _field(
              label: l10n.bulkAddFieldCommentaire,
              initialValue: state.commentaireEntree,
              maxLines: 3,
              onChanged: (v) =>
                  notifier.set((s) => s.copyWith(commentaireEntree: v)),
            ),
            const SizedBox(height: 10),
            _DateEntreeField(),
            const SizedBox(height: 16),

            _SectionHeader(l10n.bulkAddSectionRepartition),
            Row(children: [
              Text(l10n.bulkAddQuantiteTotal),
              const SizedBox(width: 12),
              SizedBox(
                width: 72,
                child: TextFormField(
                  controller: _qtCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (v) =>
                      notifier.setQuantiteTotal(int.tryParse(v) ?? 1),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            ...state.groupes.asMap().entries.map((entry) {
              final i = entry.key;
              final groupe = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RepartitionRow(
                  index: i,
                  groupe: groupe,
                  emplacements: _emplacements,
                  onChanged: (g) => notifier.updateGroupe(i, g),
                  onRemove: state.groupes.length > 1
                      ? () => notifier.removeGroupe(i)
                      : null,
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                Icon(
                  state.sommeGroupes == state.quantiteTotal
                      ? Icons.check_circle_outline
                      : Icons.warning_amber_rounded,
                  size: 16,
                  color: state.sommeGroupes == state.quantiteTotal
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.bulkAddAssignees(state.sommeGroupes, state.quantiteTotal),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: state.sommeGroupes == state.quantiteTotal
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                ),
              ]),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.bulkAddAjouterEmplacement),
              onPressed: notifier.addGroupe,
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: (_submitting || !state.isValid) ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.bulkAddConfirmer(state.quantiteTotal)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

Widget _field({
  required String label,
  required ValueChanged<String> onChanged,
  String? Function(String?)? validator,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  int maxLines = 1,
  String? initialValue,
}) {
  return TextFormField(
    initialValue: initialValue,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      isDense: true,
    ),
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    maxLines: maxLines,
    onChanged: onChanged,
    validator: validator,
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _CouleurField extends ConsumerStatefulWidget {
  final List<String> couleurs;
  const _CouleurField({required this.couleurs});

  @override
  ConsumerState<_CouleurField> createState() => _CouleurFieldState();
}

class _CouleurFieldState extends ConsumerState<_CouleurField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final currentCouleur = ref.read(bulkAddProvider).couleur;
    final def = configService.couleurDefaut;
    final initial = currentCouleur.isNotEmpty
        ? currentCouleur
        : (widget.couleurs.contains(def) ? def : '');
    _ctrl = TextEditingController(text: initial);

    if (currentCouleur.isEmpty && initial.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(bulkAddProvider.notifier).set((s) => s.copyWith(couleur: initial));
        }
      });
    }

    _ctrl.addListener(() {
      ref.read(bulkAddProvider.notifier).set((s) => s.copyWith(couleur: _ctrl.text));
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    return FormField<String>(
      validator: (_) => _ctrl.text.trim().isEmpty ? l10n.validationObligatoire : null,
      builder: (field) => DropdownMenu<String>(
        controller: _ctrl,
        enableFilter: true,
        requestFocusOnTap: true,
        expandedInsets: EdgeInsets.zero,
        label: Text(l10n.bulkAddFieldCouleur),
        errorText: field.errorText,
        onSelected: (v) {
          if (v != null) _ctrl.text = v;
        },
        dropdownMenuEntries: widget.couleurs
            .map((c) => DropdownMenuEntry(
                  value: c,
                  label: ConfigService.displayCouleur(c, locale),
                ))
            .toList(),
      ),
    );
  }
}

class _DateEntreeField extends ConsumerStatefulWidget {
  const _DateEntreeField();

  @override
  ConsumerState<_DateEntreeField> createState() => _DateEntreeFieldState();
}

class _DateEntreeFieldState extends ConsumerState<_DateEntreeField> {
  Future<void> _pick() async {
    final state = ref.read(bulkAddProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: state.dateEntree,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      ref.read(bulkAddProvider.notifier).set((s) => s.copyWith(dateEntree: picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = ref.watch(bulkAddProvider).dateEntree;
    final label = formatDate(date, context);
    return OutlinedButton.icon(
      icon: const Icon(Icons.calendar_today, size: 16),
      label: Text(context.l10n.bulkAddDateEntreeLabel(label)),
      onPressed: _pick,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _DropdownOptionalField extends StatefulWidget {
  final String label;
  final List<String> choices;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _DropdownOptionalField({
    required this.label,
    required this.choices,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_DropdownOptionalField> createState() => _DropdownOptionalFieldState();
}

class _DropdownOptionalFieldState extends State<_DropdownOptionalField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _ctrl.addListener(() => widget.onChanged(_ctrl.text));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      controller: _ctrl,
      enableFilter: true,
      requestFocusOnTap: true,
      expandedInsets: EdgeInsets.zero,
      label: Text(widget.label),
      onSelected: (v) {
        if (v != null) _ctrl.text = v;
      },
      trailingIcon: const Icon(Icons.arrow_drop_down),
      selectedTrailingIcon: const Icon(Icons.arrow_drop_up),
      dropdownMenuEntries: widget.choices
          .map((c) => DropdownMenuEntry(value: c, label: c))
          .toList(),
    );
  }
}

class _AutocompleteField extends StatefulWidget {
  final String label;
  final String initialValue;
  final List<String> suggestions;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;

  const _AutocompleteField({
    required this.label,
    required this.initialValue,
    required this.suggestions,
    required this.onChanged,
    this.validator,
  });

  @override
  State<_AutocompleteField> createState() => _AutocompleteFieldState();
}

class _AutocompleteFieldState extends State<_AutocompleteField> {
  late final TextEditingController _ctrl;
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    final q = v.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? []
          : widget.suggestions
              .where((s) => s.toLowerCase().contains(q) && s != v)
              .toList();
    });
    widget.onChanged(v);
  }

  void _select(String s) {
    _ctrl.text = s;
    _ctrl.selection =
        TextSelection.fromPosition(TextPosition(offset: s.length));
    setState(() => _filtered = []);
    widget.onChanged(s);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _ctrl,
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          validator: widget.validator,
          onChanged: _onChanged,
        ),
        if (_filtered.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 160),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: _filtered
                  .map(
                    (s) => InkWell(
                      onTap: () => _select(s),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Text(s, style: theme.textTheme.bodyMedium),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
