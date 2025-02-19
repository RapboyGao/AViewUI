import AMathExpression
import SwiftUI

@available(iOS 16, macOS 12, tvOS 13, watchOS 8, *)
public struct AMathFormatTextfield: View {
    @Binding var number: Double?
    var precision: NumberFormatStyleConfiguration.Precision
    var placeholder: String

    private var format: AMathFormatStyle<Double> {
        .precision(precision)
    }

    public var body: some View {
        TextField(placeholder, value: $number, format: format)
            .useAMathKeyboard(height: 250, format: format)
    }

    public init(number: Binding<Double?>, precision: NumberFormatStyleConfiguration.Precision, placeholder: String) {
        self._number = number
        self.precision = precision
        self.placeholder = placeholder
    }
}

@available(iOS 16, macOS 12, tvOS 13, watchOS 8, *)
private struct Example: View {
    @State private var number: Double? = 1.0

    var body: some View {
        AMathFormatTextfield(number: $number, precision: .fractionLength(0...3), placeholder: "Hello")
    }
}

@available(iOS 16, macOS 12, tvOS 13, watchOS 8, *)#Preview{
    Example()
}
