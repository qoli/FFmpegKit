#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Clean Vulkan/MoltenVK external build cache to avoid stale platform slices.
rm -rf \
  .Script/vulkan-v1.2.8/External/build \
  .Script/vulkan-v1.2.8/External/Latest \
  .Script/vulkan-v1.2.8/External/Release \
  .Script/vulkan-v1.2.8/External/Intermediates

# Clean Xcode derived data for MoltenVK packaging (if any).
rm -rf "$HOME/Library/Developer/Xcode/DerivedData/MoltenVKPackaging-"*

# Build only tvOS + tvOS Simulator.
swift package --disable-sandbox BuildFFmpeg platforms=tvos,tvsimulator

# Workaround: add fake tvOS Simulator slice for MoltenVK.xcframework if missing.
MVK_XCFRAMEWORK="$ROOT/Sources/MoltenVK.xcframework"
if [ -d "$MVK_XCFRAMEWORK" ]; then
  MVK_SIM_SLICE="$MVK_XCFRAMEWORK/tvos-arm64_x86_64-simulator"
  TMP_DIR="$(mktemp -d /tmp/mvk_fake_slice.XXXXXX)"
  trap 'rm -rf "$TMP_DIR"' EXIT

  printf "" | xcrun --sdk appletvsimulator clang -x c - -c -target arm64-apple-tvos-simulator -o "$TMP_DIR/empty_arm64.o"
  printf "" | xcrun --sdk appletvsimulator clang -x c - -c -target x86_64-apple-tvos-simulator -o "$TMP_DIR/empty_x86_64.o"

  libtool -static -o "$TMP_DIR/libMoltenVK_arm64.a" "$TMP_DIR/empty_arm64.o"
  libtool -static -o "$TMP_DIR/libMoltenVK_x86_64.a" "$TMP_DIR/empty_x86_64.o"
  lipo -create "$TMP_DIR/libMoltenVK_arm64.a" "$TMP_DIR/libMoltenVK_x86_64.a" -output "$TMP_DIR/libMoltenVK.a"

  mkdir -p "$MVK_SIM_SLICE"
  cp -f "$TMP_DIR/libMoltenVK.a" "$MVK_SIM_SLICE/libMoltenVK.a"

  python - <<'PYIN'
import plistlib
from pathlib import Path

plist_path = Path("/Volumes/Data/Github/FFmpegKit/Sources/MoltenVK.xcframework/Info.plist")
with plist_path.open('rb') as f:
    plist = plistlib.load(f)

libs = plist.get('AvailableLibraries', [])
identifier = "tvos-arm64_x86_64-simulator"
if not any(x.get('LibraryIdentifier') == identifier for x in libs):
    libs.append({
        "BinaryPath": "libMoltenVK.a",
        "LibraryIdentifier": identifier,
        "LibraryPath": "libMoltenVK.a",
        "SupportedArchitectures": ["arm64", "x86_64"],
        "SupportedPlatform": "tvos",
        "SupportedPlatformVariant": "simulator",
    })
    plist['AvailableLibraries'] = libs
    with plist_path.open('wb') as f:
        plistlib.dump(plist, f)
PYIN

  trap - EXIT
  rm -rf "$TMP_DIR"
else
  echo "MoltenVK.xcframework not found at $MVK_XCFRAMEWORK; skipping fake simulator slice."
fi

