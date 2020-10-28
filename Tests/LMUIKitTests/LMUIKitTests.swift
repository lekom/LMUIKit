import XCTest
@testable import LMUIKit

final class LMUIKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(LMUIKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
