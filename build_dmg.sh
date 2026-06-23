#!/bin/bash
set -e

# Make sure we are in the script directory
cd "$(dirname "$0")"

echo "=== Cleaning and building Release app bundle ==="
# Clean old build artifacts
rm -rf build
# Build the release configuration into the local 'build' directory
xcodebuild -scheme toolcase -configuration Release -sdk macosx SYMROOT=build build

echo "=== Creating DMG packaging environment ==="
PACKAGING_DIR="build/packaging"
rm -rf "$PACKAGING_DIR"
mkdir -p "$PACKAGING_DIR"

# Copy the app bundle
cp -R "build/Release/toolcase.app" "$PACKAGING_DIR/"

# Create a symlink to /Applications for easy drag-and-drop installation
ln -s /Applications "$PACKAGING_DIR/Applications"

# Generate the DMG file
DMG_NAME="Toolcase.dmg"
rm -f "$DMG_NAME"

echo "=== Compiling DMG ==="
hdiutil create -volname "Toolcase" -srcfolder "$PACKAGING_DIR" -ov -format UDZO "$DMG_NAME"

echo "=== Cleaning temporary packaging files ==="
rm -rf "$PACKAGING_DIR"

echo "=============================================="
echo "Success! Generated: $(pwd)/$DMG_NAME"
echo "=============================================="
