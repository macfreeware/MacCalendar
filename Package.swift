// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacCalendar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MacCalendar", targets: ["MacCalendar"])
    ],
    targets: [
        .executableTarget(
            name: "MacCalendar",
            path: "Sources/MacCalendar"
        )
    ]
)
