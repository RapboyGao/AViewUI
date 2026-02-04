import SwiftUI

#if os(iOS)

@available(iOS 16, *)
public struct AIntKeyboard: View {
    private var textfield: UITextField

    private let lettersFont: Font = .system(size: 10)
    private let numbersFont: Font = .system(size: 23)
    private let connerRadius: CGFloat = 4

    @State private var turnDirection: Angle = .zero
    private var setString: (String) -> Void

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
            ANumKeyVStack(number, letters: lettersFont, number: numbersFont)
                .bold()
        }
    }

    public var body: some View {
        AKeyboardBackgroundView { screenWidth in
            KeyBoardSpaceAroundStack(columns: 3, rowSpace: 5, columnSpace: 5) {
                ForEach(1..<4, content: makeNumberButton)

                ForEach(4..<7, content: makeNumberButton)

                ForEach(7..<10, content: makeNumberButton)

                AKeyButton(connerRadius, colors: .functionKeyColors, sound: 1155) {
                    textfield.insertText("-")
                } content: { _ in
                    Text(verbatim: "-")
                        .font(.system(size: 24))
                }

                makeNumberButton(0)

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
            .frame(width: screenWidth)
        }
    }

    public init(_ textfield: UITextField) {
        self.textfield = textfield
        self.setString = { textfield.text = $0 }
    }

    public init(_ textfield: UITextField, _ bindString: Binding<String>) {
        self.textfield = textfield
        self.setString = { bindString.wrappedValue = $0 }
    }
}

@available(iOS 16, *)
#Preview {
    AIntKeyboard(.init())
        .frame(height: 240)
}

#endif
