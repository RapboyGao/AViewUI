@testable import AViewUI
import XCTest

final class AViewUITests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods

        if let result = AMathExpression("cos(60) * 45") {
            print(result)
            print(result.evaluate())
        }
    }
}
