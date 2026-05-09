## ADDED Requirements

### Requirement: BottomSheet actions scrollable en paysage
Le contenu du BottomSheet d'actions SHALL être enveloppé dans un `SingleChildScrollView` pour éviter tout débordement vertical en orientation paysage sur Android.

#### Scenario: Ouverture BottomSheet en paysage Android
- **WHEN** l'utilisateur appuie sur une bouteille en paysage Android
- **THEN** le BottomSheet s'affiche sans débordement de pixel, son contenu est accessible par scroll si la hauteur disponible est insuffisante

#### Scenario: Contenu complet visible en portrait
- **WHEN** le BottomSheet s'ouvre en portrait
- **THEN** toutes les actions sont visibles sans scroll (comportement inchangé)
