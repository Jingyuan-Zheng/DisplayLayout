// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DisplayLayout",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "DisplayLayout", targets: ["DisplayLayout"])
    ],
    targets: [
        .executableTarget(
            name: "DisplayLayout",
            path: "Sources/DisplayLayout"
        )
    ]
)
