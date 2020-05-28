// swift-tools-version:5.0
//
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//

import PackageDescription

let package = Package(
    name: "XLPagerTabStrip",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "XLPagerTabStrip", targets: ["XLPagerTabStrip"])
    ],
    targets: [
        .target(name: "XLPagerTabStrip", path: "Sources"),
        .testTarget(name: "XLPagerTabStripTests", dependencies: ["XLPagerTabStrip"], path: "Tests")
    ],
    swiftLanguageVersions: [
        .v4_2
    ]
)
