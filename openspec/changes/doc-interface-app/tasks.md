## 1. Restructuration docs/

- [x] 1.1 Créer `docs/fr/README.md` : index complet en français avec tableau des 13 scénarios et liens relatifs vers `fr/NN-slug.md` (PC + Android)
- [x] 1.2 Créer `docs/en/README.md` : full index in English with table of all 13 scenarios and relative links to `en/NN-slug.md` files (PC + Android)
- [x] 1.3 Remplacer `docs/README.md` par une page d'entrée minimaliste bilingue : titre "Cavea — Documentation" + deux liens (`🇫🇷 Documentation en français → fr/` et `🇬🇧 English documentation → en/`) (PC + Android)

## 2. Clé l10n

- [x] 2.1 Ajouter la clé `aboutDocumentation` avec valeur `"Documentation"` dans `lib/l10n/app_fr.arb` (après `aboutConfidentialite`) (PC + Android)
- [x] 2.2 Ajouter la clé `aboutDocumentation` avec valeur `"Documentation"` dans `lib/l10n/app_en.arb` (après `aboutConfidentialite`) (PC + Android)
- [ ] 2.3 Lancer `flutter gen-l10n` pour régénérer `lib/l10n/app_localizations*.dart` et vérifier l'absence d'erreur (PC + Android)

## 3. Bouton Documentation dans le dialog À propos

- [x] 3.1 Dans `lib/features/settings/settings_screen.dart`, ajouter un `TextButton` libellé `l10n.aboutDocumentation` entre "Confidentialité" et "Licences" dans les `actions` de l'`AlertDialog` "À propos" (PC + Android)
- [x] 3.2 Implémenter l'action du bouton : détecter `Localizations.localeOf(dialogContext).languageCode`, construire l'URL (`/en/` ou `/fr/`), appeler `launchUrl` avec `LaunchMode.externalApplication` (PC + Android)

## 4. Vérification

- [ ] 4.1 Vérifier que `flutter analyze` passe sans erreur après les modifications Dart (PC) — à lancer manuellement
- [ ] 4.2 Ouvrir l'app, naviguer vers Paramètres → À propos → vérifier la présence du bouton "Documentation" (PC) — test manuel
- [ ] 4.3 Appuyer sur "Documentation" en langue FR → vérifier l'ouverture de `https://alainbenard54-collab.github.io/cavea/fr/` dans le navigateur (PC) — test manuel
- [ ] 4.4 Appuyer sur "Documentation" en langue EN → vérifier l'ouverture de `https://alainbenard54-collab.github.io/cavea/en/` dans le navigateur (PC) — test manuel
- [ ] 4.5 Vérifier que `docs/fr/README.md` et `docs/en/README.md` sont correctement servis par GitHub Pages aux URLs `/fr/` et `/en/` (PC — navigateur) — test manuel
