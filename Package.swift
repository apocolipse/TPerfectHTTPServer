import PackageDescription

let package = Package(
  name: "TPerfectHTTPServer",
  dependencies: [
    .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git",
             majorVersion: 2, minor: 0),
    .Package(url: "https://github.com/apocolipse/Thrift-Swift.git",
               majorVersion: 1, minor: 0),
  ]
)
