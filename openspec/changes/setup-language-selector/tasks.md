## 1. Implémentation

- [x] 1.1 Dans `lib/features/setup/setup_screen.dart`, convertir `_ModeChoiceStep` de `StatelessWidget` en `ConsumerWidget` (ajouter `WidgetRef ref` au `build`, importer `flutter_riverpod` et `locale_provider.dart`) (PC + Android)
- [x] 1.2 Ajouter l'import de `locale_provider.dart` dans `setup_screen.dart` (PC + Android)
- [x] 1.3 En haut du `build` de `_ModeChoiceStep`, récupérer la langue courante : `final lang = Localizations.localeOf(context).languageCode;` (PC + Android)
- [x] 1.4 Ajouter un `SegmentedButton<String>` centré avant le titre `setupWelcome` : segments "Français" (`fr`) et "English" (`en`), valeur sélectionnée = `lang`, `onSelectionChanged` appelle `ref.read(localeProvider.notifier).setLocale(code)` (PC + Android)

## 2. Vérification

- [ ] 2.1 Lancer `flutter analyze` — 0 issue (PC — à exécuter manuellement)
- [ ] 2.2 Supprimer la config Cavea (ou tester sur machine sans config), lancer l'app, vérifier que le sélecteur FR/EN apparaît en haut de l'écran de démarrage (PC — test manuel)
- [ ] 2.3 Tapper "English" → vérifier que toute l'interface bascule immédiatement en anglais (PC — test manuel)
- [ ] 2.4 Terminer la configuration, redémarrer l'app, vérifier que la langue anglaise est conservée (PC — test manuel)
- [ ] 2.5 Vérifier que l'écran "À propos" affiche "Version 1.0.0" en anglais (PC — test manuel)
