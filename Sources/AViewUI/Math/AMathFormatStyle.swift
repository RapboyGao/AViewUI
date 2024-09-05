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
        self.parseStrategy = Strategy(displayedFormat: displayedFormat.grouping(.never))
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension AMathFormatStyle where ANumber == Double {
    static func precision(_ precision: FloatingPointFormatStyle<Double>.Configuration.Precision) -> Self {
        .init(.number.precision(precision))
    }

    static func fractionLength(_ fractionLimit: Int) -> Self {
        if fractionLimit <= 0 {
            return .init(.number.precision(.fractionLength(0)))
        } else {
            return .init(.number.precision(.fractionLength(0 ... fractionLimit)))
        }
    }

    static func significantDigits(_ significantDigits: Int) -> Self {
        if significantDigits <= 0 {
            return .init(.number.precision(.significantDigits(0)))
        } else {
            return .init(.number.precision(.significantDigits(0 ... significantDigits)))
        }
    }
}
