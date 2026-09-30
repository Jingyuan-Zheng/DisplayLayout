#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

APP_NAME="DisplayLayout"
DISPLAY_NAME="Display Layout"
BUNDLE_ID="is.zjy.displaylayout"
INSTALL_DIR="$HOME/Applications"
APP_DIR="$INSTALL_DIR/$APP_NAME.app"
ICON_SOURCE="/Applications/Sidecar.app/Contents/Resources/ApplicationStub.icns"

if [[ ! -f "$ICON_SOURCE" ]]; then
  echo "Required application icon was not found:" >&2
  echo "  $ICON_SOURCE" >&2
  exit 1
fi

printf 'Building %s…\n' "$DISPLAY_NAME"
swift build -c release
BIN_DIR="$(swift build -c release --show-bin-path)"
BIN="$BIN_DIR/$APP_NAME"

if [[ ! -x "$BIN" ]]; then
  echo "Build succeeded but executable was not found: $BIN" >&2
  exit 1
fi

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$BIN" "$APP_DIR/Contents/MacOS/$APP_NAME"
cp "$ICON_SOURCE" "$APP_DIR/Contents/Resources/ApplicationStub.icns"
cp -R "$ROOT/Resources/en.lproj" "$APP_DIR/Contents/Resources/"
cp -R "$ROOT/Resources/zh-Hans.lproj" "$APP_DIR/Contents/Resources/"

cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$DISPLAY_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$DISPLAY_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.2.0</string>
    <key>CFBundleVersion</key>
    <string>2</string>
    <key>CFBundleIconFile</key>
    <string>ApplicationStub.icns</string>
    <key>CFBundleLocalizations</key>
    <array>
        <string>en</string>
        <string>zh-Hans</string>
    </array>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

mkdir -p "$INSTALL_DIR"

if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "$APP_DIR" >/dev/null
fi

printf '\nInstalled:\n  %s\n\n' "$APP_DIR"
printf 'Open it with:\n  open "%s"\n' "$APP_DIR"
