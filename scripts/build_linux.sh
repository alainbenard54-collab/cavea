#!/usr/bin/env bash
# build_linux.sh — Packaging Cavea pour Linux (AppImage et .deb)
#
# Usage :
#   ./scripts/build_linux.sh appimage   → Cavea-x86_64.AppImage
#   ./scripts/build_linux.sh deb        → cavea_<version>_amd64.deb
#   ./scripts/build_linux.sh all        → les deux
#
# Pré-requis : flutter (dans PATH), appimagetool (téléchargé si absent), dpkg-deb
# Le build Flutter Release doit avoir été exécuté au préalable :
#   flutter build linux --release

set -euo pipefail

APP_NAME="Cavea"
APP_ID="io.github.alainbenard.cavea"
VERSION="1.2.0"
ARCH="x86_64"
BUILD_DIR="build/linux/x64/release/bundle"
OUT_DIR="build/linux"

# --------------------------------------------------------------------------- #
# Vérifications préalables
# --------------------------------------------------------------------------- #

if [ ! -d "$BUILD_DIR" ]; then
  echo "❌  Dossier $BUILD_DIR introuvable. Exécutez d'abord : flutter build linux --release"
  exit 1
fi

# --------------------------------------------------------------------------- #
# AppImage
# --------------------------------------------------------------------------- #

build_appimage() {
  echo "▶  Construction AppImage..."

  local appdir="$OUT_DIR/${APP_NAME}.AppDir"
  rm -rf "$appdir"
  # L'exécutable est placé directement dans usr/ (pas usr/bin/) pour que Flutter
  # trouve lib/ et data/ dans le même répertoire que lui — résolution AOT relative.
  mkdir -p "$appdir/usr" "$appdir/usr/share/applications" "$appdir/usr/share/icons/hicolor/512x512/apps"

  # Exécutable + bibliothèques + data Flutter — structure miroir du bundle release
  cp "$BUILD_DIR/cavea" "$appdir/usr/$APP_NAME"
  chmod 755 "$appdir/usr/$APP_NAME"
  if [ -d "$BUILD_DIR/lib" ]; then
    cp -r "$BUILD_DIR/lib" "$appdir/usr/"          # → usr/lib/libapp.so etc.
  fi
  if [ -d "$BUILD_DIR/data" ]; then
    cp -r "$BUILD_DIR/data" "$appdir/usr/"         # → usr/data/flutter_assets etc.
  fi

  # Credentials OAuth — copiés à la racine de l'AppDir (à côté de AppRun / de l'exe)
  for secret in google_desktop_secrets.json dropbox_desktop_secrets.json; do
    if [ -f "$secret" ]; then
      cp "$secret" "$appdir/usr/$secret"
      echo "   ✓ $secret inclus dans l'AppImage"
    else
      echo "⚠   [WARN] $secret absent — Mode 2 non disponible dans cette AppImage"
    fi
  done

  # Icône (utilise ic_launcher xxxhdpi comme source 192px ; idéal = 512px)
  local icon_src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"
  if [ -f "$icon_src" ]; then
    cp "$icon_src" "$appdir/usr/share/icons/hicolor/512x512/apps/$APP_ID.png"
    cp "$icon_src" "$appdir/$APP_ID.png"
  else
    echo "⚠   Icône $icon_src absente — créez assets/icon/icon_512.png pour un meilleur résultat"
    # Crée un PNG vide de 512×512 si ImageMagick est disponible, sinon skip
    if command -v convert &>/dev/null; then
      convert -size 512x512 xc:'#2d2d2d' "$appdir/$APP_ID.png"
      cp "$appdir/$APP_ID.png" "$appdir/usr/share/icons/hicolor/512x512/apps/$APP_ID.png"
    fi
  fi

  # Fichier .desktop
  cat > "$appdir/$APP_ID.desktop" <<EOF
[Desktop Entry]
Name=$APP_NAME
Comment=Gestion de cave à vin personnelle
Exec=$APP_NAME
Icon=$APP_ID
Type=Application
Categories=Utility;
StartupNotify=true
EOF
  cp "$appdir/$APP_ID.desktop" "$appdir/usr/share/applications/$APP_ID.desktop"

  # AppRun
  cat > "$appdir/AppRun" <<'EOF'
#!/bin/sh
SELF=$(readlink -f "$0")
HERE=$(dirname "$SELF")
export LD_LIBRARY_PATH="$HERE/usr/lib:${LD_LIBRARY_PATH:-}"
exec "$HERE/usr/Cavea" "$@"
EOF
  chmod +x "$appdir/AppRun"

  # Télécharger appimagetool si absent
  local appimagetool="$OUT_DIR/appimagetool-x86_64.AppImage"
  if [ ! -x "$appimagetool" ]; then
    echo "   Téléchargement de appimagetool..."
    curl -L -o "$appimagetool" \
      "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    chmod +x "$appimagetool"
  fi

  local out="$OUT_DIR/${APP_NAME}-${ARCH}.AppImage"
  ARCH="$ARCH" "$appimagetool" "$appdir" "$out"
  echo "✅  AppImage : $out"
}

# --------------------------------------------------------------------------- #
# Paquet .deb
# --------------------------------------------------------------------------- #

build_deb() {
  echo "▶  Construction paquet .deb..."

  local pkg_name="cavea"
  local deb_dir="$OUT_DIR/${pkg_name}_${VERSION}_amd64"
  rm -rf "$deb_dir"
  mkdir -p "$deb_dir/DEBIAN" \
           "$deb_dir/usr/local/bin" \
           "$deb_dir/usr/local/lib/$pkg_name" \
           "$deb_dir/usr/share/applications" \
           "$deb_dir/usr/share/icons/hicolor/512x512/apps"

  # Binaire principal
  cp "$BUILD_DIR/cavea" "$deb_dir/usr/local/bin/cavea"
  chmod 755 "$deb_dir/usr/local/bin/cavea"

  # Bibliothèques Flutter — conserver le sous-dossier lib/ pour que Flutter
  # trouve libapp.so via résolution relative à l'exe (exe/lib/libapp.so).
  if [ -d "$BUILD_DIR/lib" ]; then
    cp -r "$BUILD_DIR/lib" "$deb_dir/usr/local/lib/$pkg_name/"
  fi

  # Data Flutter (assets, ICU, etc.)
  if [ -d "$BUILD_DIR/data" ]; then
    cp -r "$BUILD_DIR/data" "$deb_dir/usr/local/lib/$pkg_name/"
  fi

  # Credentials OAuth — copiés dans /usr/local/lib/cavea/ (à côté de l'exe réel)
  for secret in google_desktop_secrets.json dropbox_desktop_secrets.json; do
    if [ -f "$secret" ]; then
      cp "$secret" "$deb_dir/usr/local/lib/$pkg_name/$secret"
      echo "   ✓ $secret inclus dans le .deb"
    else
      echo "⚠   [WARN] $secret absent — Mode 2 non disponible dans ce paquet"
    fi
  done

  # Icône
  local icon_src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"
  if [ -f "$icon_src" ]; then
    cp "$icon_src" "$deb_dir/usr/share/icons/hicolor/512x512/apps/$APP_ID.png"
  fi

  # Entrée .desktop
  cat > "$deb_dir/usr/share/applications/$APP_ID.desktop" <<EOF
[Desktop Entry]
Name=$APP_NAME
Comment=Gestion de cave à vin personnelle
Exec=/usr/local/bin/cavea
Icon=$APP_ID
Type=Application
Categories=Utility;
StartupNotify=true
EOF

  # Wrapper qui ajoute les libs au LD_LIBRARY_PATH
  cat > "$deb_dir/usr/local/bin/cavea" <<EOF
#!/bin/sh
export LD_LIBRARY_PATH="/usr/local/lib/$pkg_name/lib:\${LD_LIBRARY_PATH:-}"
exec /usr/local/lib/$pkg_name/cavea "\$@"
EOF
  chmod 755 "$deb_dir/usr/local/bin/cavea"
  cp "$BUILD_DIR/cavea" "$deb_dir/usr/local/lib/$pkg_name/cavea"
  chmod 755 "$deb_dir/usr/local/lib/$pkg_name/cavea"

  # Manifest DEBIAN/control
  local installed_size
  installed_size=$(du -sk "$deb_dir" | cut -f1)
  cat > "$deb_dir/DEBIAN/control" <<EOF
Package: $pkg_name
Version: $VERSION
Architecture: amd64
Maintainer: Alain Benard <alain.benard54@gmail.com>
Installed-Size: $installed_size
Depends: libgtk-3-0t64 | libgtk-3-0, libsecret-1-0t64 | libsecret-1-0, libglib2.0-0
Description: Gestion de cave à vin personnelle
 Application Flutter de gestion de cave à vin.
 Modes : local (Mode 1) ou partagé via Google Drive / Dropbox (Mode 2).
EOF

  local out="$OUT_DIR/${pkg_name}_${VERSION}_amd64.deb"
  dpkg-deb --build --root-owner-group "$deb_dir" "$out"
  echo "✅  Paquet .deb : $out"
}

# --------------------------------------------------------------------------- #
# Point d'entrée
# --------------------------------------------------------------------------- #

case "${1:-all}" in
  appimage) build_appimage ;;
  deb)      build_deb ;;
  all)      build_appimage; build_deb ;;
  *)
    echo "Usage : $0 [appimage|deb|all]"
    exit 1
    ;;
esac
