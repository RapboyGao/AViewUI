import SwiftUI

@available(iOS 16, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
struct ANumericKeyboard: View {
    var textfield: UITextField

    private let lettersFont: Font = .system(size: 10)
    private let numbersFont: Font = .system(size: 23)
    private let connerRadius: CGFloat = 4

    @State private var turnDirection: Angle = .zero
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
    private func makeNumberButton(_ number: Int) -> some View {
        AKeyButton(connerRadius) {
            textfield.insertText(number.formatted(.number))
        } content: { _ in
            ANumKeyVStack(number)
        }
    }

    var body: some View {
        AKeyboardBackgroundView { screenWidth in
            KeyBoardSpaceAroundStack(columns: 4, rowSpace: 5, columnSpace: 5) {
                makeTextButton("+")
                ForEach(1 ..< 4, content: makeNumberButton)

                makeTextButton("-")
                ForEach(4 ..< 7, content: makeNumberButton)

                makeTextButton("e")
                ForEach(7 ..< 10, content: makeNumberButton)

                AKeyButton(connerRadius, colors: .sameAsBackground, sound: 1155) {
                    textfield.text = ""
                    withAnimation {
                        turnDirection -= .degrees(360)
                    }
                } content: { _ in
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 24))
                        .rotationEffect(turnDirection)
                }

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
        self.turnDirection = turnDirection
    }
}

@available(iOS 16, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
#Preview {
    ANumericKeyboard(.init())
        .frame(height: 240)
}
