🇬🇧 [English version](README.md)

# Cavea — Gestionnaire de cave à vin personnel

Application Flutter personnelle pour gérer votre cave à vin. Disponible sur Windows, Linux et Android.

## Philosophie

Cavea est délibérément simple : pas de photos, pas de codes-barres, pas de champs d'œnologie avancés, pas de données fournisseurs avancées, pas de déploiement serveur. L'essentiel au quotidien — suivre son stock (entrées, sorties…), savoir où chaque bouteille est rangée, comprendre quand la boire, noter son ressenti.

Une ligne en base de données = une bouteille physique.

## Modes de déploiement

### Mode Local (un seul appareil)

Votre cave vit dans un fichier `cave.db` sur votre disque local. Pas de connexion internet, pas de compte, pas de cloud — juste vos données sur votre machine.

Ce mode est disponible sur **Windows** et **Linux**. Une version Android entièrement locale (sans cloud) est prévue dans une future version.

C'est le point de départ recommandé. Vous pouvez passer en Mode Partagé plus tard depuis les Paramètres.

### Mode Partagé (plusieurs appareils)

Le fichier `cave.db` est hébergé sur **Google Drive** ou **Dropbox**. Toute combinaison d'appareils peut accéder à la même cave — Windows + Android, deux machines Windows, etc.

**Comment fonctionne le verrou** : à l'ouverture, Cavea télécharge la dernière version de `cave.db` et prend un verrou exclusif en écriture. Les autres appareils peuvent toujours ouvrir l'application, mais seront en **mode lecture seule** jusqu'à ce que vous fermiez Cavea — qui sauvegarde le fichier et libère le verrou.

C'est un choix délibéré : pas de résolution de conflits, pas de fusion, pas de complexité de synchronisation. Un seul appareil écrit à la fois.

## Plateformes

| Plateforme | Statut |
|---|---|
| Windows desktop | Cible principale |
| Android | Cible principale |
| Linux desktop | Supporté |

iOS n'est pas supporté (coût du programme Apple Developer).

## Installation

Téléchargez la dernière version depuis la [page des releases](../../releases) :

- **Windows** : `CaveaSetup-x.x.x.exe` — double-cliquez pour installer
- **Linux** : `cavea-x.x.x.deb` — paquet Debian/Ubuntu (`sudo dpkg -i cavea-x.x.x.deb`)
- **Android** : `cavea-x.x.x.apk` — activez "Installer des applications inconnues" dans les paramètres Android avant installation. Publication sur le Play Store à venir.

## Stack technique

| Couche | Technologie |
|---|---|
| Framework | Flutter 3 (Dart) |
| Base de données | drift (ORM SQLite, streams réactifs) |
| Gestion d'état | Riverpod |
| Navigation | go_router |
| UI | Material 3 |

## À l'intention des développeurs

### Compiler le projet

**Prérequis** : [Flutter SDK](https://docs.flutter.dev/get-started/install) (dernière version stable), Dart (inclus avec Flutter).

```bash
git clone <repo-url>
cd cavea
flutter pub get
flutter run -d windows   # ou -d linux, ou connecter un appareil Android
```

### Lancer les tests

```bash
flutter test
```

### Configuration OAuth (Mode Partagé)

Pour utiliser le Mode Partagé, vous devez configurer les credentials OAuth de votre fournisseur.

- **Google Drive** : voir [docs/google_drive_setup.md](docs/google_drive_setup.md)
- **Dropbox** : créer une application Dropbox sur la [console développeur Dropbox](https://www.dropbox.com/developers/apps), activer PKCE, ajouter l'URI de redirection `http://localhost:8080/auth`, et noter votre App key. Saisir-le dans Paramètres lorsque demandé.

Les credentials sont stockés localement dans le trousseau système (Windows Credential Manager / libsecret sur Linux / Android Keystore).

## Documentation utilisateur

Voir [docs/README.md](docs/README.md) pour le guide utilisateur complet — 14 scénarios disponibles en français et en anglais, dont un guide [découverte avec les données d'exemple](docs/fr/00-decouverte.md).

## Licence

Apache 2.0 — voir [LICENSE](LICENSE).
