// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "libtesseract",
  products: [
    .library(
      name: "libtesseract",
      targets: ["libtesseract"]
    ),
  ],
  dependencies: [],
  targets: [
    .binaryTarget(
      name: "libtesseract",
      url: "https://github.com/caetanonetodev/libtesseract/releases/download/1.0.0/libtesseract-1.0.0.xcframework.zip",
      checksum: "8ba1efff4945c5d0dbdec0a274ce44d4b74d34a3e9f5d649f0ebf7d6e8e7b265"
    )
  ]
)

