#!/bin/bash
set -e

APP_NAME="TrackingApp"
BUILD_DIR=".build/release"
APP_BUNDLE="$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS/MacOS"

echo "🔨 Building release..."
swift build -c release

echo "📦 Creating .app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"

cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/$APP_NAME"
cp Info.plist "$CONTENTS/Info.plist"

# Include icon if available
if [ -f "AppIcon.icns" ]; then
    mkdir -p "$CONTENTS/Resources"
    cp AppIcon.icns "$CONTENTS/Resources/AppIcon.icns"
    echo "🖼  Icon included"
fi

echo "✅ Built: $APP_BUNDLE"
echo ""
echo "To run:  open $APP_BUNDLE"
echo "To install:  cp -r $APP_BUNDLE /Applications/"
