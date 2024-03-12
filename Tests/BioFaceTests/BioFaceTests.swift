import XCTest
@testable import BioFace

final class BioFaceTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BioFace(token: "ABC").getToken(), "ABC")
    }
}
