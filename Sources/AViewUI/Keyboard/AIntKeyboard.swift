import SwiftUI

#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
public struct AIntKeyboard: View, AKeyboardProtocol {
    public var input: ACustomKeyboardInputContext

    @State private var turnDirection: Angle = .zero

    @ViewBuilder
    private func makeTextButton(_ text: String) -> some View {
        AKeyButton(connerRadius) {
            input.insertText(text)
        } content: { _ in
            Text(text)
                .font(numbersFont)
                .bold()
        }
    }

    @ViewBuilder
    private func makeNumberButton(_ number: Int) -> some View {
        AKeyButton(connerRadius) {
            input.insertText(number.formatted(.number))
        } content: { _ in
            ANumKeyVStack(number, letters: lettersFont, number: numbersFont)
                .bold()
        }
    }

    public var body: some View {
        AKeyboardBackgroundView { screenWidth in
            KeyBoardSpaceAroundStack(columns: 3, rowSpace: 6, columnSpace: 6) {
                ForEach(1..<4, content: makeNumberButton)
                ForEach(4..<7, content: makeNumberButton)
                ForEach(7..<10, content: makeNumberButton)

                AKeyButton(connerRadius, colors: .functionKeyColors, sound: 1155) {
                    input.insertText("-")
                } content: { _ in
                    Text(verbatim: "-")
                        .font(.system(size: 24))
                }

                makeNumberButton(0)

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
            }
            .frame(width: screenWidth)
        }
    }

    public init(_ context: ACustomKeyboardInputContext) {
        self.input = context
    }

    #if canImport(UIKit) && !os(watchOS)
    public init(_ textfield: UITextField) {
        self.input = .make(textField: textfield)
    }

    public init(_ textfield: UITextField, _ bindString: Binding<String>) {
        self.input = .make(textField: textfield, bindString: bindString)
    }
    #endif
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1.0, *)
#Preview {
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

    let base = AIntKeyboard(context)
        .frame(height: 240)

    #if os(macOS)
    base
        .frame(width: 360)
        .padding()
    #elseif os(tvOS)
    base
        .frame(width: 600)
        .padding()
    #elseif os(visionOS)
    base
        .frame(width: 420)
        .padding()
    #elseif os(watchOS)
    AIntKeyboard(context)
    #elseif os(iOS)
    base
    #else
    Text("Preview not available")
    #endif
}
