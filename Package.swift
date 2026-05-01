// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "graphql-syntax",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "GraphQLSyntax",
                 targets: ["GraphQLSyntax"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nerdsupremacist/Syntax.git", from: "3.0.0"),
    ],
    targets: [
        .target(
            name: "GraphQLSyntax",
            dependencies: ["Syntax"]),
        .testTarget(
            name: "GraphQLSyntaxTests",
            dependencies: ["GraphQLSyntax"]),
    ]
)
