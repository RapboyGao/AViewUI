import SwiftUI

#if canImport(UIKit) && !os(watchOS)
import UIKit

/// 可自定义键盘界面的文本输入框。
/// 使用 `keyboard` 构建键盘界面，并通过 `ACustomKeyboardInputContext` 操作输入。
@available(iOS 14.0, tvOS 14.0, *)
public struct ACustomKeyboardInputField<Keyboard: View>: ACustomKeyboardFieldProtocol {
    @Binding private var text: String
    public var placeholder: String
    private var keyboard: (ACustomKeyboardInputContext) -> Keyboard
    public var configure: (ACustomKeyboardTextField) -> Void
    public var focused: Binding<Bool>?

    /// - Parameters:
    ///   - placeholder: 占位文字
    ///   - text: 文本绑定
    ///   - configure: 额外配置 `UITextField`（注意：不要覆盖 delegate）
    ///   - keyboard: 自定义键盘构建函数
    public init(
        _ placeholder: String = "",
        text: Binding<String>,
        focused: Binding<Bool>? = nil,
        configure: @escaping (ACustomKeyboardTextField) -> Void = { _ in },
        @ViewBuilder keyboard: @escaping (ACustomKeyboardInputContext) -> Keyboard
    ) {
        self.placeholder = placeholder
        self._text = text
        self.focused = focused
        self.configure = configure
        self.keyboard = keyboard
    }

    public func makeKeyboard(context: ACustomKeyboardInputContext) -> Keyboard {
        keyboard(context)
    }

    public func externalText() -> String {
        text
    }

    public func setExternalTextFromInput(_ text: String) {
        _text.wrappedValue = text
    }

    public var suppressNextFocusedUpdate: Bool {
        false
    }
}

@available(iOS 14.0, tvOS 14.0, *)
private struct ACustomKeyboardInputFieldPreview: View {
    @State private var text: String = ""

    var body: some View {
        ACustomKeyboardInputField("输入", text: $text) { context in
            VStack(spacing: 12) {
                Text("\"\(context.text)\"")
                HStack(spacing: 12) {
                    Button("1") { context.insertText("1") }
                    Button("2") { context.insertText("2") }
                    Button("3") { context.insertText("3") }
                }
                HStack(spacing: 12) {
                    Button("退格") { context.deleteBackward() }
                    Button("清空") { context.clear() }
                    Button("完成") { context.dismissKeyboard() }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
        }
    }
}

#if os(iOS)
@available(iOS 16.0, *)
#Preview("iOS") {
    List {
        ACustomKeyboardInputFieldPreview()
    }
}
#elseif os(macOS)
@available(macOS 13.0, *)
#Preview("macOS") {
    VStack(spacing: 12) {
        ACustomKeyboardInputField("输入", text: .constant("123")) { context in
            VStack {
                Text(context.text)
                HStack {
                    Button("1") { context.insertText("1") }
                    Button("2") { context.insertText("2") }
                    Button("清空") { context.clear() }
                }
            }
            .padding(8)
        }
    }
    .padding()
    .frame(width: 360)
}
#elseif os(tvOS)
@available(tvOS 16.0, *)
#Preview("tvOS") {
    VStack(spacing: 12) {
        ACustomKeyboardInputField("输入", text: .constant("123")) { context in
            VStack {
                Text(context.text)
                HStack {
                    Button("1") { context.insertText("1") }
                    Button("2") { context.insertText("2") }
                    Button("清空") { context.clear() }
                }
            }
            .padding(8)
        }
    }
    .padding()
    .frame(width: 600)
}
#elseif os(watchOS)
@available(watchOS 9.0, *)
#Preview("watchOS") {
    VStack(spacing: 8) {
        ACustomKeyboardInputField("输入", text: .constant("1")) { context in
            VStack {
                Text(context.text)
                HStack {
                    Button("1") { context.insertText("1") }
                    Button("⌫") { context.deleteBackward() }
                }
            }
            .padding(4)
        }
    }
    .padding(6)
}
#elseif os(visionOS)
@available(visionOS 1.0, *)
#Preview("visionOS") {
    VStack(spacing: 12) {
        ACustomKeyboardInputField("输入", text: .constant("123")) { context in
            VStack {
                Text(context.text)
                HStack {
                    Button("1") { context.insertText("1") }
                    Button("2") { context.insertText("2") }
                    Button("清空") { context.clear() }
                }
            }
            .padding(8)
        }
    }
    .padding()
    .frame(width: 420)
}
#endif

#else

/// 可自定义键盘界面的文本输入框（非 UIKit 版本）。
/// 输入框仅显示文本，编辑行为由自定义键盘驱动。
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public struct ACustomKeyboardInputField<Keyboard: View>: View {
    @Binding private var text: String
    public var placeholder: String
    private var keyboard: (ACustomKeyboardInputContext) -> Keyboard
    public var configure: (ACustomKeyboardTextField) -> Void
    public var focused: Binding<Bool>?

    public init(
        _ placeholder: String = "",
        text: Binding<String>,
        focused: Binding<Bool>? = nil,
        configure: @escaping (ACustomKeyboardTextField) -> Void = { _ in },
        @ViewBuilder keyboard: @escaping (ACustomKeyboardInputContext) -> Keyboard
    ) {
        self.placeholder = placeholder
        self._text = text
        self.focused = focused
        self.configure = configure
        self.keyboard = keyboard
    }

    public var body: some View {
        ACustomKeyboardInlineFieldHost(
            placeholder: placeholder,
            externalText: text,
            setExternalTextFromInput: { newText in
                _text.wrappedValue = newText
            },
            suppressNextFocusedUpdate: false,
            focused: focused,
            configure: configure,
            keyboard: { context in
                keyboard(context)
            }
        )
    }
}

#endif
