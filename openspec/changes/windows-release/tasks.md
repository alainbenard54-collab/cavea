## 1. Bump de version

- [x] 1.1 Dans `pubspec.yaml`, remplacer `version: 0.1.0+1` par `version: 1.0.0+1` (PC + Android)
- [x] 1.2 Dans `lib/l10n/app_fr.arb`, remplacer `"aboutVersion": "Version 0.1.0"` par `"Version 1.0.0"` (PC + Android)
- [x] 1.3 Dans `lib/l10n/app_en.arb`, remplacer `"aboutVersion": "Version 0.1.0"` par `"Version 1.0.0"` (PC + Android)
- [ ] 1.4 Lancer `flutter gen-l10n` pour régénérer les fichiers app_localizations*.dart (PC — à exécuter manuellement)

## 2. Script Inno Setup

- [x] 2.1 Créer le répertoire `windows/packaging/` (PC)
- [x] 2.2 Créer `windows/packaging/cavea.iss` avec AppId GUID fixe, source `build\windows\x64\runner\Release\*`, icône, licence, raccourcis bureau+menu démarrer, MinVersion 10.0.17763, output `output\Cavea-{version}-windows-setup.exe`, Pascal Script [Code] proposant la suppression du dossier AppData Cavea à la désinstallation (PC)
- [ ] 2.3 Tester le build local : lancer `flutter build windows --release` sur Windows (PC — à exécuter manuellement)
- [ ] 2.4 Tester Inno Setup local : lancer `iscc windows\packaging\cavea.iss` sur Windows et vérifier que l'exe est produit dans `windows\packaging\output\` (PC — à exécuter manuellement)
- [ ] 2.5 Tester l'installation : exécuter l'exe produit, vérifier raccourcis, lancement de l'app, présence dans Programmes (PC — à exécuter manuellement)

## 3. Workflow GitHub Actions

- [x] 3.1 Créer le répertoire `.github/workflows/` (PC)
- [x] 3.2 Créer `.github/workflows/release-windows.yml` : déclencheur `push tags v*`, runner `windows-latest`, steps flutter setup + build + iscc + upload release asset (PC)

## 4. Template de release notes

- [x] 4.1 Créer `.github/RELEASE_TEMPLATE_WINDOWS.md` avec texte bilingue fr/en : description, prérequis système, instructions installation (SmartScreen warning), modes Local et Partagé, lien documentation, note mises à jour (PC)

## 5. Commit, tag et publication

- [ ] 5.1 Lancer `flutter analyze` et vérifier 0 issue (PC — à exécuter manuellement)
- [ ] 5.2 Committer tous les fichiers nouveaux et modifiés (PC — fait par Claude après validation flutter gen-l10n)
- [ ] 5.3 Pousser le commit sur master (PC — fait par Claude)
- [ ] 5.4 Créer et pousser le tag : `git tag v1.0.0 && git push origin v1.0.0` (PC — à exécuter manuellement après validation de l'installateur local)
- [ ] 5.5 Vérifier que le workflow GitHub Actions se déclenche et termine sans erreur (PC — GitHub UI)
- [ ] 5.6 Vérifier que `Cavea-1.0.0-windows-setup.exe` est attaché à la release GitHub v1.0.0 (PC — GitHub UI)
- [ ] 5.7 Copier le contenu de `.github/RELEASE_TEMPLATE_WINDOWS.md` dans la description de la release GitHub v1.0.0 (PC — GitHub UI)
