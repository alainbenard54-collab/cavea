## ADDED Requirements

### Requirement: Bouton Documentation dans le dialog À propos
L'application SHALL afficher un bouton "Documentation" dans le dialog "À propos" accessible depuis l'écran Paramètres.

Le bouton SHALL ouvrir la documentation en ligne dans le navigateur externe du système via `url_launcher` avec `LaunchMode.externalApplication`.

L'URL ouverte SHALL dépendre de la langue courante de l'application :
- langue `en` → `https://cavea.abapps.fr/en/`
- toute autre langue (dont `fr`) → `https://cavea.abapps.fr/fr/`

Le bouton SHALL être positionné entre le bouton "Confidentialité" et le bouton "Licences" dans les actions du dialog.

#### Scenario: Ouverture documentation en français
- **WHEN** l'app est en langue française et l'utilisateur appuie sur "Documentation" dans le dialog À propos
- **THEN** le navigateur externe s'ouvre sur `https://cavea.abapps.fr/fr/`

#### Scenario: Ouverture documentation en anglais
- **WHEN** l'app est en langue anglaise et l'utilisateur appuie sur "Documentation" dans le dialog À propos
- **THEN** le navigateur externe s'ouvre sur `https://cavea.abapps.fr/en/`

#### Scenario: Bouton visible dans le dialog
- **WHEN** l'utilisateur ouvre le dialog "À propos" depuis l'écran Paramètres
- **THEN** trois boutons texte sont visibles : "Confidentialité", "Documentation", "Licences", plus le bouton de fermeture
