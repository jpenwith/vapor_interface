// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "VaporInterface",
    platforms: [
        .iOS(.v13),
        .macOS(.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "VaporInterface",
            targets: ["VaporInterface"]
        ),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "VaporInterface",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
            ]),
        .target(
            name: "Example",
            dependencies: [
                .target(name: "VaporInterface"),
                .product(name: "Vapor", package: "vapor")
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides/blob/main/docs/building.md#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .executableTarget(
            name: "Run",
            dependencies: [.target(name: "Example")]
        ),
        .testTarget(
            name: "VaporInterfaceTests",
            dependencies: [
                .target(name: "Example"),
                .product(name: "XCTVapor", package: "vapor"),
            ]
        )
    ]
)
