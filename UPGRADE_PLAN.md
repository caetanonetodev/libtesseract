# libtesseract xcframework — Upgrade Plan (4.1.3 → 5.5.2)

## Context

- **SwiftyTesseract wrapper**: `/Users/caetano/Documents/SwiftTesseract`
- **libtesseract binary package**: `/Users/caetano/Documents/libtesseract`
- **Tesseract 5.5.2 source**: `/Users/caetano/Documents/tesseract`
- **Current Tesseract version in xcframework**: 4.1.3
- **Target Tesseract version**: 5.5.2

## Phase 1: Taskfile.yml — Version & Source Updates [COMPLETED]

All changes applied to `Taskfile.yml`:

| Variable | Before | After |
|---|---|---|
| `TESSERACT_VERSION` | `4.1.3` | `5.5.2` |
| `TESSERACT_LOCAL_SRC` | *(new)* | `/Users/caetano/Documents/tesseract` |
| `LEPTONICA_VERSION` | `1.82.0` | `1.84.1` |
| `PNG_VERSION` | `1.6.37` | `1.6.44` |
| `JPEG_SRC_NAME` | `jpegsrc.v9e` | `jpegsrc.v9f` |
| `JPEG_DIR_NAME` | `jpeg-9e` | `jpeg-9f` |
| `TIFF_NAME` | `tiff-4.3.0` | `tiff-4.7.0` |

`download-libtesseract` task changed from `curl` + `unzip` from GitHub
to `rsync` from local source at `/Users/caetano/Documents/tesseract`
(excluding `.git` and `build` directories).

All dependency download URLs verified as reachable.

## Phase 2: Remove the Patch [COMPLETED]

- Deleted entire `patch/` directory (contained only `optional_libcurl.patch`)
- Removed the `patch configure.ac ../patch/optional_libcurl.patch` line
  from `autogen-libtesseract` task in `Taskfile.yml`
- Tesseract 5.x natively supports `--without-curl` — patch no longer needed

## Phase 3: Update Compiler Flags [COMPLETED]

Changes applied to `Taskfile.yml`:

- Added `-std=c++17` to `configure-libtesseract` CXXFLAGS (required by Tesseract 5.x)
  - Only applied to Tesseract; Leptonica/libpng/libjpeg/libtiff are C libraries
- Removed `-fembed-bitcode` from CFLAGS in all 5 configure tasks:
  - `configure-libtesseract`
  - `configure-liblept`
  - `configure-libpng`
  - `configure-libjpeg`
  - `configure-libtiff`
- `--disable-legacy` kept on `configure-libtesseract` (LSTM-only, smaller binary)
- Target: Xcode 26.2 (bitcode fully removed since Xcode 15)

## Phase 4: Update Headers in Xcode Project [COMPLETED]

Removed 8 Tesseract headers no longer in 5.x public API from `project.pbxproj`:
- `platform.h`, `strngs.h`, `genericvector.h`, `tesscallback.h`
- `serialis.h`, `apitypes.h`, `tess_version.h`, `thresholder.h`
- Removed all PBXBuildFile (16 entries), PBXFileReference (8 entries),
  PBXGroup children (8 entries), and PBXHeadersBuildPhase (16 entries)

Added 2 new Tesseract headers to `project.pbxproj`:
- `export.h` (public, replaces `platform.h`)
- `version.h` (generated at build time from `version.h.in`)
- Added PBXBuildFile (4 entries), PBXFileReference (2 entries),
  PBXGroup children (2 entries), PBXHeadersBuildPhase (4 entries)

All Leptonica/libpng/libjpeg/libtiff headers: unchanged.
Umbrella header `libtesseract.h`: unchanged (imports still valid).

## Phase 5: Update Xcode Project Build Settings [COMPLETED]

Changes applied to `project.pbxproj`:

- Updated `CLANG_CXX_LANGUAGE_STANDARD` from `gnu++14` to `gnu++17` (4 occurrences)
- Replaced hardcoded `iPhoneOS14.0.sdk` paths for `libc++.tbd` and `libz.tbd`
  with SDK-relative paths using `sourceTree = SDKROOT`

## Phase 6: Update CI Workflows [COMPLETED]

Changes applied to `.github/workflows/`:

**build.yml:**
- Removed `sudo xcode-select --switch /Applications/Xcode_12.4.app` step
- Updated `actions/checkout@v1` → `@v4`

**deliver.yml:**
- Removed `sudo xcode-select --switch /Applications/Xcode_12.4.app` step
- Updated `actions/checkout@v1` → `@v4`
- Updated `EndBug/add-and-commit@v4` → `@v9`
- Removed `GITHUB_TOKEN` env block (v9 uses default token automatically)

**publish.yml:**
- Updated `actions/checkout@v1` → `@v4`

**Note:** CI `download-libtesseract` task uses local rsync and won't work
in CI runners. To be addressed when setting up the fork/release pipeline.

## Phase 7: Test Build

1. Build a **single slice first** (e.g., macOS arm64) to validate the
   autotools cross-compilation still works with Tesseract 5.5.2:
   ```
   task install-libtesseract SDK=<macos-sdk> PLATFORM_VERSION_MIN=macosx-version-min=10.13 \
     HOST=arm-apple-darwin64 ARCH_NAME=arm-apple-darwin64 ARCH=arm64 PLATFORM_PREFIX=macos
   ```
2. Verify the resulting `libtesseract.a` contains expected symbols:
   ```
   nm macos/arm-apple-darwin64/libtesseract.a | grep TessBaseAPICreate
   ```
3. If single slice succeeds, run full build:
   ```
   task build-tesseract-xcframework-zip
   ```
4. Build time: expect 2-3 hours for full xcframework (8 slices × 5 libraries).

## Phase 8: Package & Release

1. After successful build, run:
   ```
   python3 update_package_swift.py --version <new-version>
   ```
2. Update the GitHub URL in `update_package_swift.py` to point to your
   fork's releases (not `SwiftyTesseract/libtesseract`)
3. Create a GitHub release on your fork with the
   `libtesseract-<version>.xcframework.zip` attached

## Phase 9: Update SwiftyTesseract

In `/Users/caetano/Documents/SwiftTesseract/Package.swift` (line 8):

```swift
// Change from:
.package(url: "https://github.com/SwiftyTesseract/libtesseract.git", .upToNextMinor(from: "0.2.0"))
// To:
.package(url: "https://github.com/<your-fork>/libtesseract.git", .upToNextMinor(from: "<new-version>"))
```

No Swift source code changes are required in SwiftyTesseract — all 16 C API
functions used are unchanged in Tesseract 5.x.

## Risks

| Phase | Risk | Mitigation |
|---|---|---|
| Phase 3 | autotools cross-compilation may fail for 5.x | Test single slice first; fall back to CMake if needed |
| Phase 4 | Header mismatch causes framework build failure | Catalog exact installed headers from test build |
| Phase 5 | Older Xcode may not support C++17 fully | Use Xcode 15+ |
| Phase 6 | Bitcode removal breaks Xcode < 14 | Acceptable — Xcode 14+ is baseline |

## Estimated Effort

| Phase | Time |
|---|---|
| Phase 1-3 (Taskfile changes) | 1 hour |
| Phase 4-5 (Xcode project) | 1-2 hours |
| Phase 6 (CI) | 30 min |
| Phase 7 (test builds) | 2-4 hours (mostly build wait time) |
| Phase 8-9 (release + SwiftyTesseract) | 30 min |
| **Total** | **1-2 days** |
