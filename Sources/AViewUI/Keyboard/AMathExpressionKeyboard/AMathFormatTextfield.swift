import AMathExpression
import SwiftUI

@available(iOS 16.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
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

@available(iOS 16.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)#Preview{
    AMathFormatTextfield(number: .constant(25), precision: .fractionLength(0...3), placeholder: "Hello")
}
