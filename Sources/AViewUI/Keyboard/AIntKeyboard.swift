import SwiftUI

#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
public struct AIntKeyboard: View, AKeyboardProtocol {
    public var input: ACustomKeyboardInputContext

    @ViewBuilder
    private func makePlusMinusButton() -> some View {
        AKeyButton(connerRadius, colors: .functionKeyColors) {
            guard var number = Int(input.text)
            else {
                return
            }
            number = -number
            input.setText(number.description)
        } content: { _ in
            Image(systemName: "plus.forwardslash.minus")
                .font(numbersFont)
        }
    }

    public var body: some View {
        AKeyboardBackgroundView { screenWidth in
            KeyBoardSpaceAroundStack(
                rowColumns: [4, 4, 4, 4], rowSpace: 6, columnSpace: 6,
                specifications: []
            ) {
                ForEach(1..<4, content: makeNumberButton)
                makeDeleteButton()

                ForEach(4..<7, content: makeNumberButton)
                makePlusMinusButton()

                ForEach(7..<10, content: makeNumberButton)
                makeTextButton2("00")

                makeTextButton2("-")

                makeNumberButton(0)

                clearButton()

                doneButton()
            }
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
