import Foundation
import Numerics

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct AMathFormatStyle<ANumber: Real & Codable & Sendable & BinaryFloatingPoint>: ParseableFormatStyle {
    public var displayedFormat: FloatingPointFormatStyle<ANumber>
    public var parseStrategy: Strategy

    public func format(_ value: ANumber) -> String {
        displayedFormat.format(value)
    }

    public struct Strategy: ParseStrategy {
        public var displayedFormat: FloatingPointFormatStyle<ANumber>

        public func parse(_ value: String) throws -> ANumber {
            guard let number = AMathExpression<ANumber>(value)?.evaluate() else {
                return try displayedFormat.parseStrategy.parse(value)
            }
            return number
        }

        public init(displayedFormat: FloatingPointFormatStyle<ANumber>) {
            self.displayedFormat = displayedFormat
        }
    }

    public init(_ displayedFormat: FloatingPointFormatStyle<ANumber>) {
        self.displayedFormat = displayedFormat
        self.parseStrategy = Strategy(displayedFormat: displayedFormat)
    }
}
