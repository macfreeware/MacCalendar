#!/bin/bash
# Sürüm dosyalarını hazırlar: evrensel uygulama, MacCalendar.zip + .sha256 (uygulamanın kendini
# güncellemesi bu iki sabit adı arar, bkz. Sources/MacCalendar/UpdateInfo.swift) ve kurulum paketi.
#
#   scripts/make_release.sh                       # yalnızca dosyaları hazırlar ve denetler
#   scripts/make_release.sh --publish notlar.md   # ayrıca GitLab'da v<sürüm> sürümünü oluşturur (glab ile);
#                                                 # notlardaki @PKG_SHA@ ve @ZIP_SHA@ doldurulur
#
# Sürüm numarası build_app.sh'teki VERSION'dan gelir; önce onu yükseltip commit'leyin.
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION=$(sed -n 's/^VERSION="\(.*\)"$/\1/p' build_app.sh)
OUT="build/release"

rm -rf "$OUT"
./build_app.sh --zip
SKIP_APP_BUILD=1 scripts/build_pkg.sh

# Denetim: zip'ten çıkan uygulama, güncelleyicinin aradığı yerde, imzalı ve doğru sürümde mi?
CHECK=$(mktemp -d)
ditto -x -k "$OUT/MacCalendar.zip" "$CHECK"
codesign --verify --deep --strict "$CHECK/MacCalendar/MacCalendar.app"
[[ "$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$CHECK/MacCalendar/MacCalendar.app/Contents/Info.plist")" == "$VERSION" ]]
[[ "$(lipo -archs "$CHECK/MacCalendar/MacCalendar.app/Contents/MacOS/MacCalendar")" == "x86_64 arm64" ]]
rm -rf "$CHECK"

# Deneme ayarları (yalnızca DEBUG) yayımlanan ikilide olmamalı.
if strings MacCalendar.app/Contents/MacOS/MacCalendar | grep -qE "MACCALENDAR_UPDATE_|--update-headless"; then
  echo "✘ Yayım ikilisinde deneme ayarı var" >&2
  exit 1
fi

echo "✔ $OUT ($VERSION)"
cat "$OUT/MacCalendar.zip.sha256" "$OUT/MacCalendar-$VERSION.pkg.sha256"

if [[ "${1:-}" == "--publish" ]]; then
  NOTES_SRC="${2:?Notlar dosyası gerekli: scripts/make_release.sh --publish notlar.md}"
  # Özetler bu derlemeye ait olmalı: notlardaki @PKG_SHA@ ve @ZIP_SHA@ burada doldurulur.
  NOTES="$OUT/notes.md"
  sed -e "s/@PKG_SHA@/$(cut -d' ' -f1 "$OUT/MacCalendar-$VERSION.pkg.sha256")/g" \
      -e "s/@ZIP_SHA@/$(cut -d' ' -f1 "$OUT/MacCalendar.zip.sha256")/g" "$NOTES_SRC" > "$NOTES"
  glab release create "v$VERSION" -R freeware2/maccalendar \
    "$OUT/MacCalendar.zip#MacCalendar.zip" \
    "$OUT/MacCalendar.zip.sha256#MacCalendar.zip.sha256" \
    "$OUT/MacCalendar-$VERSION.pkg#MacCalendar-$VERSION.pkg" \
    "$OUT/MacCalendar-$VERSION.pkg.sha256#MacCalendar-$VERSION.pkg.sha256" \
    --ref main --name "MacCalendar $VERSION" --notes-file "$NOTES"
  # README'deki indirme düğmesi sürümsüz adresi kullanır: .../permalink/latest/downloads/MacCalendar.pkg
  ID=$(glab api "projects/freeware2%2Fmaccalendar/releases/v$VERSION/assets/links" |
       python3 -I -c 'import sys,json; print(next(l["id"] for l in json.load(sys.stdin) if l["name"].endswith(".pkg")))')
  printf '{"name":"MacCalendar-%s.pkg","link_type":"package","direct_asset_path":"/MacCalendar.pkg"}' "$VERSION" |
    glab api --method PUT -H "Content-Type: application/json" --input - \
      "projects/freeware2%2Fmaccalendar/releases/v$VERSION/assets/links/$ID" >/dev/null
fi
