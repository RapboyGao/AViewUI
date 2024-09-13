@testable import AViewUI // replace with actual project name
import JavaScriptCore
import XCTest

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)

class AMathEvaluationBenchmarkTests: XCTestCase {

    // Sample math expression to evaluate
    let mathExpression = "3 * (2 + 5) / 7 ^ 2"
    
    // Setting up AMathFormatStyle evaluation
    func evaluateWithAMathFormatStyle(expression: String) -> Double? {
        let mathStyle = AMathFormatStyle<Double>.precision(.fractionLength(10)) // Adjust the format style as needed
        return try? mathStyle.parseStrategy.parse(expression)
    }
    
    // Setting up JavaScriptCore evaluation
    func evaluateWithJavaScriptCore(expression: String) -> Double? {
        let jsContext = JSContext()
        let result = jsContext?.evaluateScript(expression)
        return result?.toDouble()
    }

    // Measure performance for AMathFormatStyle.evaluate
    func testPerformanceAMathFormatStyle() {
        let iterations = 1000
        
        measure {
            for _ in 0..<iterations {
                _ = evaluateWithAMathFormatStyle(expression: mathExpression)
            }
        }
    }
    
    // Measure performance for JavaScriptCore.evaluate
    func testPerformanceJavaScriptCore() {
        let iterations = 1000
        
        measure {
            for _ in 0..<iterations {
                _ = evaluateWithJavaScriptCore(expression: mathExpression)
            }
        }
    }
}
