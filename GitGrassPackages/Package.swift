// swift-tools-version: 6.0

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
]

let package = Package(
    name: "GitGrassPackages",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "DataLayer",
            targets: ["DataLayer"]
        ),
        .library(
            name: "Domain",
            targets: ["Domain"]
        ),
        .library(
            name: "Presentation",
            targets: ["Presentation"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", exact: "1.6.1"),
        .package(url: "https://github.com/Kyome22/DependencyList.git", exact: "0.2.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", exact: "4.2.2"),
    ],
    targets: [
        .target(
            name: "DataLayer",
            dependencies: [
                .product(name: "DependencyList", package: "DependencyList"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "KeychainAccess", package: "KeychainAccess"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Domain",
            dependencies: [
                "DataLayer",
                .product(name: "Logging", package: "swift-log"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: [
                "DataLayer",
                "Domain",
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Presentation",
            dependencies: [
                "Domain",
            ],
            swiftSettings: swiftSettings
        ),
    ]
)
