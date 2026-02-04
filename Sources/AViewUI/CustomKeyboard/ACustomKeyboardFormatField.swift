import SwiftUI
import UIKit

#if os(iOS)

/// 使用自定义键盘的格式化输入框（UIViewRepresentable 版本）。
/// - 适用于任何支持 ParseableFormatStyle 的 value + format。
@available(iOS 15.0, *)
public struct ACustomKeyboardFormatField<Format: ParseableFormatStyle, Input, Keyboard: View>: ACustomKeyboardFieldProtocol
where Format.FormatInput == Input, Format.FormatOutput == String {
    public var placeholder: String
    @Binding private var value: Input
    private var format: Format
    public var configure: (ACustomKeyboardTextField) -> Void
    private var keyboard: (ACustomKeyboardInputContext, Input) -> Keyboard
    public var focused: Binding<Bool>?

    /// - Parameters:
    ///   - placeholder: 占位文字
    ///   - value: 绑定值
    ///   - format: 格式化与解析
    ///   - configure: 额外配置 `UITextField`（注意：不要覆盖 delegate）
    ///   - keyboard: 自定义键盘构建函数
    public init(
        _ placeholder: String = "",
        value: Binding<Input>,
        format: Format,
        focused: Binding<Bool>? = nil,
        configure: @escaping (ACustomKeyboardTextField) -> Void = { _ in },
        @ViewBuilder keyboard: @escaping (ACustomKeyboardInputContext, Input) -> Keyboard
    ) {
        self.placeholder = placeholder
        self._value = value
        self.format = format
        self.focused = focused
        self.configure = configure
        self.keyboard = keyboard
    }

    public func makeKeyboard(context: ACustomKeyboardInputContext) -> Keyboard {
        keyboard(context, value)
    }

    public func externalText() -> String {
        format.format(value)
    }

    public func setExternalTextFromInput(_ text: String) {
        if let newValue = try? format.parseStrategy.parse(text) {
            _value.wrappedValue = newValue
        }
    }

    public var suppressNextFocusedUpdate: Bool {
        true
    }
}

@available(iOS 16, *)
private struct ACustomKeyboardFormatFieldPreview: View {
    @State private var value: Double = 0

    private var format: AMathFormatStyle<Double> = .fractionLength(3)

    var body: some View {
        ACustomKeyboardFormatField("表达式", value: $value, format: .number) { context, _ in
            AMathExpressionKeyboard<Double>(context, format: .number)
        }
    }
}

@available(iOS 16, *)
#Preview {
    List {
        ACustomKeyboardFormatFieldPreview()
    }
}

#endif
