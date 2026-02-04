import SwiftUI

#if os(iOS)

@available(iOS 16, *)
public struct ANumericKeyboard: View, AKeyboardProtocol {
    public var input: ACustomKeyboardInputContext

    @State private var turnDirection: Angle = .zero

    public var body: some View {
        AKeyboardBackgroundView { screenWidth in
            KeyBoardSpaceAroundStack(columns: 4, rowSpace: 6, columnSpace: 6) {
                makeTextButton("+")
                ForEach(1..<4, content: makeNumberButton)

                makeTextButton("-")
                ForEach(4..<7, content: makeNumberButton)

                makeTextButton("e")
                ForEach(7..<10, content: makeNumberButton)

                AKeyButton(connerRadius, colors: .functionKeyColors, sound: 1155) {
                    input.clear()
                    withAnimation {
                        turnDirection -= .degrees(360)
                    }
                } content: { _ in
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 24))
                        .rotationEffect(turnDirection)
                }

                AKeyButton(connerRadius) {
                    input.insertText(".")
                } content: { isPressed in
                    Text(".")
                        .font(numbersFont)
                        .bold(isPressed)
                }

                makeNumberButton(0)

                makeDeleteButton()
            }
            .frame(width: screenWidth)
        }
    }

    public init(_ context: ACustomKeyboardInputContext) {
        self.input = context
    }

    public init(_ textfield: UITextField) {
        self.input = .make(textField: textfield)
    }

    public init(_ textfield: UITextField, _ bindString: Binding<String>) {
        self.input = .make(textField: textfield, bindString: bindString)
    }
}

@available(iOS 16, *)
#Preview {
    ANumericKeyboard(.init())
        .frame(height: 240)
}

#endif
