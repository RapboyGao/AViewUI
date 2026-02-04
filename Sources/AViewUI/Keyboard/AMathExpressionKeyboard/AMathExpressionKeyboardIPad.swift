import AMathExpression
import Numerics
import SwiftUI

#if os(iOS)
@available(iOS 16, *)
public struct AMathExpressionKeyboardIPad<ANumber: Codable & Sendable & Real & BinaryFloatingPoint>: View,
    AKeyboardProtocol
{
    public var input: ACustomKeyboardInputContext
    private var formatStyle: AMathFormatStyle<ANumber>
    private let setString: (String) -> Void

    @State private var turnDirection: Angle = .zero

    @ViewBuilder
    private func makeFuncButton(name functionName: String) -> some View {
        AKeyButton(connerRadius) {
            input.insertText(functionName)
            insertBrackets()
        } content: { _ in
            Text(functionName)
        }
    }

    // 假设 textField 是你的 UITextField 实例
    func insertBrackets() {
        input.replaceSelection("()")
        input.moveCursor(-1)
    }

    @ViewBuilder
    private func doneButton() -> some View {
        AKeyButton(cornerRadius: connerRadius) { isClicked, colorScheme in
            if isClicked {
                return AKeyColors.defaultColors.getColor(isClicked, colorScheme)
            } else {
                return .blue
            }
        } action: {
            let text = input.text
            guard
                let number = try? formatStyle.parseStrategy.parse(text)
            else { return }
            let string = formatStyle.format(number)
            guard text == string
            else {
                setString(string)
                return
            }
            input.dismissKeyboard()
        } content: { isClicked in
            Text("=")
                .font(numbersFont)
                .foregroundColor(isClicked ? .primary : .white)
        }
    }

    @ViewBuilder
    private func clearButton() -> some View {
        AKeyButton(connerRadius, colors: .functionKeyColors, sound: 1155) {
            setString("")

            withAnimation {
                turnDirection -= .degrees(360)
            }
        } content: { _ in
            Image(systemName: "arrow.counterclockwise")
                .font(.system(size: 24))
                .rotationEffect(turnDirection)
        }
    }

    @ViewBuilder
    private func bracketsButton() -> some View {
        AKeyButton(connerRadius, colors: .functionKeyColors) {
            insertBrackets()
        } content: { _ in
            Text("( )")
                .font(numbersFont)
        }
    }

    @ViewBuilder
    func line1Content() -> some View {
        makeFuncButton(name: "sin")
        makeFuncButton(name: "cos")
        makeFuncButton(name: "tan")
        makeFuncButton(name: "ln")
        ForEach(1..<4, content: makeNumberButton)
        makeDeleteButton()
        makeTextButton2("÷")

    }

    @ViewBuilder
    func line2Content() -> some View {
        makeFuncButton(name: "asin")
        makeFuncButton(name: "acos")
        makeFuncButton(name: "atan2")
        makeFuncButton(name: "log")
        ForEach(4..<7, content: makeNumberButton)
        makeTextButton2("×")
        makeTextButton2("-")

    }

    @ViewBuilder
    func line3Content() -> some View {
        makeFuncButton(name: "√")
        makeFuncButton(name: "∛")
        AKeyButton(connerRadius) {
            input.insertText("2.7182818284")
        } content: { isPressed in
            Text("e")
                .font(numbersFont)
                .bold(isPressed)
        }
        AKeyButton(connerRadius) {
            input.insertText("3.1415926535")
        } content: { isPressed in
            Text("π")
                .font(numbersFont)
                .bold(isPressed)
        }
        ForEach(7..<10, content: makeNumberButton)
        makeTextButton2("+")
        makeTextButton2("^")

    }

    @ViewBuilder
    func line4Content() -> some View {
        makeFuncButton(name: "ceil")
        makeFuncButton(name: "floor")
        makeFuncButton(name: "round")
        makeFuncButton(name: "abs")
        makeTextButton(".")
        makeTextButton("0")
        bracketsButton()
        clearButton()
        doneButton()
    }

    public var body: some View {
        AKeyboardBackgroundView { screenWidth in
            KeyBoardSpaceAroundStack(columns: 9, rowSpace: 6, columnSpace: 6) {
                line1Content()
                line2Content()
                line3Content()
                line4Content()
            }
            .frame(width: screenWidth)
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
        deleteBackward: {},
        replaceSelection: { _ in },
        moveCursor: { _ in },
        setSelection: { _ in },
        setText: { _ in },
        clear: {},
        selectAll: {},
        dismissKeyboard: {}
    )

    AMathExpressionKeyboardIPad<Double>(context, format: .number.precision(.fractionLength(5)))
        .frame(height: 240)
}

#endif
