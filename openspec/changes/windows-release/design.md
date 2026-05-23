## Context

Cavea est une app Flutter compilée pour Windows x64. Le build release produit ses artefacts dans `build\windows\x64\runner\Release\` (Flutter 3.13+). L'icône Windows est `windows/runner/resources/app_icon.ico` (ICO multi-tailles 16/32/48/64/128/256 px, déjà générée). La licence Apache 2.0 est dans `LICENSE` à la racine.

GitHub Actions `windows-latest` (Windows Server 2022) inclut Inno Setup 6.x pré-installé — la commande `iscc` est disponible sans étape d'installation supplémentaire.

Il n'existe aucun workflow CI/CD. Le dépôt est public. La pre-release v0.1.0 existe déjà — la nouvelle release v1.0.0 sera créée automatiquement par le workflow lors du push du tag.

## Goals / Non-Goals

**Goals:**
- Produire un installateur Windows autonome (pas de dépendances .NET/VC++ — Flutter bundle tout)
- Automatiser le build + publication via GitHub Actions sur chaque tag `v*`
- Fournir un template de release notes bilingue pour la release GitHub

**Non-Goals:**
- Signature de code (certificat EV) — nécessite un investissement annuel, hors V1
- Distribution Microsoft Store
- Auto-update intégré dans l'app

## Decisions

### D1 — Inno Setup plutôt que NSIS ou WiX

Inno Setup est le standard de facto pour les apps Flutter Windows (recommandé dans la documentation Flutter). Syntaxe plus lisible que NSIS, pas de XML lourd comme WiX. Pré-installé sur `windows-latest`. Supporte `MinVersion`, raccourcis, désinstallation propre, et gestion des upgrades via AppId GUID.

### D2 — Déclencheur sur tag `v*` uniquement

Le workflow ne se déclenche que sur `git push --tags` avec `v*`. Cela permet de contrôler précisément quand une release est publiée, sans risque de publication accidentelle sur chaque commit master.

### D3 — `softprops/action-gh-release@v2` pour la publication

Action standard et bien maintenue pour créer/mettre à jour une GitHub Release et y attacher des assets. Elle crée automatiquement la release si elle n'existe pas, ou y ajoute l'asset si la release existe déjà (créée manuellement depuis l'interface GitHub).

Alternative écartée : `gh release create` en CLI — moins robuste en cas de release pré-existante.

### D4 — Nom de l'exe incluant le tag Git

`Cavea-${{ github.ref_name }}-windows-setup.exe` (ex : `Cavea-v1.0.0-windows-setup.exe`). Le tag Git est la source de vérité pour la version — pas de duplication risquée avec la version dans le .iss.

### D5 — AppId GUID fixe

L'AppId Inno Setup doit être stable d'une version à l'autre pour que Windows reconnaisse les mises à jour et désinstallations correctement. GUID généré une fois, jamais modifié : `{6F3C2A1B-D4E5-4F8A-9B0C-1D2E3F4A5B6C}`.

### D6 — Pas de [Run] post-install par défaut

La section `[Run]` pour lancer l'app après installation sera présente mais avec le flag `postinstall` en mode décoché (unchecked). Comportement standard — certains utilisateurs installent sur un serveur ou à distance.

## Risks / Trade-offs

- [Pas de signature] Windows SmartScreen affichera un avertissement "application inconnue" au premier lancement → Mitigation : documenter dans le README et le texte de release (clic droit → Exécuter quand même), comportement attendu pour les apps open source sans certificat EV
- [Runner windows-latest peut changer] Si GitHub change la version d'Inno Setup pré-installée → Mitigation : épingler la version de Flutter via `flutter-version` dans l'action, et vérifier `iscc /?` si problème
- [Chemin build Flutter] Si le chemin `build\windows\x64\runner\Release\` change dans une future version Flutter → Mitigation : tâche de vérification locale avant push du tag
