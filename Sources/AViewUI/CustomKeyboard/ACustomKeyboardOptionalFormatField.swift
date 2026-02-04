import SwiftUI
import UIKit

#if os(iOS)

/// 使用自定义键盘的可选值格式化输入框（UIViewRepresentable 版本）。
/// - 适用于任何支持 ParseableFormatStyle 的 Optional value + format。
@available(iOS 15.0, *)
public struct ACustomKeyboardOptionalFormatField<Format: ParseableFormatStyle, Input, Keyboard: View>:
    ACustomKeyboardFieldProtocol
where Format.FormatInput == Input, Format.FormatOutput == String {
    public var placeholder: String
    @Binding private var value: Input?
    private var format: Format
    public var configure: (ACustomKeyboardTextField) -> Void
    private var keyboard: (ACustomKeyboardInputContext, Input?) -> Keyboard
    public var focused: Binding<Bool>?

    /// - Parameters:
    ///   - placeholder: 占位文字
    ///   - value: 绑定值（可选）
    ///   - format: 格式化与解析
    ///   - focused: 双向焦点绑定
    ///   - configure: 额外配置 `UITextField`（注意：不要覆盖 delegate）
    ///   - keyboard: 自定义键盘构建函数
    public init(
        _ placeholder: String = "",
        value: Binding<Input?>,
        format: Format,
        focused: Binding<Bool>? = nil,
        configure: @escaping (ACustomKeyboardTextField) -> Void = { _ in },
        @ViewBuilder keyboard: @escaping (ACustomKeyboardInputContext, Input?) -> Keyboard
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
        value.map(format.format) ?? ""
    }

    public func setExternalTextFromInput(_ text: String) {
        if text.isEmpty {
            _value.wrappedValue = nil
        } else {
            _value.wrappedValue = try? format.parseStrategy.parse(text)
        }
    }

    public var suppressNextFocusedUpdate: Bool {
        true
    }
}

@available(iOS 16, *)
private struct ACustomKeyboardOptionalFormatFieldPreview: View {
    @State private var value: Double? = 0

    var body: some View {
        ACustomKeyboardOptionalFormatField("表达式", value: $value, format: .number) { context, _ in
            AMathExpressionKeyboard<Double>(context, format: .number)
        }
    }
}

@available(iOS 16, *)
#Preview {
    List {
        ACustomKeyboardOptionalFormatFieldPreview()
    }
}

#endif
