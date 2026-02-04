import AMathExpression
import Numerics
import SwiftUI

#if os(iOS)
@available(iOS 16, *)
public struct AMathExpressionKeyboardIPad<ANumber: Codable & Sendable & Real & BinaryFloatingPoint>: View {
    private var input: ACustomKeyboardInputContext
    private var formatStyle: AMathFormatStyle<ANumber>
    private let lettersFont: Font = .system(size: 10)
    private let numbersFont: Font = .system(size: 23)
    private let connerRadius: CGFloat = 4
    private let setString: (String) -> Void

    @State private var turnDirection: Angle = .zero

    @ViewBuilder
    private func makeTextButton(_ text: String) -> some View {
        AKeyButton(connerRadius) {
            input.insertText(text)
        } content: { _ in
            Text(text).font(numbersFont)
        }
    }

    @ViewBuilder
    private func makeTextButton2(_ text: String) -> some View {
        AKeyButton(connerRadius, colors: .functionKeyColors) {
            input.insertText(text)
        } content: { _ in
            Text(text).font(numbersFont)
        }
    }

    @ViewBuilder
    private func makeNumberButton(_ number: Int) -> some View {
        AKeyButton(connerRadius) {
            input.insertText(number.formatted(.number))
        } content: { _ in
            ANumKeyVStack(number, letters: lettersFont, number: numbersFont)
        }
    }

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
    private func deleteButton() -> some View {
        AKeyButton(connerRadius, colors: .functionKeyColors, sound: 1155) {
            input.deleteBackward()
        } content: { isPressed in
            Image(systemName: isPressed ? "delete.left.fill" : "delete.left")
                .font(.system(size: 24))
                .fontWeight(.light)
        }
    }

    @ViewBuilder
    private func deleteButton2() -> some View {
        AKeyButton(connerRadius, sound: 1155) {
            input.deleteBackward()
        } content: { isPressed in
            Image(systemName: isPressed ? "delete.left.fill" : "delete.left")
                .font(.system(size: 24))
                .fontWeight(.light)
        }
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
        makeTextButton2("+")
        ForEach(1..<4) { number in
            makeNumberButton(number)
        }
        deleteButton()

    }

    @ViewBuilder
    func line2Content() -> some View {
        makeFuncButton(name: "sin")
        makeFuncButton(name: "cos")
        makeFuncButton(name: "tan")
        makeFuncButton(name: "ln")
        makeTextButton2("-")
        ForEach(4..<7) { number in
            makeNumberButton(number)
        }
        makeTextButton2("^")

    }

    @ViewBuilder
    func line3Content() -> some View {
        makeFuncButton(name: "asin")
        makeFuncButton(name: "acos")
        makeFuncButton(name: "atan2")
        makeFuncButton(name: "log")
        makeTextButton2("×")
        ForEach(7..<10) { number in
            makeNumberButton(number)
        }
        bracketsButton()

    }

    @ViewBuilder
    func line4Content() -> some View {
        makeFuncButton(name: "ceil")
        makeFuncButton(name: "floor")
        makeFuncButton(name: "round")
        makeFuncButton(name: "abs")
        makeTextButton2("÷")
        makeTextButton2(".")
        makeTextButton("0")
        clearButton()
        doneButton()
    }

    public var body: some View {
        AKeyboardBackgroundView { screenWidth in
            KeyBoardSpaceAroundStack(columns: 9, rowSpace: 5, columnSpace: 5) {
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
        deleteBackward: { },
        replaceSelection: { _ in },
        moveCursor: { _ in },
        setSelection: { _ in },
        setText: { _ in },
        clear: { },
        selectAll: { },
        dismissKeyboard: { }
    )

    AMathExpressionKeyboardIPad<Double>(context, format: .number.precision(.fractionLength(5)))
        .frame(height: 240)
}

#endif
