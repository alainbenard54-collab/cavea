#!/usr/bin/env bash
# Vérifie que la configuration Android pour google_sign_in v7 est correcte.
# À lancer avant tout build Android pour détecter les régressions de config.
# Usage : bash scripts/check_android_config.sh
set -euo pipefail

ERRORS=0

check() {
  local label="$1"
  local result="$2"
  if [ "$result" = "ok" ]; then
    echo "  ✓ $label"
  else
    echo "  ✗ $label — $result"
    ERRORS=$((ERRORS + 1))
  fi
}

echo "=== Vérification config Android ==="

# 1. dart-defines.json présent (gitignored — à créer depuis dart-defines.json.template)
if [ -f "dart-defines.json" ]; then
  check "dart-defines.json présent" "ok"
else
  check "dart-defines.json présent" "absent — copier dart-defines.json.template en dart-defines.json et renseigner les valeurs"
fi

# 2. GOOGLE_ANDROID_SERVER_CLIENT_ID renseigné dans dart-defines.json
if [ -f "dart-defines.json" ]; then
  VALUE=$(python3 -c "import json; d=json.load(open('dart-defines.json')); print(d.get('GOOGLE_ANDROID_SERVER_CLIENT_ID',''))" 2>/dev/null)
  if [ -n "$VALUE" ] && [ "$VALUE" != "REMPLACER_PAR_LE_CLIENT_ID_WEB_DE_google-services.json" ]; then
    check "GOOGLE_ANDROID_SERVER_CLIENT_ID renseigné (client OAuth Web application GCP)" "ok"
  else
    check "GOOGLE_ANDROID_SERVER_CLIENT_ID renseigné (client OAuth Web application GCP)" "valeur manquante ou placeholder — créer un client 'Web application' dans GCP Console > APIs & Services > Credentials et mettre son client_id ici"
  fi
fi

# 3. google_sign_in v7+ dans pubspec.yaml
GSIN_VERSION=$(grep 'google_sign_in:' pubspec.yaml | grep -oP '[\d]+' | head -1)
if [ -n "$GSIN_VERSION" ] && [ "$GSIN_VERSION" -ge 7 ]; then
  check "google_sign_in v7+ dans pubspec.yaml" "ok"
else
  check "google_sign_in v7+ dans pubspec.yaml" "version: '$GSIN_VERSION' — vérifier pubspec.yaml"
fi

echo ""
if [ "$ERRORS" -eq 0 ]; then
  echo "Tout est OK."
  echo "Build : flutter run -d <device> --dart-define-from-file=dart-defines.json"
  exit 0
else
  echo "$ERRORS erreur(s) — corriger avant de builder."
  exit 1
fi
