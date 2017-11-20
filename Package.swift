// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Server",
    dependencies: [
      .package(url: "https://github.com/IBM-Swift/Kitura.git", from: "2.0.0"),
      .package(url: "https://github.com/IBM-Swift/Kitura-CORS.git", from: "2.0.0"),
      .package(url: "https://github.com/IBM-Swift/Swift-Kuery-PostgreSQL", from: "1.0.0"),
      .package(url: "https://github.com/IBM-Swift/Swift-SMTP", from: "1.1.3"),
      .package(url: "https://github.com/IBM-Swift/SwiftyJSON", from: "17.0.0"),
      .package(url: "https://github.com/sdrpa/then", from: "3.0.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Bittrex",
            dependencies: ["Kitura", "KituraCORS", "SwiftKueryPostgreSQL", "SwiftSMTP", "SwiftyJSON", "then"]),
        .testTarget(
            name: "BittrexTests",
            dependencies: ["Bittrex"]),
        .target(
            name: "Server",
            dependencies: ["Bittrex"])
    ]
)
