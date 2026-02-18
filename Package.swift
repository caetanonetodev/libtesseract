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
      checksum: "c9f73db902b2c027aa2d1270fabc8c46fc29033ab4ff8e6e9fda6dc1b080be7c"
    )
  ]
)

