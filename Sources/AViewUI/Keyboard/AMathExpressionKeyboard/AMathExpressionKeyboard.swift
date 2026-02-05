import AMathExpression
import SwiftUI

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
public struct AMathExpressionKeyboard<ANumber: Codable & Sendable & Real & BinaryFloatingPoint>: View,
    AKeyboardProtocol
{
    public var input: ACustomKeyboardInputContext
    private var formatStyle: AMathFormatStyle<ANumber>
    private let setString: (String) -> Void

    private var isIPad: Bool {
        #if canImport(UIKit) && !os(watchOS)
        switch UIDevice.current.userInterfaceIdiom {
        case .pad, .tv, .vision, .mac:
            return true
        case .unspecified, .phone, .carPlay:
            return false
        @unknown default:
            return false
        }
        #else
        #if os(watchOS)
        return false
        #else
        return true
        #endif
        #endif
    }

    public var body: some View {
        if isIPad {
            AMathExpressionKeyboardIPad(input, format: formatStyle.displayedFormat, setString: setString)
        } else {
            AMathExpressionKeyboardIPhone(input, format: formatStyle.displayedFormat, setString: setString)
        }
    }

    public init(
        _ context: ACustomKeyboardInputContext,
        format: FloatingPointFormatStyle<ANumber>,
        setString: @escaping (String) -> Void
    ) {
        self.input = context
        self.formatStyle = AMathFormatStyle(format)
        self.setString = setString
    }

    public init(_ context: ACustomKeyboardInputContext, format: FloatingPointFormatStyle<ANumber>) {
        self.input = context
        self.formatStyle = AMathFormatStyle(format)
        self.setString = { context.setText($0) }
    }

    public init(
        _ context: ACustomKeyboardInputContext,
        _ bindString: Binding<String>,
        format: FloatingPointFormatStyle<ANumber>
    ) {
        self.input = context
        self.formatStyle = AMathFormatStyle(format)
        self.setString = { bindString.wrappedValue = $0 }
    }

    public init(_ context: ACustomKeyboardInputContext, _ format: AMathFormatStyle<ANumber>) {
        self.input = context
        self.formatStyle = format
        self.setString = { context.setText($0) }
    }
}

#if os(iOS)
@available(iOS 16, *)
#Preview("iOS") {
    let context = ACustomKeyboardInputContext(
        text: "",
        selectedRange: NSRange(location: 0, length: 0),
        isFocused: true,
        insertText: { _ in },
        deleteBackward: {},
        replaceSelection: { _ in },
        moveCursor: { _ in },
        setSelection: { _ in },
        setText: { _ in },
        clear: {},
        selectAll: {},
        dismissKeyboard: {}
    )

    AMathExpressionKeyboard<Double>(context, format: .number.precision(.fractionLength(5)))
        .frame(height: 240)
}
#elseif os(macOS)
@available(macOS 13.0, *)
#Preview("macOS") {
    let context = ACustomKeyboardInputContext(
        text: "",
        selectedRange: NSRange(location: 0, length: 0),
        isFocused: true,
        insertText: { _ in },
        deleteBackward: {},
        replaceSelection: { _ in },
        moveCursor: { _ in },
        setSelection: { _ in },
        setText: { _ in },
        clear: {},
        selectAll: {},
        dismissKeyboard: {}
    )

    AMathExpressionKeyboard<Double>(context, format: .number.precision(.fractionLength(5)))
        .frame(height: 240)
        .frame(width: 360)
        .padding()
}
#elseif os(tvOS)
@available(tvOS 16.0, *)
#Preview("tvOS") {
    let context = ACustomKeyboardInputContext(
        text: "",
        selectedRange: NSRange(location: 0, length: 0),
        isFocused: true,
        insertText: { _ in },
        deleteBackward: {},
        replaceSelection: { _ in },
        moveCursor: { _ in },
        setSelection: { _ in },
        setText: { _ in },
        clear: {},
        selectAll: {},
        dismissKeyboard: {}
    )

    AMathExpressionKeyboard<Double>(context, format: .number.precision(.fractionLength(5)))
        .frame(height: 240)
        .frame(width: 600)
        .padding()
}
#elseif os(watchOS)
@available(watchOS 9.0, *)
#Preview("watchOS") {
    let context = ACustomKeyboardInputContext(
        text: "",
        selectedRange: NSRange(location: 0, length: 0),
        isFocused: true,
        insertText: { _ in },
        deleteBackward: {},
        replaceSelection: { _ in },
        moveCursor: { _ in },
        setSelection: { _ in },
        setText: { _ in },
        clear: {},
        selectAll: {},
        dismissKeyboard: {}
    )

    AMathExpressionKeyboard<Double>(context, format: .number.precision(.fractionLength(5)))
        .frame(height: 180)
}
#elseif os(visionOS)
@available(visionOS 1.0, *)
#Preview("visionOS") {
    let context = ACustomKeyboardInputContext(
        text: "",
        selectedRange: NSRange(location: 0, length: 0),
        isFocused: true,
        insertText: { _ in },
        deleteBackward: {},
        replaceSelection: { _ in },
        moveCursor: { _ in },
        setSelection: { _ in },
        setText: { _ in },
        clear: {},
        selectAll: {},
        dismissKeyboard: {}
    )

    AMathExpressionKeyboard<Double>(context, format: .number.precision(.fractionLength(5)))
        .frame(height: 240)
        .frame(width: 420)
        .padding()
}
#endif
