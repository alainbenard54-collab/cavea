## MODIFIED Requirements

### Requirement: BouteilleDao — opérations de base
Ajout d'une méthode d'insertion en lot transactionnelle.

#### Scenario: Insertion en lot atomique
- **WHEN** `insertBouteilles(List<BouteillesCompanion>)` est appelé avec une liste non vide
- **THEN** toutes les bouteilles sont insérées dans une seule transaction ; en cas d'erreur, aucune n'est persistée
