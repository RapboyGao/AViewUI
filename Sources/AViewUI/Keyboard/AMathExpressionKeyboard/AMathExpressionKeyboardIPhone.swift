import AMathExpression
import Numerics
import SwiftUI

private let functionPart1 = [
    "acos", "atan", "∛", "√",
    "sin", "cos", "tan", "asin",
    "exp", "log", "log10", "abs",
    "ceil", "floor", "round",
]

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
public struct AMathExpressionKeyboardIPhone<ANumber: Codable & Sendable & Real & BinaryFloatingPoint>: View,
    AKeyboardProtocol
{
    public var input: ACustomKeyboardInputContext
    private var formatStyle: AMathFormatStyle<ANumber>
    private let setString: (String) -> Void

    @State private var showFunction = false
    @State private var turnDirection: Angle = .zero
    @Namespace private var namespace

    // 假设 textField 是你的 UITextField 实例
    func insertBrackets() {
        input.replaceSelection("()")
        input.moveCursor(-1)
    }

    @ViewBuilder
    private func transferButton() -> some View {
        imageButton2(systemName: showFunction ? "numbers" : "function") {
            showFunction.toggle()
        }
        .font(.system(size: 25))
        .matchedGeometryEffect(id: "transferButton", in: namespace)
    }

    @ViewBuilder
    private func doneButton() -> some View {
        equalButton {
            let text = input.text
            guard
                let number = try? formatStyle.parseStrategy.parse(text)
            else { return }
            let string = formatStyle.format(number)
            guard text == string
            else {
                setString(string)
                return
            }
            input.dismissKeyboard()
        }
    }

    @ViewBuilder
    private func defaultContent() -> some View {
        makeTextButton("+")
        makeTextButton("-")
        makeTextButton("×")
        makeTextButton2("÷")

        ForEach(1..<4, content: makeNumberButton)
        makeDeleteButton()

        ForEach(4..<7, content: makeNumberButton)
        makeTextButton2("^")

        ForEach(7..<10, content: makeNumberButton)
        clearButton()

        transferButton()

        makeNumberButton(0)
        makeTextButton2(".")
        doneButton()
    }

    @ViewBuilder
    private func functionContent() -> some View {
        ForEach(functionPart1, id: \.self) { functionName in
            AKeyButton(connerRadius) {
                input.insertText(functionName)
                insertBrackets()
                showFunction.toggle()
            } content: { _ in
                Text(functionName)
            }
        }

        AKeyButton(connerRadius) {
            insertBrackets()
        } content: { _ in
            Text("( )")
                .font(numbersFont)
        }

        transferButton()

        imageButton2(systemName: "e.circle") {
            input.insertText("2.7182818284")
            showFunction.toggle()
        }

        imageButton2(systemName: "pi") {
            input.insertText("3.1415926535")
            showFunction.toggle()
        }

        makeDeleteButton()
    }

    public var body: some View {
        AKeyboardBackgroundView { screenWidth in
            KeyBoardSpaceAroundStack(columns: 4, rowSpace: 7, columnSpace: 6) {
                if showFunction {
                    functionContent()
                } else {
                    defaultContent()
                }
            }
            .frame(width: screenWidth)
        }
    }

    public init(
        _ context: ACustomKeyboardInputContext,
        format: FloatingPointFormatStyle<ANumber>,
        setString: @escaping (String) -> Void
    ) {
        self.input = context
        self.formatStyle = AMathFormatStyle(format)
        self.setString = setString
    }

    public init(_ context: ACustomKeyboardInputContext, format: FloatingPointFormatStyle<ANumber>) {
        self.input = context
        self.formatStyle = AMathFormatStyle(format)
        self.setString = { context.setText($0) }
    }

    public init(
        _ context: ACustomKeyboardInputContext,
        _ bindString: Binding<String>,
        format: FloatingPointFormatStyle<ANumber>
    ) {
        self.input = context
        self.formatStyle = AMathFormatStyle(format)
        self.setString = { bindString.wrappedValue = $0 }
    }

    public init(_ context: ACustomKeyboardInputContext, _ format: AMathFormatStyle<ANumber>) {
        self.input = context
        self.formatStyle = format
        self.setString = { context.setText($0) }
    }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, visionOS 1.0, *)
#Preview {
    let context :ACustomKeyboardInputContext = .empty()

    let base = AMathExpressionKeyboardIPhone<Double>(context, format: .number.precision(.fractionLength(5)))
        .frame(height: 280)

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
    AMathExpressionKeyboardIPhone<Double>(context, format: .number.precision(.fractionLength(5)))
    #elseif os(iOS)
    base
    #else
    Text("Preview not available")
    #endif
}
