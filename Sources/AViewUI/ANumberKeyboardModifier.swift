import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct ANumberKeyboardModifier: ViewModifier {
    @Binding var value: Double?
    var digits: Int

    @State private var rotationAngle: Double = 0 // State variable to track rotation
    @FocusState private var isFocused: Bool

    public init(value: Binding<Double?>, digits: Int) {
        self._value = value
        self.digits = digits
    }

    public func body(content: Content) -> some View {
        content
            .autocorrectionDisabled()
            .focused($isFocused)
#if os(iOS)
            .keyboardType(.decimalPad)
            .textContentType(.oneTimeCode)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if isFocused {
                        if let currentValue = value, !currentValue.isZero {
                            Button {
                                value = -currentValue
                            } label: {
                                Text(-currentValue, format: .number.precision(.significantDigits(0 ... digits)))
                                    .foregroundStyle(currentValue > 0 ? .red : .blue)
                            }
                        }
                        Spacer()
                        Button {
                            value = nil
                            withAnimation {
                                rotationAngle -= 360
                            }
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                        }
                        .rotationEffect(.degrees(rotationAngle)) // Apply rotation effect
                        .onAppear {
                            withAnimation {
                                rotationAngle = 0
                            }
                        }
                    }
                }
            }
#endif
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
#Preview {
    NavigationStack {
        List {
            TextField("Hello", value: .constant(50), format: .number.precision(.significantDigits(0 ... 10)))
                .modifier(ANumberKeyboardModifier(value: .constant(50), digits: 10))
        }
    }
}
