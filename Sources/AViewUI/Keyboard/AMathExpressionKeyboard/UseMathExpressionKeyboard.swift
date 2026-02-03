import AMathExpression
import SwiftUI

@available(iOS 16.0, macOS 12, tvOS 13.0, watchOS 8, *)
extension TextField {
    @ViewBuilder
    public func useAMathKeyboard<ANumber: Codable & Sendable & Real & BinaryFloatingPoint>(
        height: CGFloat, format: FloatingPointFormatStyle<ANumber>, setString: @escaping (String) -> Void
    ) -> some View {
        #if os(iOS)
        self.aKeyboardView { uiTextfield in
            let context = ACustomKeyboardInputContext(uiTextfield)
            AMathExpressionKeyboard(context, format: format, setString: setString)
                .frame(height: height)
        }
        #elseif os(tvOS)
        self.keyboardType(.decimalPad)
        #else
        self
        #endif
    }
    @ViewBuilder
    public func useAMathKeyboard<ANumber: Codable & Sendable & Real & BinaryFloatingPoint>(
        height: CGFloat, format: FloatingPointFormatStyle<ANumber>
    ) -> some View {
        #if os(iOS)
        self.aKeyboardView { uiTextfield in
            let context = ACustomKeyboardInputContext(uiTextfield)
            AMathExpressionKeyboard(context, format: format)
                .frame(height: height)
        }
        #elseif os(tvOS)
        self.keyboardType(.decimalPad)
        #else
        self
        #endif
    }

    @ViewBuilder
    public func useAMathKeyboard<ANumber: Codable & Sendable & Real & BinaryFloatingPoint>(
        height: CGFloat, format: FloatingPointFormatStyle<ANumber>, _ bindString: Binding<String>
    ) -> some View {
        #if os(iOS)
        self.aKeyboardView { uiTextfield in
            let context = ACustomKeyboardInputContext(uiTextfield)
            AMathExpressionKeyboard(context, bindString, format: format)
                .frame(height: height)
        }
        #elseif os(tvOS)
        self.keyboardType(.decimalPad)
        #else
        self
        #endif
    }

    @ViewBuilder
    public func useAMathKeyboard<ANumber: Codable & Sendable & Real & BinaryFloatingPoint>(
        height: CGFloat, format: AMathFormatStyle<ANumber>
    ) -> some View {
        #if os(iOS)
        self.aKeyboardView { uiTextfield in
            let context = ACustomKeyboardInputContext(uiTextfield)
            AMathExpressionKeyboard(context, format: format.displayedFormat)
                .frame(height: height)
        }
        #elseif os(tvOS)
        self.keyboardType(.decimalPad)
        #else
        self
        #endif
    }

    @ViewBuilder
    public func useAMathKeyboard<ANumber: Codable & Sendable & Real & BinaryFloatingPoint>(
        height: CGFloat, format: AMathFormatStyle<ANumber>, _ bindString: Binding<String>
    ) -> some View {
        #if os(iOS)
        self.aKeyboardView { uiTextfield in
            let context = ACustomKeyboardInputContext(uiTextfield)
            AMathExpressionKeyboard(context, bindString, format: format.displayedFormat)
                .frame(height: height)
        }
        #elseif os(tvOS)
        self.keyboardType(.decimalPad)
        #else
        self
        #endif
    }
}
