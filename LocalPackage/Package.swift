// swift-tools-version: 6.2

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
]

let package = Package(
    name: "LocalPackage",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "DataSource",
            targets: ["DataSource"]
        ),
        .library(
            name: "Model",
            targets: ["Model"]
        ),
        .library(
            name: "UserInterface",
            targets: ["UserInterface"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", exact: "1.10.1"),
        .package(url: "https://github.com/Kyome22/DependencyList.git", exact: "1.1.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", exact: "4.2.2"),
    ],
    targets: [
        .target(
            name: "DataSource",
            dependencies: [
                .product(name: "DependencyList", package: "DependencyList"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Model",
            dependencies: [
                "DataSource",
                .product(name: "Logging", package: "swift-log"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "UserInterface",
            dependencies: [
                "DataSource",
                "Model",
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "ModelTests",
            dependencies: [
                "DataSource",
                "Model",
            ],
            swiftSettings: swiftSettings
        ),
    ]
)
