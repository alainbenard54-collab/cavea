// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config_service.dart';
import '../../data/database.dart';
import '../../data/providers.dart';

class BottleEditScreen extends ConsumerStatefulWidget {
  final String id;

  const BottleEditScreen({super.key, required this.id});

  @override
  ConsumerState<BottleEditScreen> createState() => _BottleEditScreenState();
}

class _BottleEditScreenState extends ConsumerState<BottleEditScreen> {
  final _formKey = GlobalKey<FormState>();

  Bouteille? _bouteille;
  bool _loading = true;
  bool _saving = false;

  DateTime _dateEntree = DateTime.now();

  final _domaineCtrl = TextEditingController();
  final _appellationCtrl = TextEditingController();
  final _millesimeCtrl = TextEditingController();
  final _couleurCtrl = TextEditingController();
  final _cruCtrl = TextEditingController();
  final _contenanceCtrl = TextEditingController();
  final _emplacementCtrl = TextEditingController();
  final _prixAchatCtrl = TextEditingController();
  final _gardeMinCtrl = TextEditingController();
  final _gardeMaxCtrl = TextEditingController();
  final _commentaireEntreeCtrl = TextEditingController();
  final _fournisseurNomCtrl = TextEditingController();
  final _fournisseurInfosCtrl = TextEditingController();
  final _producteurCtrl = TextEditingController();

  List<String> _couleurs = [];
  List<String> _domaines = [];
  List<String> _appellations = [];
  List<String> _crus = [];
  List<String> _contenances = [];
  List<String> _fournisseurs = [];
  List<String> _emplacements = [];

  // Valeurs initiales pour les boutons restore
  String _domaineInitial = '';
  String _appellationInitial = '';
  String _emplacementInitial = '';
  String _fournisseurNomInitial = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _domaineCtrl.dispose();
    _appellationCtrl.dispose();
    _millesimeCtrl.dispose();
    _couleurCtrl.dispose();
    _cruCtrl.dispose();
    _contenanceCtrl.dispose();
    _emplacementCtrl.dispose();
    _prixAchatCtrl.dispose();
    _gardeMinCtrl.dispose();
    _gardeMaxCtrl.dispose();
    _commentaireEntreeCtrl.dispose();
    _fournisseurNomCtrl.dispose();
    _fournisseurInfosCtrl.dispose();
    _producteurCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final dao = ref.read(bouteillesDaoProvider);
    final bouteille = await dao.getBouteilleById(widget.id);
    if (!mounted) return;

    if (bouteille == null) {
      setState(() => _loading = false);
      return;
    }

    _domaineCtrl.text = bouteille.domaine;
    _appellationCtrl.text = bouteille.appellation;
    _millesimeCtrl.text = bouteille.millesime > 0 ? bouteille.millesime.toString() : '';
    _couleurCtrl.text = bouteille.couleur;
    _cruCtrl.text = bouteille.cru ?? '';
    _contenanceCtrl.text = bouteille.contenance;
    _emplacementCtrl.text = bouteille.emplacement;
    _prixAchatCtrl.text = bouteille.prixAchat?.toString() ?? '';
    _gardeMinCtrl.text = bouteille.gardeMin?.toString() ?? '';
    _gardeMaxCtrl.text = bouteille.gardeMax?.toString() ?? '';
    _commentaireEntreeCtrl.text = bouteille.commentaireEntree ?? '';
    _fournisseurNomCtrl.text = bouteille.fournisseurNom ?? '';
    _fournisseurInfosCtrl.text = bouteille.fournisseurInfos ?? '';
    _producteurCtrl.text = bouteille.producteur ?? '';

    final results = await Future.wait([
      dao.getDistinctDomaines(),
      dao.getAllDistinctAppellations(),
      dao.getAllDistinctCrus(),
      dao.getAllDistinctContenances(),
      dao.getDistinctFournisseurs(),
      dao.getDistinctEmplacements(),
      dao.getAllDistinctCouleurs(),
    ]);
    if (!mounted) return;

    final refCouleurs = configService.refCouleurs;
    final dbCouleurs = results[6];
    final allCouleurs = List<String>.from(refCouleurs);
    for (final c in dbCouleurs) {
      if (!allCouleurs.contains(c)) allCouleurs.add(c);
    }
    if (!allCouleurs.contains(bouteille.couleur)) {
      allCouleurs.insert(0, bouteille.couleur);
    }

    setState(() {
      _bouteille = bouteille;
      _dateEntree = DateTime.tryParse(bouteille.dateEntree) ?? DateTime.now();
      _domaineInitial = bouteille.domaine;
      _appellationInitial = bouteille.appellation;
      _emplacementInitial = bouteille.emplacement;
      _fournisseurNomInitial = bouteille.fournisseurNom ?? '';
      _loading = false;
      _domaines = results[0];
      _appellations = results[1];
      _crus = _mergeWithRef(results[2], configService.refCrus);
      _contenances = _mergeWithRef(results[3], configService.refContenances);
      _fournisseurs = results[4];
      _emplacements = results[5];
      _couleurs = allCouleurs;
    });
  }

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

  static final _levelRe = RegExp(r'^[a-zA-ZÀ-ÿ0-9][a-zA-ZÀ-ÿ0-9 ]*$');

  String? _validateEmplacement(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Emplacement obligatoire';
    final levels = trimmed.split(' > ');
    if (levels.any((l) => !_levelRe.hasMatch(l.trim()))) {
      return 'Format : "Niveau1" ou "Niveau1 > Niveau2 > …"\n'
          '(lettres, chiffres, espaces ; séparateur " > ")';
    }
    return null;
  }

  String _formatDateISO(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String _formatDateDisplay(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateEntree,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _dateEntree = picked);
    }
  }

  void _cancel() {
    FocusScope.of(context).unfocus();
    context.pop();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final gardeMinVal = int.tryParse(_gardeMinCtrl.text.trim());
    final gardeMaxVal = int.tryParse(_gardeMaxCtrl.text.trim());

    if (gardeMinVal != null && gardeMaxVal != null && gardeMinVal > gardeMaxVal) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Garde min doit être ≤ garde max.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
      return;
    }

    if (_gardeMinCtrl.text.trim().isEmpty || _gardeMaxCtrl.text.trim().isEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Garde non renseignée'),
          content: const Text(
            'La garde min ou max n\'est pas renseignée.\n\n'
            'La maturité de cette bouteille ne pourra pas être '
            'déterminée dans la vue Stock.\n\n'
            'Confirmer quand même sans ces données ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Retour — saisir la garde'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirmer sans garde'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _saving = true);

    final b = _bouteille!;
    final companion = BouteillesCompanion(
      id: Value(b.id),
      domaine: Value(_domaineCtrl.text.trim()),
      appellation: Value(_appellationCtrl.text.trim()),
      millesime: Value(int.tryParse(_millesimeCtrl.text.trim()) ?? 0),
      couleur: Value(_couleurCtrl.text.trim()),
      cru: Value(_cruCtrl.text.trim().isNotEmpty ? _cruCtrl.text.trim() : null),
      contenance: Value(_contenanceCtrl.text.trim()),
      emplacement: Value(_emplacementCtrl.text.trim()),
      dateEntree: Value(_formatDateISO(_dateEntree)),
      prixAchat: Value(double.tryParse(_prixAchatCtrl.text.replaceAll(',', '.'))),
      gardeMin: Value(int.tryParse(_gardeMinCtrl.text.trim())),
      gardeMax: Value(int.tryParse(_gardeMaxCtrl.text.trim())),
      commentaireEntree: Value(_commentaireEntreeCtrl.text.trim().isNotEmpty
          ? _commentaireEntreeCtrl.text.trim()
          : null),
      fournisseurNom: Value(_fournisseurNomCtrl.text.trim().isNotEmpty
          ? _fournisseurNomCtrl.text.trim()
          : null),
      fournisseurInfos: Value(_fournisseurInfosCtrl.text.trim().isNotEmpty
          ? _fournisseurInfosCtrl.text.trim()
          : null),
      producteur: Value(_producteurCtrl.text.trim().isNotEmpty
          ? _producteurCtrl.text.trim()
          : null),
      // Champs protégés — préservés depuis la bouteille chargée
      dateSortie: Value(b.dateSortie),
      noteDegus: Value(b.noteDegus),
      commentaireDegus: Value(b.commentaireDegus),
      updatedAt: Value(DateTime.now().toIso8601String()),
    );

    try {
      await ref.read(bouteillesDaoProvider).updateBouteille(companion);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_bouteille == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modifier la fiche')),
        body: const Center(child: Text('Bouteille introuvable.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la fiche'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _cancel,
            child: const Text('Annuler'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enregistrer'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader('Identité'),
            _AutocompleteField(
              label: 'Domaine *',
              controller: _domaineCtrl,
              suggestions: _domaines,
              initialValue: _domaineInitial,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
            ),
            const SizedBox(height: 10),
            _AutocompleteField(
              label: 'Appellation *',
              controller: _appellationCtrl,
              suggestions: _appellations,
              initialValue: _appellationInitial,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _millesimeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Millésime *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FilterDropdownField(
                  label: 'Couleur *',
                  choices: _couleurs,
                  controller: _couleurCtrl,
                  required: true,
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: _FilterDropdownField(
                  label: 'Cru',
                  choices: _crus,
                  controller: _cruCtrl,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FilterDropdownField(
                  label: 'Contenance',
                  choices: _contenances,
                  controller: _contenanceCtrl,
                ),
              ),
            ]),
            const SizedBox(height: 16),

            _SectionHeader('Emplacement'),
            _AutocompleteField(
              label: 'Emplacement *',
              controller: _emplacementCtrl,
              suggestions: _emplacements,
              initialValue: _emplacementInitial,
              validator: _validateEmplacement,
            ),
            const SizedBox(height: 16),

            _SectionHeader('Garde & prix'),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _gardeMinCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Garde min (ans)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _gardeMaxCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Garde max (ans)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _prixAchatCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Prix achat (€)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            _SectionHeader('Fournisseur'),
            _AutocompleteField(
              label: 'Nom fournisseur',
              controller: _fournisseurNomCtrl,
              suggestions: _fournisseurs,
              initialValue: _fournisseurNomInitial,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _fournisseurInfosCtrl,
              decoration: const InputDecoration(
                labelText: 'Infos fournisseur',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _producteurCtrl,
              decoration: const InputDecoration(
                labelText: 'Producteur',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),

            _SectionHeader('Commentaire & date'),
            TextFormField(
              controller: _commentaireEntreeCtrl,
              decoration: const InputDecoration(
                labelText: "Commentaire d'entrée",
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text("Date d'entrée : ${_formatDateDisplay(_dateEntree)}"),
              onPressed: _pickDate,
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enregistrer'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Widgets locaux ────────────────────────────────────────────────────────────

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

/// DropdownMenu filtrable avec saisie libre — utilisé pour couleur (required),
/// cru et contenance (optionnels). Même composant que BulkAddScreen.
class _FilterDropdownField extends StatefulWidget {
  final String label;
  final List<String> choices;
  final TextEditingController controller;
  final bool required;

  const _FilterDropdownField({
    required this.label,
    required this.choices,
    required this.controller,
    this.required = false,
  });

  @override
  State<_FilterDropdownField> createState() => _FilterDropdownFieldState();
}

class _FilterDropdownFieldState extends State<_FilterDropdownField> {
  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: widget.required
          ? (_) => widget.controller.text.trim().isEmpty ? 'Obligatoire' : null
          : null,
      builder: (field) => DropdownMenu<String>(
        controller: widget.controller,
        enableFilter: true,
        requestFocusOnTap: true,
        expandedInsets: EdgeInsets.zero,
        label: Text(widget.label),
        errorText: field.errorText,
        onSelected: (v) {
          if (v != null) widget.controller.text = v;
        },
        dropdownMenuEntries: widget.choices
            .map((c) => DropdownMenuEntry(value: c, label: c))
            .toList(),
      ),
    );
  }
}

/// Champ texte avec autocomplétion en overlay (visible au-dessus du clavier)
/// et bouton restore (↩) quand la valeur diffère de la valeur initiale.
class _AutocompleteField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final List<String> suggestions;
  final String? Function(String?)? validator;
  final String? initialValue;

  const _AutocompleteField({
    required this.label,
    required this.controller,
    required this.suggestions,
    this.validator,
    this.initialValue,
  });

  @override
  State<_AutocompleteField> createState() => _AutocompleteFieldState();
}

class _AutocompleteFieldState extends State<_AutocompleteField> {
  late final FocusNode _focusNode;
  final _fieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _restore() {
    widget.controller.text = widget.initialValue ?? '';
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.controller.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (textEditingValue) {
        final q = textEditingValue.text.toLowerCase();
        if (q.isEmpty) return const Iterable<String>.empty();
        return widget.suggestions
            .where((s) => s.toLowerCase().contains(q) && s != textEditingValue.text);
      },
      displayStringForOption: (s) => s,
      fieldViewBuilder: (_, __, ___, onFieldSubmitted) => TextFormField(
        key: _fieldKey,
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: widget.initialValue != null
              ? ValueListenableBuilder<TextEditingValue>(
                  valueListenable: widget.controller,
                  builder: (_, value, __) => value.text != widget.initialValue
                      ? IconButton(
                          icon: const Icon(Icons.restore, size: 18),
                          tooltip: 'Restaurer la valeur initiale',
                          onPressed: _restore,
                        )
                      : const SizedBox.shrink(),
                )
              : null,
        ),
        validator: widget.validator,
        onFieldSubmitted: (_) => onFieldSubmitted(),
      ),
      optionsViewBuilder: (_, onSelected, options) {
        final fieldBox =
            _fieldKey.currentContext?.findRenderObject() as RenderBox?;
        final fieldWidth = fieldBox?.size.width ?? 240.0;
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(4),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: fieldWidth, maxHeight: 160),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (_, i) {
                  final option = options.elementAt(i);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Text(option,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
