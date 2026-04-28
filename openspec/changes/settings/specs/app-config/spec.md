## ADDED Requirements

### Requirement: Stockage des valeurs par défaut bulk-add
`ConfigService` SHALL stocker et restituer deux valeurs par défaut pour le formulaire d'ajout en lot : `couleurDefaut` et `contenanceDefaut`. Ces valeurs SHALL être persistées dans SharedPreferences et retourner des valeurs hardcodées si absentes.

#### Scenario: Lecture avec valeurs configurées
- **WHEN** `ConfigService` est chargé et que les clés `couleur_defaut` / `contenance_defaut` existent dans SharedPreferences
- **THEN** `configService.couleurDefaut` retourne la valeur persistée, idem pour `contenanceDefaut`

#### Scenario: Lecture sans valeurs configurées (première utilisation)
- **WHEN** `ConfigService` est chargé et qu'aucune clé `couleur_defaut` / `contenance_defaut` n'existe dans SharedPreferences
- **THEN** `configService.couleurDefaut` retourne "Rouge" et `configService.contenanceDefaut` retourne "75 cl"

#### Scenario: Sauvegarde des valeurs par défaut
- **WHEN** l'utilisateur modifie `couleurDefaut` ou `contenanceDefaut` dans l'écran Paramètres
- **THEN** `ConfigService.saveBulkAddDefaults()` persiste les nouvelles valeurs dans SharedPreferences sans modifier `storageMode` ni `dbPath`
