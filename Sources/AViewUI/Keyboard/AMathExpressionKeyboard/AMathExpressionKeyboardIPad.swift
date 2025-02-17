import AMathExpression
import Numerics
import SwiftUI

#if os(iOS)
@available(iOS 16, *)
public struct AMathExpressionKeyboardIPad<ANumber: Codable & Sendable & Real & BinaryFloatingPoint>: View {
    private var uiTextField: UITextField
    private var formatStyle: AMathFormatStyle<ANumber>
    private let lettersFont: Font = .system(size: 10)
    private let numbersFont: Font = .system(size: 23)
    private let connerRadius: CGFloat = 4
    private let setString: (String) -> Void

    @State private var turnDirection: Angle = .zero


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

    @ViewBuilder
    private func makeFuncButton(name functionName: String) -> some View {
        AKeyButton(connerRadius) {
            uiTextField.insertText(functionName)
            insertBrackets()
        } content: { _ in
            Text(functionName)
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
                let number = try? formatStyle.parseStrategy.parse(text)
            else { return }
            let string = formatStyle.format(number)
            guard uiTextField.text == string
            else {
                setString(string)
                return
            }
            uiTextField.resignFirstResponder()
        } content: { isClicked in
            Text("=")
                .font(numbersFont)
                .foregroundColor(isClicked ? .primary : .white)
        }
    }

    @ViewBuilder
    private func clearButton() -> some View {
        AKeyButton(connerRadius, colors: .sameAsBackground, sound: 1155) {
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
        AKeyButton(connerRadius, colors: .sameAsBackground) {
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
            uiTextField.insertText("2.7182818284")
        } content: { isPressed in
            Text("e")
                .font(numbersFont)
                .bold(isPressed)
        }

        AKeyButton(connerRadius) {
            uiTextField.insertText("3.1415926535")
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

    public init(_ textfield: UITextField, format: FloatingPointFormatStyle<ANumber>, setString: @escaping (String) -> Void) {
        self.uiTextField = textfield
        self.formatStyle = AMathFormatStyle(format)
        self.setString = setString
    }

    public init(_ textfield: UITextField, format: FloatingPointFormatStyle<ANumber>) {
        self.uiTextField = textfield
        self.formatStyle = AMathFormatStyle(format)
        self.setString = { textfield.text = $0 }
    }

    public init(_ textfield: UITextField, _ bindString: Binding<String>, format: FloatingPointFormatStyle<ANumber>) {
        self.uiTextField = textfield
        self.formatStyle = AMathFormatStyle(format)
        self.setString = { bindString.wrappedValue = $0 }
    }

    public init(_ textfield: UITextField, _ format: AMathFormatStyle<ANumber>) {
        self.uiTextField = textfield
        self.formatStyle = format
        self.setString = { textfield.text = $0 }
    }
}

@available(iOS 16, *)#Preview{
    AMathExpressionKeyboardIPad<Double>(.init(), .fractionLength(5))
        .frame(height: 240)
}

#endif
