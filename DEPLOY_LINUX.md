# Déploiement Cavea sur Linux

Guide destiné aux utilisateurs finaux souhaitant installer et configurer Cavea sur Linux.

## Distributions supportées

| Distribution | Statut |
|---|---|
| Ubuntu 22.04 LTS | ✅ Supporté |
| Ubuntu 24.04 LTS | ✅ Supporté |
| Ubuntu 26.04 LTS | ✅ Supporté |
| Autres distributions Debian/Ubuntu | Probable, non testé |

---

## Installation

### Option A — Paquet .deb (recommandée)

Le paquet .deb installe Cavea et ses dépendances automatiquement.

```bash
sudo apt install ./cavea_0.1.0_amd64.deb
```

L'application apparaît ensuite dans le menu Applications.

**Désinstallation :**
```bash
sudo apt remove cavea
```

---

### Option B — AppImage (portable, sans installation)

L'AppImage est un exécutable autonome qui ne modifie pas le système.

```bash
chmod +x Cavea-x86_64.AppImage
./Cavea-x86_64.AppImage
```

> **Note :** Certaines distributions récentes bloquent les AppImage par défaut (FUSE requis). Si l'app ne démarre pas :
> ```bash
> sudo apt install libfuse2
> ```

---

## Configuration — Mode 1 (cave locale, usage solo)

Au premier lancement, le wizard s'affiche. Choisissez **"Mode 1 — Local"** et sélectionnez un dossier pour stocker `cave.db`.

Le fichier peut se trouver n'importe où : dossier personnel (`~/cave/`), clé USB, partage réseau monté localement, etc.

---

## Configuration — Mode 2 (cave partagée via Google Drive ou Dropbox)

Mode 2 nécessite des identifiants OAuth que vous obtenez depuis la console du fournisseur. Ces identifiants sont stockés dans un fichier JSON à placer à côté de l'exécutable.

### Étape 1 — Obtenir les identifiants OAuth

#### Google Drive

1. Ouvrez la [Google Cloud Console](https://console.cloud.google.com/)
2. Créez un projet → activez l'API **Google Drive**
3. Identifiants → **Créer des identifiants** → **ID client OAuth 2.0** → type **Application de bureau**
4. Téléchargez le fichier JSON et renommez-le `google_desktop_secrets.json`

Format attendu :
```json
{
  "client_id": "VOTRE_CLIENT_ID.apps.googleusercontent.com",
  "client_secret": "VOTRE_SECRET"
}
```

#### Dropbox

1. Ouvrez le [portail développeurs Dropbox](https://www.dropbox.com/developers/apps)
2. Créez une app → type **Scoped access** → accès **App folder**
3. Notez le **App key** et le **App secret**
4. Créez le fichier `dropbox_desktop_secrets.json` manuellement :

```json
{
  "app_key": "VOTRE_APP_KEY",
  "app_secret": "VOTRE_APP_SECRET"
}
```

---

### Étape 2 — Placer le fichier secrets

#### Installation .deb

Placez le fichier JSON dans `/usr/local/lib/cavea/` :

```bash
sudo cp google_desktop_secrets.json /usr/local/lib/cavea/
# ou
sudo cp dropbox_desktop_secrets.json /usr/local/lib/cavea/
```

#### AppImage

Placez le fichier JSON dans le **même dossier** que l'AppImage :

```
~/cavea/
├── Cavea-x86_64.AppImage
└── google_desktop_secrets.json   ← ici
```

---

### Étape 3 — Premier lancement Mode 2

Au premier lancement :
1. Choisissez **"Mode 2 — Partagé"** dans le wizard
2. Sélectionnez le fournisseur (Google Drive ou Dropbox)
3. Le navigateur s'ouvre sur la page d'authentification du fournisseur
4. Autorisez l'accès → le navigateur affiche "Authentification réussie, vous pouvez fermer cette fenêtre"
5. L'app télécharge `cave.db` depuis le cloud et démarre

Le token d'authentification est enregistré dans le trousseau système (GNOME Keyring ou KDE Wallet). Les prochains lancements sont silencieux — le navigateur ne s'ouvre plus.

---

## Problèmes connus

### L'app ne démarre pas après installation .deb

Vérifiez que les dépendances sont satisfaites :
```bash
dpkg -l | grep -E "libgtk-3|libsecret"
```

Si absentes :
```bash
sudo apt install libgtk-3-0t64 libsecret-1-0t64
```

### Erreur "Authentification Google annulée"

Le navigateur doit s'ouvrir automatiquement via `xdg-open`. Vérifiez qu'un navigateur est configuré par défaut :
```bash
xdg-settings get default-web-browser
```

### Artefacts graphiques sous Wayland

Ajoutez cette variable d'environnement avant de lancer l'app :
```bash
GDK_BACKEND=x11 ./Cavea-x86_64.AppImage
```

Pour le rendre permanent avec le .deb, créez `~/.local/share/applications/cavea.desktop` avec `Exec=env GDK_BACKEND=x11 /usr/local/bin/cavea`.

### Le trousseau système n'est pas disponible

Si vous utilisez une session sans GNOME Keyring ni KDE Wallet (ex. environnement minimal), `libsecret` peut échouer silencieusement. Installez et démarrez le trousseau :
```bash
sudo apt install gnome-keyring
```
Puis reconnectez-vous pour que le démon démarre automatiquement.

---

## Désinstallation complète

```bash
# Paquet .deb
sudo apt remove cavea
sudo rm -f /usr/local/lib/cavea/google_desktop_secrets.json
sudo rm -f /usr/local/lib/cavea/dropbox_desktop_secrets.json

# Données utilisateur (cave.db — ATTENTION : irréversible)
# rm ~/chemin/vers/cave.db

# Tokens OAuth dans le trousseau
# → supprimer via l'application "Mots de passe et clés" (GNOME Keyring)
```
