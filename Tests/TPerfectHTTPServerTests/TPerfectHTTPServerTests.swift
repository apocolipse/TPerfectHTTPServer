import XCTest
@testable import TPerfectHTTPServer

class TPerfectHTTPServerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(TPerfectHTTPServer().text, "Hello, World!")
    }


    static var allTests : [(String, (TPerfectHTTPServerTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
