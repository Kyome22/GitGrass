// swift-tools-version: 6.2

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
]

let package = Package(
    name: "LocalPackage",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v15),
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
        .package(url: "https://github.com/cybozu/LicenseList.git", exact: "2.3.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", exact: "4.2.2"),
    ],
    targets: [
        .target(
            name: "DataSource",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Model",
            dependencies: [
                "DataSource",
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "UserInterface",
            dependencies: [
                "Model",
                .product(name: "LicenseList", package: "LicenseList"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "DataSourceTests",
            dependencies: [
                "DataSource"
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "ModelTests",
            dependencies: [
                "Model",
            ],
            swiftSettings: swiftSettings
        ),
    ]
)
