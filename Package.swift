// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Relapse",
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "4.0.0"),
    ],
    targets: [
        .target(name: "Relapse", dependencies: ["RelapseCore"]),
        .target(name: "RelapseCore", dependencies: ["GRDB"]),
        .testTarget(name: "RelapseTests",dependencies: ["Relapse"]),
    ]
)
