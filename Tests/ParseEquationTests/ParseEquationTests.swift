import XCTest
@testable import ParseEquation

final class ParseEquationTests: XCTestCase {
    func testExample() throws {
        // Use XCTAssert and related functions to verify
        // your tests produce the correct results.
        XCTAssertEqual(ParseEquation().parse(equation: "-5*10+100-25 / 2.5 + 12"), 42.0)
    }
}
