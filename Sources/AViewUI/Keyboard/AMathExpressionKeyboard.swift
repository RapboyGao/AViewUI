import SwiftUI

private let functionPart1 = [
    "sin", "cos", "tan", "asin",
    "acos", "atan", "cbrt", "sqrt",
    "exp", "log", "log10", "abs",
    "ceil", "floor", "round",
]

@available(iOS 16, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct AMathExpressionKeyboard<SomeFormatStyle: ParseableFormatStyle>: View where SomeFormatStyle.FormatInput == Double, SomeFormatStyle.FormatOutput == String {
    private var uiTextField: UITextField
    private var format: AMathFormatStyle<SomeFormatStyle>
    private let lettersFont: Font = .system(size: 10)
    private let numbersFont: Font = .system(size: 23)
    private let connerRadius: CGFloat = 4

    @State private var showFunction = false
    @Namespace private var namespace

    @ViewBuilder
    private func makeTextButton(_ text: String) -> some View {
        AKeyButton(connerRadius) {
            uiTextField.insertText(text)
        } content: { _ in
            Text(text).font(numbersFont)
        }
    }

    @ViewBuilder
    private func makeTextButton2(_ text: String) -> some View {
        AKeyButton(connerRadius, colors: .sameAsBackground) {
            uiTextField.insertText(text)
        } content: { _ in
            Text(text).font(numbersFont)
        }
    }

    @ViewBuilder
    private func makeNumberButton(_ number: Int) -> some View {
        AKeyButton(connerRadius) {
            uiTextField.insertText(number.formatted(.number))
        } content: { _ in
            ANumKeyVStack(number, letters: lettersFont, number: numbersFont)
        }
    }

    // 假设 textField 是你的 UITextField 实例
    func insertBrackets() {
        guard let selectedRange = uiTextField.selectedTextRange else {
            return
        }
        // 在当前光标位置插入括号
        uiTextField.replace(selectedRange, withText: "()")

        // 设置光标到括号中间
        if let newPosition = uiTextField.position(from: selectedRange.start, offset: 1) {
            uiTextField.selectedTextRange = uiTextField.textRange(from: newPosition, to: newPosition)
        }
    }

    @ViewBuilder
    private func transferButton() -> some View {
        AKeyButton(connerRadius, colors: .sameAsBackground) {
            showFunction.toggle()
        } content: { isClicked in
            if showFunction {
                Text("123")
                    .font(numbersFont)
            } else {
                Image(systemName: "function")
                    .font(numbersFont)
                    .bold(isClicked)
            }
        }
        .matchedGeometryEffect(id: "transferButton", in: namespace)
    }

    @ViewBuilder
    private func deleteButton() -> some View {
        AKeyButton(connerRadius, colors: .sameAsBackground, sound: 1155) {
            uiTextField.deleteBackward()
        } content: { isPressed in
            Image(systemName: isPressed ? "delete.left.fill" : "delete.left")
                .font(.system(size: 24))
                .fontWeight(.light)
        }
    }

    @ViewBuilder
    private func deleteButton2() -> some View {
        AKeyButton(connerRadius, sound: 1155) {
            uiTextField.deleteBackward()
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
            guard let text = uiTextField.text,
                  let number = try? format.parseStrategy.parse(text)
            else { return }
            let string = format.format(number)
            guard string != "0"
            else {
                let string = number.formatted(.number.grouping(.never).precision(.significantDigits(0 ... 10)))
                return
            }
            uiTextField.text = string
        } content: { isClicked in
            Text("=")
                .font(numbersFont)
                .foregroundColor(isClicked ? .primary : .white)
        }
    }

    @ViewBuilder
    private func defaultContent() -> some View {
        makeTextButton("÷")

        AKeyButton(connerRadius) {
            insertBrackets()
        } content: { _ in
            Text("( )")
                .font(numbersFont)
        }

        makeTextButton("^")

        deleteButton2()

        makeTextButton("+")
        ForEach(1 ..< 4, content: makeNumberButton)

        makeTextButton("-")
        ForEach(4 ..< 7, content: makeNumberButton)

        makeTextButton("×")
        ForEach(7 ..< 10, content: makeNumberButton)

        AKeyButton(connerRadius, colors: .sameAsBackground) {
            showFunction.toggle()
        } content: { isClicked in
            Image(systemName: "function")
                .font(numbersFont)
                .bold(isClicked)
        }
        .matchedGeometryEffect(id: "transferButton", in: namespace)

        makeTextButton2(".")
        makeNumberButton(0)
        doneButton()
    }

    @ViewBuilder
    private func functionContent() -> some View {
        ForEach(functionPart1, id: \.self) { functionName in
            AKeyButton(connerRadius) {
                uiTextField.insertText(functionName)
                insertBrackets()
                showFunction.toggle()
            } content: { _ in
                Text(functionName)
            }
        }

        AKeyButton(connerRadius, colors: .sameAsBackground) {
            uiTextField.insertText(",")
        } content: { isPressed in
            Text(",")
                .font(numbersFont)
                .bold(isPressed)
        }

        transferButton()

        AKeyButton(connerRadius, colors: .sameAsBackground) {
            uiTextField.insertText("2.7182818284")
        } content: { isPressed in
            Text("e")
                .font(numbersFont)
                .bold(isPressed)
        }

        AKeyButton(connerRadius, colors: .sameAsBackground) {
            uiTextField.insertText("3.1415926535")
        } content: { isPressed in
            Text("π")
                .font(numbersFont)
                .bold(isPressed)
        }

        deleteButton()
    }

    public var body: some View {
        AKeyboardBackgroundView { screenWidth in
            KeyBoardSpaceAroundStack(columns: 4, rowSpace: 5, columnSpace: 5) {
                if showFunction {
                    functionContent()
                } else {
                    defaultContent()
                }
            }
            .frame(width: screenWidth)
        }
    }

    public init(_ textfield: UITextField, format: SomeFormatStyle) {
        self.uiTextField = textfield
        self.format = AMathFormatStyle(format)
    }
}

@available(iOS 16, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension AMathExpressionKeyboard where SomeFormatStyle == FloatingPointFormatStyle<Double> {
    init(textField: UITextField) {
        self.uiTextField = textField
        self.format = AMathFormatStyle(.number.grouping(.never).precision(.fractionLength(0 ... 10)))
    }
}

@available(iOS 16, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
#Preview {
    AMathExpressionKeyboard(.init(), format: .number)
        .frame(height: 240)
}
