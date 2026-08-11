## Context

Voir `proposal.md` (Why) pour la motivation. Contexte technique propre à ce design :

- La suite de tests existante (`unit-tests`, `dao-integration-tests`, `maturity-unit-tests`, spec `unit-tests`) couvre exclusivement les couches non-UI (DAO, parsing, contrôleurs Riverpod). Aucun test n'exerce le rendu visuel réel des écrans.
- L'utilisateur développe exclusivement sous **Windows natif** (Flutter 3.44.9). Il dispose aussi d'une VM Ubuntu 26.04 (Flutter installé manuellement) utilisée pour les builds Linux, et de WSL pour cette session — mais sans Flutter installé dans WSL.
- La CI (`ci.yml`) tourne sur `ubuntu-latest` (GitHub Actions), mais son câblage golden est explicitement hors périmètre de ce change.
- Rendu des polices : le rasterizer diffère entre Windows (DirectWrite) et Linux (FreeType), même avec la police identique — deux références générées sur des OS différents ne matcheront jamais pixel-perfect. Décision produit (validée avec l'utilisateur) : **une seule référence par golden, générée et comparée exclusivement sous Windows natif**, pour l'instant. Le futur change de câblage CI devra retraiter cette question (voir Risques).

## Goals / Non-Goals

**Goals:**
- Détecter les régressions visuelles majeures : disparition d'un élément (bouton, badge), changement de couleur significatif (ex. couleurs de maturité bleu/vert/rouge), déplacement/désalignement de layout.
- Fournir un harnais de test réutilisable (thème Material 3, localisations réelles, données Riverpod déterministes) pour tous les golden tests futurs, pas seulement le premier jeu.
- Documenter un process reproductible de régénération volontaire des références.

**Non-Goals:**
- Détecter des micro-variations de rendu de police/anti-aliasing entre OS (accepté comme hors scope tant qu'une seule référence Windows existe).
- Câbler les golden tests dans `ci.yml` (change séparé à venir).
- Couvrir l'exhaustivité des écrans/widgets de l'app — ce change livre un premier jeu représentatif, extensible ensuite au fil de l'eau.
- Remplacer les tests unitaires/DAO existants — les golden tests s'ajoutent en complément, sur une préoccupation différente (rendu visuel, pas logique).

## Decisions

### Package : Alchemist (déjà tranché en amont, pas rediscuté ici)
Alchemist encapsule `matchesGoldenFile` avec chargement des polices réelles par défaut (contrairement au test Flutter nu, qui retombe sur une police de test type Ahem si les fonts ne sont pas chargées explicitement) et une configuration de tolérance intégrée (`AlchemistConfig`). C'est la raison pour laquelle ce choix évite d'avoir à écrire ce harnais à la main.

### Périmètre du premier jeu de golden tests
4 écrans/widgets, validés explicitement avec l'utilisateur :
- **Stock** — `lib/features/stock/stock_screen.dart` + `lib/features/stock/stock_table.dart` (table desktop ≥640px et liste mobile) : priorité la plus haute, contient les badges de maturité colorés (bleu/vert/rouge/gris), la régression la plus critique à détecter.
- **Emplacements** — `lib/features/locations/location_tree_screen.dart` : layout table/liste ≥640px récemment retravaillé (`emplacements-table-view`), bon test de non-régression sur un changement récent.
- **Fiche bouteille + BottomSheet actions** — `lib/features/bottle_detail/bottle_detail_screen.dart` + `lib/features/bottle_actions/bottle_actions_sheet.dart` : composants réutilisés depuis plusieurs écrans (Stock, Emplacements, Historique), un seul golden couvre indirectement plusieurs flux.
- **Formulaire bulk-add** — `lib/features/bulk_add/bulk_add_screen.dart` (piloté par `lib/features/bulk_add/bulk_add_controller.dart`) : formulaire le plus complexe (répartition dynamique de groupes), assumé comme le plus long à stabiliser.

Chaque écran est testé sous forme d'un widget isolé (pas de boot complet de l'app via `go_router`), enveloppé dans un harnais minimal `MaterialApp` + `ProviderScope` avec des providers Riverpod overridés sur des données statiques déterministes (pas de DB drift réelle, pas de dépendance réseau/OAuth) — cohérent avec le pattern déjà utilisé dans `test/helpers/` pour les tests de contrôleurs.

### Localisations réelles, pas le stub existant
`test/helpers/fake_app_localizations.dart` retourne une chaîne vide pour tout sauf les 20 en-têtes CSV — inutilisable pour un test visuel (le texte réel doit apparaître à l'écran). Les golden tests utilisent les vrais délégués (`AppLocalizations.localizationsDelegates`, `AppLocalizations.supportedLocales`) avec une locale fixe (`fr`) pour la reproductibilité. La locale `en` n'est pas couverte par ce premier jeu (extension possible plus tard, hors périmètre ici).

### Seuil de tolérance : exact (0%)
Une seule référence Windows, comparée uniquement sur la même machine/OS : pas de bruit inter-OS à absorber. Autant être strict pour capter tout changement, même mineur — validé explicitement avec l'utilisateur plutôt que de choisir une tolérance par défaut.

### Stockage des références : `test/golden/<écran>/`
Dossier dédié à la racine de `test/`, un sous-dossier par écran/widget couvert (ex. `test/golden/stock/`, `test/golden/emplacements/`, `test/golden/bottle_detail/`, `test/golden/bulk_add/`). Toujours versionné dans le dépôt (PNG committés). Structure lisible indépendamment de l'emplacement des fichiers de test Dart eux-mêmes.

### Régénération volontaire : `flutter test --update-goldens` sous Windows natif
Commande standard Alchemist/Flutter, exécutée exclusivement sous Windows (le seul environnement Flutter réellement utilisé par l'utilisateur au quotidien). Pas de génération multi-OS pour l'instant — validé explicitement avec l'utilisateur, qui accepte ce compromis et traitera une éventuelle adaptation par OS plus tard si besoin réel.

## Risks / Trade-offs

- **[Risque] Références Windows incompatibles avec une future comparaison en CI Linux** → Mitigation : assumé et documenté ; le futur change de câblage `ci.yml` devra soit régénérer les références dans un environnement Linux (VM Ubuntu de l'utilisateur ou équivalent), soit adopter une tolérance de diff plus large côté CI, soit restreindre le golden check à une exécution locale uniquement (pas en CI). Décision explicitement différée, pas prise ici.
- **[Risque] Chargement des polices réelles peut échouer/varier selon l'environnement de build** → Mitigation : Alchemist gère ce chargement par défaut ; à vérifier concrètement lors de l'implémentation (tâche dédiée dans `tasks.md`) plutôt que supposé.
- **[Trade-off] Tolérance 0% est fragile si le poste Windows change (mise à jour Windows, pilote GPU, etc.)** → Accepté sciemment par l'utilisateur ; en cas de faux positifs récurrents après un changement d'environnement (pas de code), régénérer les références plutôt qu'assouplir la tolérance par défaut.
- **[Trade-off] Premier jeu limité à 4 écrans en `fr` uniquement** → Périmètre volontairement réduit pour livrer vite un harnais réutilisable ; extension (autres écrans, locale `en`) traitée dans des changes futurs, pas ici.
