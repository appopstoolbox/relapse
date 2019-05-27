// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Relapse",
    platforms: [.macOS(.v10_13)],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "4.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.5.0"),
    ],
    targets: [
        .target(name: "relapse", dependencies: ["RelapseCore"]),
        .target(name: "RelapseCore", dependencies: ["GRDB"]),
        .testTarget(name: "RelapseTests",dependencies: ["relapse", "SnapshotTesting"]),
    ]
)
