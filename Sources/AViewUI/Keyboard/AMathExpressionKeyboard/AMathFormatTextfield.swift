import AMathExpression
import SwiftUI

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
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

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
private struct Example: View {
    @State private var number: Double? = 1.0

    var body: some View {
        AMathFormatTextfield(number: $number, precision: .fractionLength(0...3), placeholder: "Hello")
        Text(number ?? .nan, format: .number)
    }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1.0, *)
#Preview {
    #if os(iOS)
    List {
        Example()
    }
    #elseif os(macOS)
    VStack(spacing: 12) {
        Example()
    }
    .padding()
    .frame(width: 360)
    #elseif os(tvOS)
    VStack(spacing: 12) {
        Example()
    }
    .padding()
    .frame(width: 600)
    #elseif os(watchOS)
    VStack(spacing: 8) {
        Example()
    }
    .padding(6)
    #elseif os(visionOS)
    VStack(spacing: 12) {
        Example()
    }
    .padding()
    .frame(width: 420)
    #else
    Text("Preview not available")
    #endif
}
