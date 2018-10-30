// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "TPerfectHTTPServer",
  dependencies: [
    .package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
    .package(url: "https://github.com/apocolipse/Thrift-Swift.git", from: "1.1.0")
  ]
)

