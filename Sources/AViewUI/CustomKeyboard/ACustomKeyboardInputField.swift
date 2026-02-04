import SwiftUI
import UIKit

#if os(iOS)

/// 可自定义键盘界面的文本输入框。
/// 使用 `keyboard` 构建键盘界面，并通过 `ACustomKeyboardInputContext` 操作输入。
@available(iOS 14.0, *)
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

@available(iOS 14.0, *)
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

@available(iOS 14.0, *)
#Preview {
    List {
        ACustomKeyboardInputFieldPreview()
    }
}

#endif
