import SwiftUI

private let functionPart1 = [
    "sin(", "cos(", "tan(", "asin(",
    "acos(", "atan(", "atan2(", "sqrt(",
    "exp(", "log(", "log10(", "abs(",
    "average(", "ceil(", "floor(", "round(",
]

@available(iOS 16, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct AMathExpressionKeyboard: View {
    private var textfield: UITextField
    private let lettersFont: Font = .system(size: 10)
    private let numbersFont: Font = .system(size: 23)
    private let connerRadius: CGFloat = 4

    @State private var showFunction = false
    @Namespace private var namespace

    @ViewBuilder
    private func makeTextButton(_ text: String) -> some View {
        AKeyButton(connerRadius) {
            textfield.insertText(text)
        } content: { _ in
            Text(text).font(numbersFont)
                .bold()
        }
    }

    @ViewBuilder
    private func makeTextButton2(_ text: String) -> some View {
        AKeyButton(connerRadius, colors: .sameAsBackground) {
            textfield.insertText(text)
        } content: { _ in
            Text(text).font(numbersFont)
                .bold()
        }
    }

    @ViewBuilder
    private func makeTextButton3(_ text: String) -> some View {
        AKeyButton(connerRadius) {
            textfield.insertText(text)
        } content: { _ in
            Text(text)
        }
    }

    @ViewBuilder
    private func makeNumberButton(_ number: Int) -> some View {
        AKeyButton(connerRadius) {
            textfield.insertText(number.formatted(.number))
        } content: { _ in
            ANumKeyVStack(number, letters: lettersFont, number: numbersFont)
                .bold()
        }
    }

    @ViewBuilder
    private func defaultContent() -> some View {
        ForEach(["÷", "(", ")", "^"], id: \.self) { sign in
            makeTextButton(sign)
        }

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

        AKeyButton(connerRadius, colors: .sameAsBackground) {
            textfield.insertText(".")
        } content: { isPressed in
            Text(".")
                .font(numbersFont)
                .bold(isPressed)
        }

        makeNumberButton(0)

        AKeyButton(connerRadius, colors: .sameAsBackground, sound: 1155) {
            textfield.deleteBackward()
        } content: { isPressed in
            Image(systemName: isPressed ? "delete.left.fill" : "delete.left")
                .font(.system(size: 24))
                .fontWeight(.light)
        }
    }

    @ViewBuilder
    private func functionContent() -> some View {
        ForEach(functionPart1, id: \.self) { sign in
            makeTextButton3(sign)
        }

        AKeyButton(connerRadius, colors: .sameAsBackground) {
            showFunction.toggle()
        } content: { _ in
            Text("123")
                .font(numbersFont)
        }
        .matchedGeometryEffect(id: "transferButton", in: namespace)

        AKeyButton(connerRadius, colors: .sameAsBackground) {
            textfield.insertText(",")
        } content: { isPressed in
            Text(",")
                .font(numbersFont)
                .bold(isPressed)
        }

        AKeyButton(connerRadius, colors: .sameAsBackground) {
            textfield.insertText("2.7182818284")
        } content: { isPressed in
            Text("e")
                .font(numbersFont)
                .bold(isPressed)
        }

        AKeyButton(connerRadius, colors: .sameAsBackground) {
            textfield.text = "3.1415926535"
        } content: { isPressed in
            Text("π")
                .font(numbersFont)
                .bold(isPressed)
        }
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

    public init(_ textfield: UITextField) {
        self.textfield = textfield
    }
}

@available(iOS 16, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
#Preview {
    AMathExpressionKeyboard(.init())
        .frame(height: 240)
}
