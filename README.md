# libtesseract

![Swift Tools Version Badge](https://img.shields.io/badge/swift%20tools%20version-5.7-blue.svg) ![ios platform badge](https://img.shields.io/badge/iOS-16.0%20%2B-orange.svg) ![catalyst platform badge](https://img.shields.io/badge/macOS%20%28catalyst%29-16.0%20%2B-purple.svg) ![macOS platform badge](https://img.shields.io/badge/macOS-13.0%20%2B-red.svg)

Pre-built [Tesseract OCR](https://github.com/tesseract-ocr/tesseract) xcframework for Apple platforms, distributed as a Swift package. This is a maintained fork of [SwiftyTesseract/libtesseract](https://github.com/SwiftyTesseract/libtesseract).

If you're looking for a Swift-friendly API on top of the raw C library, see [SwiftyTesseract](https://github.com/caetanonetodev/SwiftyTesseract).

## Included Versions

| Library | Version |
|---------|---------|
| Tesseract | 5.5.2 |
| Leptonica | 1.84.1 |
| libpng | 1.6.44 |
| libjpeg | 9f |
| libtiff | 4.7.0 |

## Supported Platforms

| Platform | Architectures | Minimum Version |
|----------|--------------|-----------------|
| iOS | arm64 | 16.0 |
| iOS Simulator | arm64, x86_64 | 16.0 |
| macOS | arm64, x86_64 | 13.0 |
| Mac Catalyst | arm64 | 16.0 |

## Installation

Add libtesseract as a Swift Package dependency:

```swift
// Package.swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "AwesomePackage",
  platforms: [
    .macOS(.v13),
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "AwesomePackage",
      targets: ["AwesomePackage"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/caetanonetodev/libtesseract.git", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "AwesomePackage",
      dependencies: ["libtesseract"],
      linkerSettings: [
        .linkedLibrary("z"),
        .linkedLibrary("c++"),
        .linkedFramework("Accelerate"),
      ]
    ),
  ]
)
```

### Required Linker Dependencies

Your target must link against the following:

- **libz** — compression
- **libc++** — C++ standard library
- **Accelerate.framework** — signal processing (used by Leptonica)

In an Xcode project, add these in **Build Phases > Link Binary with Libraries**.

## Building from Source

If you want to build the xcframework locally, you need `automake`, `pkg-config`, and `task` installed:

```bash
brew install automake pkg-config go-task/tap/go-task
```

Then run:

```bash
task build-tesseract-xcframework-zip
```

This compiles all 5 libraries for all 4 platforms and produces `libtesseract.xcframework` and a zip file ready for release.

## Attributions

libtesseract distributes the following dependencies in binary form:

- [Tesseract](https://github.com/tesseract-ocr/tesseract) — Licensed under the [Apache v2 License](https://github.com/tesseract-ocr/tesseract/blob/master/LICENSE)
- [Leptonica](http://www.leptonica.org) — Licensed under the [BSD 2-Clause License](http://www.leptonica.org/about-the-license.html)
- [libpng](http://www.libpng.org) — Licensed under the [Libpng License](http://www.libpng.org/pub/png/src/libpng-LICENSE.txt)
- [libjpeg](http://libjpeg.sourceforge.net) — Licensed under the [Libjpeg License](http://jpegclub.org/reference/libjpeg-license/)
- [libtiff](http://www.libtiff.org) — Licensed under the [Libtiff License](https://fedoraproject.org/wiki/Licensing:Libtiff?rd=Licensing/libtiff)
