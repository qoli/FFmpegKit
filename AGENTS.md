# Repository Guidelines

## Project Structure & Module Organization
- `Sources/` holds Swift Package targets, C sources for `ffmpeg`/`ffplay`/`ffprobe`, and prebuilt `.xcframework` binaries (e.g., `Sources/Libavcodec.xcframework`).
- `Plugins/BuildFFmpeg/` contains the Swift Package plugin that builds FFmpeg and its dependencies.
- `Demo/` is an Xcode workspace with iOS/macOS/tvOS sample apps and CocoaPods setup (`Podfile`).
- `Package.swift` defines SwiftPM products; `*.podspec` files define CocoaPods specs.

## Build, Test, and Development Commands
- `swift package --disable-sandbox BuildFFmpeg` builds native libraries and XCFrameworks (requires Homebrew and network access).
- `swift package BuildFFmpeg -h` prints build options and supported libraries/platforms.
- `swift run ffmpeg`, `swift run ffplay`, `swift run ffprobe` run the bundled executables.
- `cd Demo && pod install` sets up the demo workspace.
- Example local build: `xcodebuild -workspace Demo.xcworkspace -scheme macOS` (CI uses similar commands in `.github/workflows/build.yml`).

## Coding Style & Naming Conventions
- Swift: 4-space indentation, follow existing patterns and Swift API Design Guidelines.
- Keep file/type names descriptive (e.g., `BuildFFMPEG.swift`, `BuildMPV.swift`).
- C sources under `Sources/ffmpeg`, `Sources/ffplay`, `Sources/ffprobe` are upstream; avoid reformatting and keep changes minimal.
- No enforced formatter/linter is present; match the surrounding file style.

## Testing Guidelines
- No dedicated unit test targets are present. Validate changes by building the demo workspace and running the CLI tools.
- If adding tests, prefer SwiftPM `Tests/` targets or Xcode test bundles and name files `*Tests.swift`.

## Commit & Pull Request Guidelines
- Commit history favors short, imperative messages (e.g., “fix build”, “update”), sometimes in Chinese. Keep commits concise and scoped.
- PRs should describe the change, affected platforms, and commands run; link related issues. Add screenshots only for demo UI changes.

## License & Build Notes
- The default build enables GPL components (e.g., `libsmbclient`). Review `LICENSE` before distributing.
- The build plugin writes to a local `.Script/` directory and may require `--disable-sandbox` or explicit SwiftPM permissions.
