## ADDED Requirements

### Requirement: Barre d'actions contextuelle en mode sélection
L'application SHALL afficher une barre d'actions contextuelle fixée en bas de l'écran quand le mode sélection est actif. Cette barre SHALL proposer les actions Déplacer, Consommer et Annuler. En mode lecture seule (SyncReadOnly), les actions Déplacer et Consommer SHALL être désactivées.

#### Scenario: Barre visible en mode sélection
- **WHEN** le mode sélection est activé
- **THEN** une barre contextuelle apparaît en bas de l'écran avec le compteur, les boutons "Déplacer", "Consommer" et "Annuler"

#### Scenario: Barre cachée hors mode sélection
- **WHEN** le mode sélection est inactif
- **THEN** la barre contextuelle n'est pas affichée

#### Scenario: Actions désactivées en mode lecture seule
- **WHEN** le mode sélection est actif et SyncReadOnly est actif
- **THEN** les boutons Déplacer et Consommer sont grisés et non interactifs, un texte "Mode lecture seule" est affiché dans la barre, le bouton Annuler reste actif

---

### Requirement: Action Déplacer en lot
L'application SHALL permettre de modifier l'emplacement de toutes les bouteilles sélectionnées en une seule opération. Le formulaire SHALL proposer le même champ emplacement avec autocomplétion que l'action unitaire.

#### Scenario: Ouverture du formulaire Déplacer en lot
- **WHEN** l'utilisateur appuie sur "Déplacer" dans la barre contextuelle (N bouteilles sélectionnées)
- **THEN** un BottomSheet s'ouvre avec un champ emplacement (autocomplétion activée) et les boutons Confirmer / Annuler

#### Scenario: Déplacement valide en lot
- **WHEN** l'utilisateur saisit ou sélectionne un emplacement valide et confirme
- **THEN** `emplacement` est mis à jour sur les N bouteilles sélectionnées en une transaction, `date_sortie` reste null pour toutes, le mode sélection est désactivé

#### Scenario: Emplacement invalide en lot
- **WHEN** l'utilisateur confirme un emplacement ne respectant pas le format hiérarchique
- **THEN** un message d'erreur s'affiche sous le champ, la sauvegarde est bloquée (comportement identique à l'action unitaire)

#### Scenario: Annuler Déplacer en lot
- **WHEN** l'utilisateur appuie sur Annuler dans le formulaire Déplacer en lot
- **THEN** le BottomSheet se ferme, la sélection est conservée, le mode sélection reste actif

---

### Requirement: Action Consommer en lot
L'application SHALL permettre de consommer toutes les bouteilles sélectionnées en une seule opération. Le formulaire SHALL proposer les mêmes champs que l'action Consommer unitaire (date, note /10 optionnelle, commentaire optionnel).

#### Scenario: Ouverture du formulaire Consommer en lot
- **WHEN** l'utilisateur appuie sur "Consommer" dans la barre contextuelle (N bouteilles sélectionnées)
- **THEN** un BottomSheet s'ouvre avec un DatePicker (défaut = aujourd'hui), un champ note /10 optionnel, un champ commentaire optionnel, et les boutons Confirmer / Annuler

#### Scenario: Consommation en lot à la date du jour
- **WHEN** l'utilisateur confirme sans modifier la date
- **THEN** `date_sortie` = date du jour, `note_degus` et `commentaire_degus` sont enregistrés (ou null si non renseignés) sur les N bouteilles sélectionnées en une transaction, les bouteilles disparaissent du stock, le mode sélection est désactivé

#### Scenario: Consommation en lot à une date passée
- **WHEN** l'utilisateur modifie la date via le DatePicker avant de confirmer
- **THEN** `date_sortie` = date choisie sur les N bouteilles, même valeur pour toutes

#### Scenario: Annuler Consommer en lot
- **WHEN** l'utilisateur appuie sur Annuler dans le formulaire Consommer en lot
- **THEN** le BottomSheet se ferme, la sélection est conservée, le mode sélection reste actif

---

### Requirement: Atomicité des opérations en lot
Les opérations Déplacer en lot et Consommer en lot SHALL être exécutées dans une transaction SQLite. Si l'opération échoue partiellement, aucune modification SHALL être persistée.

#### Scenario: Succès de la transaction
- **WHEN** l'utilisateur confirme une action en lot sur N bouteilles
- **THEN** toutes les N bouteilles sont mises à jour atomiquement dans une seule transaction

#### Scenario: Échec de la transaction
- **WHEN** une erreur survient pendant l'écriture batch en base
- **THEN** aucune des N bouteilles n'est modifiée, un message d'erreur est affiché à l'utilisateur
