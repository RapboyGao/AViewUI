import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct AMathFormatStyle<SomeFormatStyle: ParseableFormatStyle>: ParseableFormatStyle where SomeFormatStyle.FormatOutput == String, SomeFormatStyle.FormatInput == Double {
    public var displayedFormat: SomeFormatStyle
    public var parseStrategy: Strategy

    public func format(_ value: Double) -> String {
        displayedFormat.format(value)
    }

    public struct Strategy: ParseStrategy {
        public var displayedFormat: SomeFormatStyle

        public func parse(_ value: String) throws -> Double {
            guard let number = Double(value) ?? AMathExpression(value)?.evaluate() else {
                return try displayedFormat.parseStrategy.parse(value)
            }
            return number
        }

        public init(displayedFormat: SomeFormatStyle) {
            self.displayedFormat = displayedFormat
        }
    }

    public init(_ displayedFormat: SomeFormatStyle) {
        self.displayedFormat = displayedFormat
        self.parseStrategy = Strategy(displayedFormat: displayedFormat)
    }
}
