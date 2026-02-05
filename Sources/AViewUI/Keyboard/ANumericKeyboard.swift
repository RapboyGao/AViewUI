import SwiftUI

#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
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

    #if os(iOS)
    ANumericKeyboard(context)
        .frame(height: 240)
    #elseif os(macOS)
    ANumericKeyboard(context)
        .frame(height: 240)
        .frame(width: 360)
        .padding()
    #elseif os(tvOS)
    ANumericKeyboard(context)
        .frame(height: 240)
        .frame(width: 600)
        .padding()
    #elseif os(watchOS)
    ANumericKeyboard(context)
        .frame(height: 180)
    #elseif os(visionOS)
    ANumericKeyboard(context)
        .frame(height: 240)
        .frame(width: 420)
        .padding()
    #else
    Text("Preview not available")
    #endif
}
