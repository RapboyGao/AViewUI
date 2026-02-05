import SwiftUI

#if canImport(UIKit) && !os(watchOS)
import UIKit

/// 使用自定义键盘的可选值格式化输入框（UIViewRepresentable 版本）。
/// - 适用于任何支持 ParseableFormatStyle 的 Optional value + format。
@available(iOS 15.0, tvOS 15.0, *)
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

@available(iOS 16, tvOS 16, *)
private struct ACustomKeyboardOptionalFormatFieldPreview: View {
    @State private var value: Double? = 0

    var body: some View {
        ACustomKeyboardOptionalFormatField("表达式", value: $value, format: .number) { context, _ in
            AMathExpressionKeyboard<Double>(context, format: .number)
        }
    }
}

#if os(iOS)
@available(iOS 16, *)
#Preview("iOS") {
    List {
        ACustomKeyboardOptionalFormatFieldPreview()
    }
}
#elseif os(macOS)
@available(macOS 13.0, *)
#Preview("macOS") {
    VStack(spacing: 12) {
        ACustomKeyboardOptionalFormatField("表达式", value: .constant(12.3), format: .number) { context, _ in
            AMathExpressionKeyboard<Double>(context, format: .number)
                .frame(height: 240)
        }
    }
    .padding()
    .frame(width: 360)
}
#elseif os(tvOS)
@available(tvOS 16.0, *)
#Preview("tvOS") {
    VStack(spacing: 12) {
        ACustomKeyboardOptionalFormatField("表达式", value: .constant(12.3), format: .number) { context, _ in
            AMathExpressionKeyboard<Double>(context, format: .number)
                .frame(height: 240)
        }
    }
    .padding()
    .frame(width: 600)
}
#elseif os(watchOS)
@available(watchOS 9.0, *)
#Preview("watchOS") {
    VStack(spacing: 8) {
        ACustomKeyboardOptionalFormatField("表达式", value: .constant(12.3), format: .number) { context, _ in
            ANumericKeyboard(context)
                .frame(height: 180)
        }
    }
    .padding(6)
}
#elseif os(visionOS)
@available(visionOS 1.0, *)
#Preview("visionOS") {
    VStack(spacing: 12) {
        ACustomKeyboardOptionalFormatField("表达式", value: .constant(12.3), format: .number) { context, _ in
            AMathExpressionKeyboard<Double>(context, format: .number)
                .frame(height: 240)
        }
    }
    .padding()
    .frame(width: 420)
}
#endif

#else

/// 使用自定义键盘的可选值格式化输入框（非 UIKit 版本）。
/// 输入框仅显示文本，编辑行为由自定义键盘驱动。
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct ACustomKeyboardOptionalFormatField<Format: ParseableFormatStyle, Input, Keyboard: View>: View
where Format.FormatInput == Input, Format.FormatOutput == String {
    public var placeholder: String
    @Binding private var value: Input?
    private var format: Format
    public var configure: (ACustomKeyboardTextField) -> Void
    private var keyboard: (ACustomKeyboardInputContext, Input?) -> Keyboard
    public var focused: Binding<Bool>?

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

    public var body: some View {
        let externalText = value.map(format.format) ?? ""
        return ACustomKeyboardInlineFieldHost(
            placeholder: placeholder,
            externalText: externalText,
            setExternalTextFromInput: { text in
                if text.isEmpty {
                    _value.wrappedValue = nil
                } else {
                    _value.wrappedValue = try? format.parseStrategy.parse(text)
                }
            },
            suppressNextFocusedUpdate: true,
            focused: focused,
            configure: configure,
            keyboard: { context in
                keyboard(context, value)
            }
        )
    }
}

#endif
