#!/bin/zsh
# MacCalendar.app'i derler (Apple Silicon + Intel, universal).
#   --zip  ayrıca build/release/MacCalendar-<sürüm>.zip ve SHA-256 değerini üretir
set -e
cd "$(dirname "$0")"

APP_NAME="MacCalendar"
VERSION="1.1.2"
BUNDLE_DIR="${APP_NAME}.app"
CONTENTS_DIR="${BUNDLE_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"
MODULE_CACHE="/tmp/maccalendar-module-cache"

echo "🔨 ${APP_NAME} derleniyor..."
mkdir -p "${MODULE_CACHE}"
rm -rf "${BUNDLE_DIR}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

echo "🎨 Uygulama simgesi (AppIcon.icns) oluşturuluyor..."
swiftc \
    -module-cache-path "${MODULE_CACHE}" \
    -target arm64-apple-macosx13.0 \
    -framework AppKit \
    -framework CoreGraphics \
    scripts/generate_icon.swift \
    -o /tmp/generate_icon_bin
/tmp/generate_icon_bin
iconutil -c icns /tmp/AppIcon.iconset -o "${RESOURCES_DIR}/AppIcon.icns"

echo "⚙️ Uygulama ikili dosyası derleniyor (arm64 + x86_64)..."
for ARCH in arm64 x86_64; do
    swiftc \
        -O \
        -module-cache-path "${MODULE_CACHE}" \
        -target ${ARCH}-apple-macosx13.0 \
        -framework AppKit \
        -framework SwiftUI \
        -framework Combine \
        -framework ServiceManagement \
        Sources/MacCalendar/LocalizationManager.swift \
        Sources/MacCalendar/AppSettings.swift \
        Sources/MacCalendar/CalendarFlyoutView.swift \
        Sources/MacCalendar/MenuBarManager.swift \
        Sources/MacCalendar/MacCalendarApp.swift \
        -o "/tmp/${APP_NAME}-${ARCH}"
done
lipo -create "/tmp/${APP_NAME}-arm64" "/tmp/${APP_NAME}-x86_64" -output "${MACOS_DIR}/${APP_NAME}"

chmod +x "${MACOS_DIR}/${APP_NAME}"

cat > "${CONTENTS_DIR}/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.rafetsapanci.MacCalendar</string>
    <key>CFBundleName</key>
    <string>MacCalendar</string>
    <key>CFBundleDisplayName</key>
    <string>MacCalendar</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

codesign --force --deep --sign - "${BUNDLE_DIR}" 2>/dev/null || true
touch "${BUNDLE_DIR}"

echo "✅ ${BUNDLE_DIR} simgesiyle birlikte başarıyla hazırlandı!"

if [[ "${1:-}" == "--zip" ]]; then
    # Zip, uygulamayı ve GPL lisans metnini içeren bir klasör taşır.
    mkdir -p build/release
    ZIP="build/release/${APP_NAME}-${VERSION}.zip"
    STAGE="build/release/${APP_NAME}-${VERSION}"
    rm -rf "${ZIP}" "${ZIP}.sha256" "${STAGE}"
    mkdir -p "${STAGE}"
    cp -R "${BUNDLE_DIR}" "${STAGE}/"
    cp LICENSE "${STAGE}/LICENSE.txt"
    ditto -c -k --norsrc --keepParent "${STAGE}" "${ZIP}"
    rm -rf "${STAGE}"
    (cd build/release && shasum -a 256 "$(basename "${ZIP}")" > "$(basename "${ZIP}").sha256")
    echo "📦 Paket: ${ZIP}"
fi
