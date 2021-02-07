// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "graphql-syntax",
    products: [
        .library(name: "GraphQLSyntax",
                 targets: ["GraphQLSyntax"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nerdsupremacist/Syntax.git", from: "1.0.2"),
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
