// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "GenericProtocolVariable",
    targets: [
        .target(
            name: "GenericProtocolVariable",
            dependencies: []
        ),
        .testTarget(
            name: "GenericProtocolVariableTests",
            dependencies: ["GenericProtocolVariable"]
        ),
    ]
)
