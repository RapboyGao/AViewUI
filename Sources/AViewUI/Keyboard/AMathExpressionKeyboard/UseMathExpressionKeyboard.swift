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
            let context = makeKeyboardContext(for: uiTextfield)
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
            let context = makeKeyboardContext(for: uiTextfield)
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
            let context = makeKeyboardContext(for: uiTextfield)
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
            let context = makeKeyboardContext(for: uiTextfield)
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
            let context = makeKeyboardContext(for: uiTextfield)
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

@available(iOS 16.0, *)
private func makeKeyboardContext(for textField: UITextField) -> ACustomKeyboardInputContext {
    let text = textField.text ?? ""
    let selectedRange = textField.currentSelectedRange ?? NSRange(location: text.count, length: 0)
    return ACustomKeyboardInputContext(
        text: text,
        selectedRange: selectedRange,
        isFocused: textField.isFirstResponder,
        insertText: { textField.insertText($0) },
        deleteBackward: { textField.deleteBackward() },
        replaceSelection: { input in
            guard let selected = textField.selectedTextRange else {
                textField.insertText(input)
                return
            }
            textField.replace(selected, withText: input)
        },
        moveCursor: { offset in
            let base = textField.currentSelectedRange ?? selectedRange
            let textCount = textField.text?.count ?? 0
            let newLocation = max(0, min(textCount, base.location + offset))
            textField.setSelectedRange(NSRange(location: newLocation, length: 0))
        },
        setSelection: { range in
            let textCount = textField.text?.count ?? 0
            let clamped = range.clamped(to: textCount)
            textField.setSelectedRange(clamped)
        },
        setText: { newText in
            textField.text = newText
        },
        clear: {
            textField.text = ""
        },
        selectAll: {
            let textCount = textField.text?.count ?? 0
            textField.setSelectedRange(NSRange(location: 0, length: textCount))
        },
        dismissKeyboard: {
            textField.resignFirstResponder()
        }
    )
}
