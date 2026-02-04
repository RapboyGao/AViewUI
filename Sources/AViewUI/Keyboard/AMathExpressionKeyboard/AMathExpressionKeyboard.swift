import AMathExpression
import SwiftUI

#if os(iOS)
@available(iOS 16, *)
public struct AMathExpressionKeyboard<ANumber: Codable & Sendable & Real & BinaryFloatingPoint>: View,
    AKeyboardProtocol
{
    public var input: ACustomKeyboardInputContext
    private var formatStyle: AMathFormatStyle<ANumber>
    private let setString: (String) -> Void

    private var isIPad: Bool {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return true
        case .unspecified, .phone, .tv, .carPlay, .mac, .vision:
            return false
        @unknown default:
            return false
        }

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

@available(iOS 16, *) #Preview {
    let context = ACustomKeyboardInputContext(
        text: "",
        selectedRange: NSRange(location: 0, length: 0),
        isFocused: true,
        insertText: { _ in },
        deleteBackward: { },
        replaceSelection: { _ in },
        moveCursor: { _ in },
        setSelection: { _ in },
        setText: { _ in },
        clear: { },
        selectAll: { },
        dismissKeyboard: { }
    )

    AMathExpressionKeyboard<Double>(context, format: .number.precision(.fractionLength(5)))
        .frame(height: 240)
}

#endif
