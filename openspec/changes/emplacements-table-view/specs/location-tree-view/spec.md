## MODIFIED Requirements

### Requirement: Liste de bouteilles avec badge maturité
En tapant sur un nœud feuille ou sur "Directement dans cet emplacement", l'app SHALL afficher la liste des bouteilles. Quand la largeur disponible du contenu est ≥ 640px, l'affichage SHALL être un tableau triable par colonne (mêmes colonnes que le tableau desktop de l'écran Stock, sans la colonne Emplacement — déjà visible dans le fil d'ariane). En dessous de 640px, l'affichage SHALL rester une liste de tuiles avec un badge maturité compact en trailing (à la place de l'emplacement, redondant avec le fil d'ariane).

#### Scenario: Badge maturité dans la liste (largeur < 640px)
- **WHEN** l'utilisateur consulte la liste bouteilles d'un emplacement sur une largeur < 640px
- **THEN** chaque bouteille affiche un badge compact : "Optimal" (vert), "Trop jeune" (bleu), "À boire !" (rouge) — aucun badge si pas de données de garde

#### Scenario: Tableau triable en largeur ≥ 640px
- **WHEN** l'utilisateur consulte la liste bouteilles d'un emplacement sur une largeur ≥ 640px
- **THEN** l'app affiche un tableau avec les colonnes icône couleur, domaine, appellation, millésime, garde (coloré selon maturité) et prix — sans colonne emplacement

#### Scenario: Tri par colonne dans le tableau
- **WHEN** l'utilisateur tape sur l'en-tête d'une colonne triable du tableau (domaine, appellation, millésime, garde, prix)
- **THEN** la liste se trie selon cette colonne ; un second tap sur la même colonne inverse le sens du tri

#### Scenario: Tri par défaut
- **WHEN** l'utilisateur ouvre la liste bouteilles d'un emplacement sans avoir changé le tri
- **THEN** les bouteilles sont triées par domaine croissant ; à domaine égal, par niveau de maturité puis score d'urgence (même logique de tri que l'écran Stock, pour une cohérence de comportement entre les deux écrans)

#### Scenario: Actions disponibles en mode écriture
- **WHEN** l'app est en mode écriture et l'utilisateur tape sur une bouteille dans la liste (tableau ou tuiles)
- **THEN** le BottomSheet d'actions s'affiche (Consommer, Consulter la fiche, Déplacer, Modifier la fiche)

#### Scenario: Actions en mode lecture seule
- **WHEN** l'app est en SyncReadOnly et l'utilisateur tape sur une bouteille
- **THEN** le BottomSheet affiche "Mode lecture seule — modifications indisponibles" et Fermer uniquement

#### Scenario: Multi-sélection en mode écriture
- **WHEN** l'utilisateur effectue un appui long sur une bouteille (mode écriture), en tableau comme en tuiles
- **THEN** le mode sélection s'active avec la BulkActionBar (Déplacer / Consommer) et une colonne/case à cocher apparaît en tableau

#### Scenario: Multi-sélection désactivée en lecture seule
- **WHEN** l'app est en SyncReadOnly
- **THEN** l'appui long est ignoré, en tableau comme en tuiles
