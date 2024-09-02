import SwiftUI

@available(iOS 16, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct AMathExpressionKeyboard: View {
    private var textfield: UITextField
    private let lettersFont: Font = .system(size: 10)
    private let numbersFont: Font = .system(size: 23)
    private let connerRadius: CGFloat = 4

    private var allFunctionNamesSorted: [String] {
        AMathExpression.mathFunctions.keys.sorted()
    }

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
    private func makeNumberButton(_ number: Int) -> some View {
        AKeyButton(connerRadius) {
            textfield.insertText(number.formatted(.number))
        } content: { _ in
            ANumKeyVStack(number, letters: lettersFont, number: numbersFont)
                .bold()
        }
    }

    public var body: some View {
        AKeyboardBackgroundView { screenWidth in
            KeyBoardSpaceAroundStack(columns: 4, rowSpace: 5, columnSpace: 5) {
                Menu {
                    ForEach(allFunctionNamesSorted, id: \.self) { funcName in
                        Button(funcName) {
                            textfield.insertText(funcName + "(")
                        }
                    }
                } label: {
                    AKeyButton(connerRadius) {
                        textfield.insertText(".")
                    } content: { _ in
                        Image(systemName: "function")
                            .foregroundColor(.primary)
                            .font(numbersFont)
                    }
                }
                ForEach(["(", ")", "^"], id: \.self) { sign in
                    makeTextButton(sign)
                }

                makeTextButton("+")
                ForEach(1 ..< 4, content: makeNumberButton)

                makeTextButton("-")
                ForEach(4 ..< 7, content: makeNumberButton)

                makeTextButton("×")
                ForEach(7 ..< 10, content: makeNumberButton)

                makeTextButton("/")
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
