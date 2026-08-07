## Context

Voir proposal.md - Why. La logique de validation est aujourd'hui dupliquée indépendamment dans 5 fichiers (regex quasi identique, 2 variantes : par-segment vs hiérarchie-complète-en-une-regex), sans aucun widget/validateur partagé dans `lib/shared/`. L'import CSV (`csv_parser.dart`) n'a actuellement aucune validation sur ce champ. Le style d'erreur déjà en place dans `_rowToCompanion` est un tuple `(BouteillesCompanion?, String?)`, avec des messages texte simples (non l10n) du type `'millesime invalide : "$millesimeStr"'`.

## Goals / Non-Goals

**Goals:**
- Une seule source de vérité pour le format emplacement, testable indépendamment de l'UI.
- Le nouveau jeu de caractères (`_`, `-`) actif partout où le format est vérifié, y compris à l'import CSV.
- Le message d'erreur d'une ligne CSV rejetée pour emplacement invalide nomme explicitement `emplacement` (demande explicite de l'utilisateur), pas un message générique.

**Non-Goals:**
- Ne pas rendre `emplacement` obligatoire à l'import CSV — aujourd'hui une valeur vide est acceptée (bouteille sans emplacement assigné), ce comportement est préservé. Seul le *format*, quand la valeur est non vide, est désormais vérifié.
- Ne pas ajouter d'autres caractères que `_` et `-` (pas d'apostrophe, parenthèses, etc. — décision déjà tranchée avec l'utilisateur).
- Ne pas toucher `bulk-select` (déplacement en lot depuis la vue Emplacements/Stock) — sa spec ne documente aucun texte de format, aucune modification nécessaire côté spec ; le fichier `deplacer_batch_sheet.dart` migre quand même vers le validateur partagé côté code (couvert par `bottle-actions`, qui documente déjà l'action Déplacer).
- Ne pas changer le séparateur ` > ` ni la règle "doit commencer par un caractère alphanumérique".

## Decisions

**Nouveau fichier `lib/shared/emplacement_validator.dart`, classe statique pure Dart (pas de dépendance Flutter/BuildContext/l10n).**
```dart
class EmplacementValidator {
  static final RegExp _levelPattern =
      RegExp(r'^[a-zA-ZÀ-ÿ0-9][a-zA-ZÀ-ÿ0-9 _-]*$');

  static bool isValid(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    final levels = trimmed.split(' > ');
    return levels.every((level) => _levelPattern.hasMatch(level.trim()));
  }
}
```
Alternative écartée : garder deux fonctions séparées (une par-segment, une hiérarchie-complète-en-regex) pour coller exactement aux deux variantes actuelles. Rejetée : elles sont fonctionnellement équivalentes (la variante "hiérarchie complète" de `bulk_add_controller.dart` n'est qu'un encodage regex de la même règle par-segment) ; une seule implémentation par-segment est plus lisible et plus facile à faire évoluer (ex. futur changement de séparateur).

**API volontairement minimale : `isValid(String) → bool`, pas de retour de message localisé.**
Chaque appelant UI garde son propre `TextFormField.validator` et son propre texte localisé (`l10n.deplacerFormatError` ou `l10n.repartitionFormatError` — les deux messages restent distincts et ne sont pas fusionnés, décision non demandée par l'utilisateur). Le validateur partagé ne fait que la vérification de format ; il ne connaît ni le contexte d'affichage ni la langue.

**Wiring des 5 call sites existants** : chacun remplace sa regex locale + sa fonction de validation par un appel à `EmplacementValidator.isValid(value)`, en conservant son propre message d'erreur localisé et sa propre gestion de champ vide (le champ vide reste "obligatoire" côté formulaire, ce n'est pas ce validateur qui gère cette règle — `isValid('')` retourne `false`, ce qui est cohérent avec le comportement actuel de rejet d'une chaîne vide).

**Wiring de l'import CSV (`csv_parser.dart::_rowToCompanion`)** : ajout d'un check après les champs obligatoires existants (domaine/appellation/millesime/couleur), uniquement si `emplacement` est non vide :
```dart
if (emplacement.isNotEmpty && !EmplacementValidator.isValid(emplacement)) {
  return (null, 'emplacement invalide : "$emplacement"');
}
```
Le préfixe `'emplacement invalide : '` répond explicitement à la demande de l'utilisateur (message qui nomme le champ en cause) et suit le style déjà utilisé pour `millesime invalide : "$millesimeStr"` — cohérence avec les messages existants du même fichier.

**Mise à jour des ARB `deplacerFormatError` / `repartitionFormatError` (fr + en)** pour mentionner `_` et `-` dans le texte affiché — sinon le message resterait factuellement incomplet une fois le format élargi.

**Mise à jour CLAUDE.md** (règle métier `emplacement`, section Data model) pour lister `_` et `-` dans les caractères acceptés.

## Risks / Trade-offs

- [Un des 5 call sites avait une nuance de comportement non capturée par la simple regex, ex. trim différent] → Mitigation : relire précisément chaque fonction de validation actuelle avant de la remplacer (déjà fait lors de l'investigation initiale — toutes les 5 suivent exactement le même schéma trim + split + regex-per-segment), et couvrir `EmplacementValidator` par des tests unitaires dédiés (le projet a une suite de tests existante, convention à suivre : `test/` + helpers).
- [Centraliser crée un point unique de défaillance : un bug dans `EmplacementValidator` affecte 6 endroits d'un coup au lieu d'un seul] → Accepté, c'est l'objectif recherché (cohérence). Mitigation : tests unitaires exhaustifs sur les cas limites (début non-alphanumérique, underscore/tiret en début vs milieu, séparateur mal formé, niveaux vides entre deux `>`).

## Amendement (post-code-review, avant archivage)

Un `/code-review` lancé après l'implémentation initiale (14/14 tâches) a trouvé 2 bugs réels dans `EmplacementValidator` et signalé une dette d'architecture. Discutés et tranchés avec l'utilisateur avant archivage.

**Bug 1 — le trim par segment masque un séparateur mal formé.** `isValid()` applique `level.trim()` sur chaque segment après `trimmed.split(' > ')`. Un séparateur mal formé (double espace, tab) produit un segment avec un espace résiduel (`" Rack"` pour `"Cave >  Rack"`), que ce trim efface silencieusement avant le test de regex — la valeur est acceptée à tort, alors que le format documenté dans les specs (« Séparateur obligatoire : ` > ` ») l'exclut. Fix : supprimer le trim par segment ; ne garder que le trim global de la valeur entière (déjà nécessaire pour tolérer un espace en tête/fin de saisie utilisateur). Chaque segment issu du split doit désormais matcher `_levelPattern` tel quel — un séparateur non exactement `' > '` (espace manquant, en trop, tab) fait échouer le split proprement et le segment restant ne matche plus.

**Bug 2 — la plage Unicode `À-ÿ` matche à tort `×` et `÷`.** Cette plage, utilisée pour couvrir les lettres accentuées, inclut par erreur deux points de code non-lettres : `×` (U+00D7) et `÷` (U+00F7). Fix : exclure ces deux caractères du pattern (négation explicite dans la classe de caractères).

**Dette actée — séparateur dupliqué, décision : centraliser maintenant.** `' > '` était déjà codé en dur dans `lib/features/locations/location_node.dart` (5 occurrences), indépendamment du validateur. Décision utilisateur : ne pas différer. `EmplacementValidator` expose une constante `separator` (`' > '`) ; `location_node.dart` l'utilise désormais aux 5 endroits au lieu du littéral dupliqué.

**Décision explicite — données existantes non conformes : aucune action.** Pas de migration automatique, pas d'écran de diagnostic. Les bouteilles déjà en base avec un emplacement non conforme (notamment issues d'anciens imports CSV non validés, avant ce change) restent inchangées ; elles ne deviennent conformes que si l'utilisateur les modifie via une écriture normale (Déplacer / Modifier la fiche / Bulk-add), qui applique déjà `EmplacementValidator.isValid`. Le rapport d'import CSV existant (compteur + détail des lignes rejetées, déjà visible côté UI, non silencieux) est jugé suffisant comme garde-fou ; pas de traitement spécial pour les ré-imports de backups legacy. Le jeu de caractères accepté reste inchangé (pas d'ajout d'apostrophe, parenthèses, etc. pour accommoder les données legacy).
