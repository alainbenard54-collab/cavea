## ADDED Requirements

### Requirement: Header filtres sans débordement en paysage Android
En orientation paysage sur Android, la zone contenant la barre de recherche et les filtres SHALL être scrollable verticalement pour éviter tout débordement de rendu. La barre de recherche SHALL rester toujours visible en haut.

#### Scenario: Paysage Android avec filtres développés
- **WHEN** l'utilisateur ouvre les filtres en orientation paysage sur Android
- **THEN** aucun débordement de pixel n'apparaît ; le contenu des filtres est accessible par scroll vertical

#### Scenario: Barre de recherche toujours visible
- **WHEN** l'utilisateur scrolle dans les filtres en paysage
- **THEN** la barre de recherche reste visible et accessible

---

### Requirement: Chips couleur sélectionnées en tête de liste avec gradient overflow
Les FilterChips de couleur actifs (sélectionnés) SHALL apparaître en premier dans la rangée. La rangée de chips SHALL utiliser un masque de dégradé (ShaderMask) aux bords pour indiquer visuellement qu'il y a du contenu hors champ. Au tap sur un chip non visible, la rangée SHALL scroller automatiquement pour le rendre visible.

#### Scenario: Chip sélectionné remis en tête
- **WHEN** l'utilisateur sélectionne un chip couleur initialement hors écran
- **THEN** ce chip se repositionne en premier dans la rangée et devient visible sans scroll manuel

#### Scenario: Gradient overflow visible
- **WHEN** la rangée de chips dépasse la largeur disponible
- **THEN** un dégradé transparent aux bords indique qu'il y a des chips non visibles

---

### Requirement: Toggle filtres paysage avec reset inline
En orientation paysage sur Android, le toggle "Filtres / Filtres actifs" et le bouton reset SHALL être affichés sur une seule ligne horizontale : le toggle à gauche, le bouton reset (icône) à droite. En portrait, le bouton reset reste en bas sous les filtres.

#### Scenario: Toggle et reset inline en paysage
- **WHEN** des filtres sont actifs et l'utilisateur est en paysage Android
- **THEN** le texte "Filtres actifs" et l'icône de reset sont sur la même ligne, sans empiètement

#### Scenario: Reset en bas en portrait
- **WHEN** des filtres sont actifs et l'utilisateur est en portrait
- **THEN** le bouton de reset complet s'affiche sous les filtres, séparé du toggle

---

### Requirement: Dropdown filtres avancés sans débordement
Le composant `_CascadeDropdown` (filtres appellation et millésime) SHALL utiliser `isExpanded: true` pour occuper toute la largeur disponible et éviter tout débordement horizontal.

#### Scenario: Dropdown étendu en portrait filtres avancés
- **WHEN** l'utilisateur ouvre le panneau "Filtres avancés" en portrait sur Android
- **THEN** les dropdowns appellation et millésime s'affichent sans débordement horizontal
