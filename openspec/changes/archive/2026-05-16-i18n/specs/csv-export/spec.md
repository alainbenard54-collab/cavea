## MODIFIED Requirements

### Requirement: Contenu et format du fichier CSV exporté
Le CSV exporté SHALL contenir toutes les colonnes de la table `bouteilles` dans l'ordre suivant : `id`, `domaine`, `appellation`, `millesime`, `couleur`, `cru`, `contenance`, `emplacement`, `date_entree`, `date_sortie`, `prix_achat`, `garde_min`, `garde_max`, `commentaire_entree`, `note_degus`, `commentaire_degus`, `fournisseur_nom`, `fournisseur_infos`, `producteur`, `updated_at`. Le fichier SHALL être encodé en UTF-8 avec BOM. Les valeurs null SHALL être représentées par un champ vide. Les valeurs contenant le séparateur ou des guillemets SHALL être entourées de guillemets doubles (guillemets internes doublés). **Les en-têtes de colonnes SHALL être traduits selon la locale active au moment de l'export** : `CsvExportService.buildCsv()` SHALL recevoir un paramètre `AppLocalizations l10n` et utiliser des clés ARB dédiées (`csvHeaderId`, `csvHeaderDomaine`, `csvHeaderAppellation`, etc.) pour les libellés de la ligne d'en-tête. Les valeurs des données elles-mêmes restent inchangées (valeurs DB brutes).

#### Scenario: Colonne updated_at présente
- **WHEN** l'utilisateur exporte
- **THEN** chaque ligne du CSV contient la valeur ISO8601 de `updated_at` pour cette bouteille

#### Scenario: Valeur nulle
- **WHEN** un champ nullable (ex. `date_sortie`) est null pour une bouteille
- **THEN** la cellule correspondante est vide dans le CSV

#### Scenario: Valeur contenant le séparateur
- **WHEN** un champ textuel contient le caractère séparateur choisi
- **THEN** la valeur est entourée de guillemets doubles dans le CSV

#### Scenario: Encodage BOM
- **WHEN** le fichier est ouvert dans Excel ou LibreOffice sans configuration d'encodage
- **THEN** les caractères accentués s'affichent correctement

#### Scenario: En-têtes en français
- **WHEN** la locale active est `fr` et l'utilisateur exporte
- **THEN** la première ligne du CSV contient "Domaine", "Appellation", "Millésime", etc. en français

#### Scenario: En-têtes en anglais
- **WHEN** la locale active est `en` et l'utilisateur exporte
- **THEN** la première ligne du CSV contient "Domain", "Appellation", "Vintage", etc. en anglais

#### Scenario: Valeurs DB inchangées quelle que soit la locale
- **WHEN** une bouteille a `couleur = "Rouge"` en base et la locale est `en`
- **THEN** la cellule couleur dans le CSV contient `"Rouge"` (valeur DB brute, pas "Red")
