## 1. Dépendances et configuration du projet

- [x] 1.1 Ajouter toutes les dépendances runtime et dev dans `pubspec.yaml` (drift, drift_flutter, flutter_riverpod, go_router, shared_preferences, file_picker, flutter_dotenv, uuid, path_provider, path, build_runner, drift_dev) — PC + Android
- [x] 1.2 Lancer `flutter pub get` et vérifier l'absence d'erreur de résolution — PC + Android
- [x] 1.3 Ajouter les permissions Android dans `android/app/src/main/AndroidManifest.xml` pour `file_picker` (READ_EXTERNAL_STORAGE / READ_MEDIA_*) — Android uniquement

## 2. Modèle de données drift

- [x] 2.1 Créer `lib/data/tables/bouteilles.dart` : définition drift de la table `Bouteilles` avec tous les champs (id TEXT PK, domaine, appellation, millesime INTEGER, couleur, cru nullable, contenance, emplacement, date_entree, date_sortie nullable, prix_achat REAL nullable, garde_min INTEGER nullable, garde_max INTEGER nullable, commentaire_entree nullable, note_degus REAL nullable, commentaire_degus nullable, fournisseur_nom nullable, fournisseur_infos nullable, producteur nullable, updated_at) — PC + Android
- [x] 2.2 Créer `lib/data/database.dart` : classe `AppDatabase` annotée `@DriftDatabase(tables: [Bouteilles])`, migration initiale schéma v1, ouverture via `NativeDatabase(File(path))` — PC + Android
- [x] 2.3 Lancer `flutter pub run build_runner build` et vérifier la génération de `database.g.dart` — PC + Android

## 3. DAO et providers Riverpod

- [x] 3.1 Créer `lib/data/daos/bouteille_dao.dart` : `BouteilleDao` avec `watchStock()` (Stream, filtre date_sortie NULL/vide, tri domaine+millesime), `insertBouteille()`, `updateBouteille()`, `getBouteilleById()` — PC + Android
- [x] 3.2 Créer `lib/data/providers.dart` : `appDatabaseProvider` (Provider<AppDatabase>) et `bouteillesDaoProvider` (Provider<BouteilleDao>) — PC + Android

## 4. Service de configuration

- [x] 4.1 Créer `lib/core/config_service.dart` : classe `ConfigService` avec `load()` (lit SharedPreferences), `loadFromEnv()` (lit `.env` via flutter_dotenv, Windows uniquement), `save()` (persiste dans SharedPreferences), `isConfigured` getter — PC + Android
- [x] 4.2 Vérifier que `loadFromEnv()` est no-op (sans erreur) si `.env` est absent — PC uniquement

## 5. Wizard de premier lancement

- [x] 5.1 Créer `lib/features/setup/setup_screen.dart` : écran Material 3 avec 3 étapes — choix du mode (Mode 1 actif, Modes 2/3 désactivés avec mention "Non disponible dans cette version"), saisie du chemin + bouton "Parcourir" (file picker dossier), écran de confirmation — PC + Android
- [x] 5.2 Créer `lib/features/setup/setup_controller.dart` : StateNotifier Riverpod gérant l'état du wizard, appel `ConfigService.save()`, création `cave.db` si absent — PC + Android
- [x] 5.3 Vérifier que la validation du chemin affiche une erreur si le dossier n'existe pas — PC + Android

## 6. Navigation et point d'entrée

- [x] 6.1 Créer `lib/app/router.dart` : go_router avec routes `/setup` et `/` (écran principal placeholder), redirection initiale selon `ConfigService.isConfigured` — PC + Android
- [x] 6.2 Créer `lib/app/theme.dart` : Material 3 theme minimal (couleurs neutres, pas de personnalisation avancée) — PC + Android
- [x] 6.3 Mettre à jour `lib/main.dart` : `ProviderScope`, chargement `ConfigService` avant `runApp`, `CaveApp` avec `MaterialApp.router` — PC + Android
- [ ] 6.4 Lancer `flutter run -d windows` et vérifier que le wizard s'affiche au premier lancement, que la config est persistée, et que les relances suivantes vont directement à l'écran principal — PC uniquement

## 7. Feature import CSV

- [x] 7.1 Créer `lib/features/import_csv/csv_parser.dart` : fonction pure `parseCsv(String content) → List<BouteilleCompanion>` — séparateur `;`, encodage UTF-8, UUID généré si colonne `id` vide, lignes malformées comptées comme erreurs — PC + Android
- [x] 7.2 Créer `lib/features/import_csv/import_service.dart` : `ImportService.run(List<BouteilleCompanion>, {bool overwrite}) → ImportResult` — logique insert/update/skip selon UUID + flag overwrite, retourne compteurs — PC + Android
- [x] 7.3 Créer `lib/features/import_csv/import_csv_screen.dart` : bouton "Choisir un fichier CSV" (file_picker filtré `.csv`), case à cocher "Écraser les existants", bouton "Importer", affichage du rapport (X insérées · Y mises à jour · Z ignorées · W erreurs) — PC + Android
- [x] 7.4 Ajouter la route `/import-csv` dans `router.dart` et un bouton d'accès depuis l'écran principal placeholder — PC + Android
- [ ] 7.5 Tester l'import de `cave_clean.csv` (828 lignes) : vérifier le rapport et l'absence de doublon sur un second import avec case "écraser" décochée — PC uniquement
