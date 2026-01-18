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
