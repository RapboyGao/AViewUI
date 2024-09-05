@testable import AViewUI
import XCTest

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
final class AViewUITests: XCTestCase {
    func test1() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest
        
        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
        let text = "12,345 + max(12,345)"
        if let result = AMathExpression<Double>(text), let evaluated = result.evaluate() {
            print(result)
            print(evaluated)
        }
        
        let result = AMathFormatStyle<Double>(.number.precision(.significantDigits(0 ... 10)))
        try print(result.parseStrategy.parse(text))
    }
    
    func test2() throws {
        let format = AMathFormatStyle<Double>(.number.grouping(.never).precision(.fractionLength(0 ... 10)))
        print(type(of: format))
    }
    
    func test3() throws {
        let a: Decimal = 3
        let b: Decimal = -0.5
        print(pow(3.0, -0.5))
        print(a.pow(b))
    }
}
