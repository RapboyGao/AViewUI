import AMathExpression
import SwiftUI

@available(iOS 16, macOS 12, tvOS 13, watchOS 8, *)
public struct AMathFormatTextfield: View {
    @Binding var number: Double?
    var precision: NumberFormatStyleConfiguration.Precision
    var placeholder: String
    var rightAligned: Bool

    private var format: AMathFormatStyle<Double> {
        .precision(precision)
    }

    public var body: some View {
        ACustomKeyboardOptionalFormatField(
            placeholder,
            value: $number,
            format: format,
            configure: { textField in
                if rightAligned {
                    textField.textAlignment = .right
                }
            }
        ) { context, input in
            AMathExpressionKeyboard(context, format)
                .frame(height: 280)
        }
    }

    public init(
        number: Binding<Double?>,
        precision: NumberFormatStyleConfiguration.Precision,
        placeholder: String,
        rightAligned: Bool = false
    ) {
        self._number = number
        self.precision = precision
        self.placeholder = placeholder
        self.rightAligned = rightAligned
    }
}

@available(iOS 16, macOS 12, tvOS 13, watchOS 8, *)
private struct Example: View {
    @State private var number: Double? = 1.0

    var body: some View {
        AMathFormatTextfield(number: $number, precision: .fractionLength(0...3), placeholder: "Hello")
        Text(number ?? .nan, format: .number)
    }
}

@available(iOS 16, macOS 12, tvOS 13, watchOS 8, *)
#Preview {
    List {
        Example()
    }
}
