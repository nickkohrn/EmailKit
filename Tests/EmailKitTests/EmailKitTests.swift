import XCTest
@testable import EmailKit

final class EmailKitTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(EmailKit().text, "Hello, World!")
    }
}
