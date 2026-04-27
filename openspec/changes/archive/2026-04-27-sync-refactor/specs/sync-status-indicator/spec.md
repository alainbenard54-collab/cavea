## ADDED Requirements

### Requirement: Icône de mode de stockage dans l'AppBar
L'application SHALL afficher en permanence une icône dans l'AppBar indiquant le mode de stockage actif, avec un tooltip lisible.

#### Scenario: Mode 1 — PC seul
- **WHEN** l'app est configurée en Mode 1 (local)
- **THEN** une icône ordinateur (`Icons.computer`) grise est affichée dans l'AppBar avec le tooltip "Mode local — PC seul"

#### Scenario: Mode 2 — Partagé
- **WHEN** l'app est configurée en Mode 2 (Google Drive)
- **THEN** une icône nuage (`Icons.cloud`) bleue est affichée dans l'AppBar avec le tooltip "Mode partagé — Google Drive"

---

### Requirement: Icône de verrou en Mode 2
En Mode 2, l'application SHALL afficher une icône de verrou à côté de l'icône de mode, reflétant l'état courant de l'accès à la base.

#### Scenario: Mode écriture — lock détenu
- **WHEN** l'app est en Mode 2 et détient le verrou (mode écriture)
- **THEN** une icône cadenas ouvert (`Icons.lock_open`) de couleur verte est affichée avec le tooltip "Votre cave est ouverte en écriture"

#### Scenario: Mode lecture seule — lock tiers
- **WHEN** l'app est en Mode 2 en mode lecture seule
- **THEN** une icône cadenas fermé (`Icons.lock`) de couleur ambre est affichée avec le tooltip "Consultation uniquement — cave ouverte sur un autre appareil"

#### Scenario: Démarrage en cours
- **WHEN** l'app est en mode Mode 2 et que `syncOnStartup()` est en cours
- **THEN** aucune icône de verrou n'est affichée (ou une icône de chargement est affichée)

#### Scenario: Icône absente en Mode 1
- **WHEN** l'app est en Mode 1
- **THEN** aucune icône de verrou n'est affichée
