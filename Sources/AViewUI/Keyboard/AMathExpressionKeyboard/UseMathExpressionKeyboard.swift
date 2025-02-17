import SwiftUI
import AMathExpression

@available(iOS 16.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension TextField {
    @ViewBuilder
    public func useAMathKeyboard<ANumber: Codable & Sendable & Real & BinaryFloatingPoint>(height: CGFloat, format: FloatingPointFormatStyle<ANumber>, setString: @escaping (String) -> Void) -> some View {
        #if os(iOS)
        self.aKeyboardView { uiTextfield in
            AMathExpressionKeyboard(uiTextfield, format: format, setString: setString)
                .frame(height: height)
        }
        #else
        self.keyboardType(.decimalPad)
        #endif
    }
    @ViewBuilder
    public func useAMathKeyboard<ANumber: Codable & Sendable & Real & BinaryFloatingPoint>(height: CGFloat, format: FloatingPointFormatStyle<ANumber>) -> some View {
        #if os(iOS)
        self.aKeyboardView { uiTextfield in
            AMathExpressionKeyboard(uiTextfield, format: format)
                .frame(height: height)
        }
        #else
        self.keyboardType(.decimalPad)
        #endif
    }

    @ViewBuilder
    public func useAMathKeyboard<ANumber: Codable & Sendable & Real & BinaryFloatingPoint>(height: CGFloat, format: FloatingPointFormatStyle<ANumber>, _ bindString: Binding<String>) -> some View {
        #if os(iOS)
        self.aKeyboardView { uiTextfield in
            AMathExpressionKeyboard(uiTextfield, bindString, format: format)
                .frame(height: height)
        }
        #else
        self.keyboardType(.decimalPad)
        #endif
    }
    
    @ViewBuilder
    public func useAMathKeyboard<ANumber: Codable & Sendable & Real & BinaryFloatingPoint>(height: CGFloat, format: AMathFormatStyle<ANumber>) -> some View {
        #if os(iOS)
        self.aKeyboardView { uiTextfield in
            AMathExpressionKeyboard(uiTextfield, format: format.displayedFormat)
                .frame(height: height)
        }
        #else
        self.keyboardType(.decimalPad)
        #endif
    }

    @ViewBuilder
    public func useAMathKeyboard<ANumber: Codable & Sendable & Real & BinaryFloatingPoint>(height: CGFloat, format: AMathFormatStyle<ANumber>, _ bindString: Binding<String>) -> some View {
        #if os(iOS)
        self.aKeyboardView { uiTextfield in
            AMathExpressionKeyboard(uiTextfield, bindString, format: format.displayedFormat)
                .frame(height: height)
        }
        #else
        self.keyboardType(.decimalPad)
        #endif
    }
}
