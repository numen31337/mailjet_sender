// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MailjetSender",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v2),
        .macOS(.v10_11)
    ],
    products: [
        .library(
            name: "MailjetSender",
            targets: ["MailjetSender"]),
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0")),
    ],
    targets: [
        .target(
            name: "MailjetSender",
            dependencies: ["ZIPFoundation"]),
    ]
)
