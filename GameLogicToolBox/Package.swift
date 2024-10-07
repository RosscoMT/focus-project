// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GameLogicToolBox",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v11),
    ],
    products: [
        .library(
            name: "GameLogicToolBox",
            targets: ["Engine"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "Engine",
                dependencies: []),
        .testTarget(name: "GameLogicToolBoxTests",
                dependencies: ["Engine"],
                    path: "Tests", resources: [.process("Resources/TestConfiguration.plist")])
    ]
)
