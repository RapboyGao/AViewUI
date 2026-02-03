import SwiftUI
import UIKit

#if os(iOS)

/// 输入法键盘构建函数可用的上下文。
/// - 负责暴露常用输入接口：插入、删除、选区替换、移动光标、收起键盘等。
@available(iOS 14.0, *)
public struct ACustomKeyboardInputContext {
    /// 当前文本
    public let text: String
    /// 当前选区（location 为起始，length 为长度）
    public let selectedRange: NSRange
    /// 是否处于聚焦（第一响应者）状态
    public let isFocused: Bool

    /// 当前选中的文本（若无选区则为空）
    public var selectedText: Substring {
        let start = text.safeIndex(offset: selectedRange.location)
        let end = text.safeIndex(offset: selectedRange.location + selectedRange.length)
        return text[min(start, end)..<max(start, end)]
    }

    /// 插入文本（等价于系统键盘输入）
    public let insertText: (String) -> Void
    /// 删除光标前字符（退格）
    public let deleteBackward: () -> Void
    /// 替换当前选区
    public let replaceSelection: (String) -> Void
    /// 按偏移移动光标（负数向左，正数向右）
    public let moveCursor: (Int) -> Void
    /// 直接设置选区
    public let setSelection: (NSRange) -> Void
    /// 直接设置文本（可用于清空、全量替换）
    public let setText: (String) -> Void
    /// 清空文本
    public let clear: () -> Void
    /// 全选
    public let selectAll: () -> Void
    /// 收起键盘
    public let dismissKeyboard: () -> Void
}

/// 可自定义键盘界面的文本输入框。
/// 使用 `keyboard` 构建键盘界面，并通过 `ACustomKeyboardInputContext` 操作输入。
@available(iOS 14.0, *)
public struct ACustomKeyboardInputField<Keyboard: View>: UIViewRepresentable {
    @Binding private var text: String
    private var placeholder: String
    private var keyboard: (ACustomKeyboardInputContext) -> Keyboard
    private var configure: (ACustomKeyboardTextField) -> Void

    /// - Parameters:
    ///   - placeholder: 占位文字
    ///   - text: 文本绑定
    ///   - configure: 额外配置 `UITextField`（注意：不要覆盖 delegate）
    ///   - keyboard: 自定义键盘构建函数
    public init(
        _ placeholder: String = "",
        text: Binding<String>,
        configure: @escaping (ACustomKeyboardTextField) -> Void = { _ in },
        @ViewBuilder keyboard: @escaping (ACustomKeyboardInputContext) -> Keyboard
    ) {
        self.placeholder = placeholder
        self._text = text
        self.configure = configure
        self.keyboard = keyboard
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, keyboard: keyboard)
    }

    public func makeUIView(context: Context) -> ACustomKeyboardTextField {
        let textField = ACustomKeyboardTextField(frame: .zero)
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.onTextChange = { [weak coordinator = context.coordinator] newText, textField in
            coordinator?.handleTextChange(newText, textField: textField)
        }
        configure(textField)
        context.coordinator.attach(textField)
        context.coordinator.updateKeyboard()
        return textField
    }

    public func updateUIView(_ uiView: ACustomKeyboardTextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.placeholder = placeholder
        configure(uiView)
        context.coordinator.keyboard = keyboard
        context.coordinator.updateKeyboard()
    }

    public final class Coordinator: NSObject, UITextFieldDelegate {
        private var text: Binding<String>
        fileprivate var keyboard: (ACustomKeyboardInputContext) -> Keyboard
        private weak var textField: ACustomKeyboardTextField?
        private var hostingController: UIHostingController<Keyboard>?
        private var selectedRange: NSRange = .init(location: 0, length: 0)
        private var isFocused: Bool = false

        init(text: Binding<String>, keyboard: @escaping (ACustomKeyboardInputContext) -> Keyboard) {
            self.text = text
            self.keyboard = keyboard
        }

        func attach(_ textField: ACustomKeyboardTextField) {
            self.textField = textField
            selectedRange = textField.currentSelectedRange ?? NSRange(location: 0, length: 0)
        }

        func handleTextChange(_ newText: String, textField: UITextField) {
            text.wrappedValue = newText
            selectedRange = textField.currentSelectedRange ?? NSRange(location: newText.count, length: 0)
            updateKeyboard()
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            isFocused = true
            selectedRange = textField.currentSelectedRange ?? NSRange(location: 0, length: 0)
            updateKeyboard()
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            isFocused = false
            selectedRange = textField.currentSelectedRange ?? NSRange(location: 0, length: 0)
            updateKeyboard()
        }

        public func textFieldDidChangeSelection(_ textField: UITextField) {
            selectedRange = textField.currentSelectedRange ?? selectedRange
            updateKeyboard()
        }

        func updateKeyboard() {
            guard let textField else { return }
            let context = makeContext(with: textField)

            if let hostingController {
                hostingController.rootView = keyboard(context)
            } else {
                let hosting = UIHostingController(rootView: keyboard(context))
                hosting.view.backgroundColor = .clear
                hostingController = hosting
            }

            if let view = hostingController?.view {
                view.frame = CGRect(origin: .zero, size: view.intrinsicContentSize)
                textField.inputView = view
                textField.reloadInputViews()
            }
        }

        private func makeContext(with textField: UITextField) -> ACustomKeyboardInputContext {
            let currentText = textField.text ?? text.wrappedValue
            let currentRange = textField.currentSelectedRange ?? selectedRange
            return ACustomKeyboardInputContext(
                text: currentText,
                selectedRange: currentRange,
                isFocused: isFocused,
                insertText: { [weak textField] input in
                    textField?.insertText(input)
                },
                deleteBackward: { [weak textField] in
                    textField?.deleteBackward()
                },
                replaceSelection: { [weak self, weak textField] input in
                    guard let textField, let selected = textField.selectedTextRange else {
                        textField?.insertText(input)
                        return
                    }
                    textField.replace(selected, withText: input)
                    self?.selectedRange = textField.currentSelectedRange ?? currentRange
                    self?.updateKeyboard()
                },
                moveCursor: { [weak self, weak textField] offset in
                    guard let self, let textField else { return }
                    let base = textField.currentSelectedRange ?? currentRange
                    let newLocation = max(0, min(currentText.count, base.location + offset))
                    let newRange = NSRange(location: newLocation, length: 0)
                    textField.setSelectedRange(newRange)
                    self.selectedRange = newRange
                    self.updateKeyboard()
                },
                setSelection: { [weak self, weak textField] range in
                    guard let self, let textField else { return }
                    let clamped = range.clamped(to: currentText.count)
                    textField.setSelectedRange(clamped)
                    self.selectedRange = clamped
                    self.updateKeyboard()
                },
                setText: { [weak self, weak textField] newText in
                    guard let self, let textField else { return }
                    textField.text = newText
                    self.text.wrappedValue = newText
                    let end = NSRange(location: newText.count, length: 0)
                    textField.setSelectedRange(end)
                    self.selectedRange = end
                    self.updateKeyboard()
                },
                clear: { [weak self, weak textField] in
                    guard let self, let textField else { return }
                    textField.text = ""
                    self.text.wrappedValue = ""
                    let zero = NSRange(location: 0, length: 0)
                    textField.setSelectedRange(zero)
                    self.selectedRange = zero
                    self.updateKeyboard()
                },
                selectAll: { [weak self, weak textField] in
                    guard let self, let textField else { return }
                    let range = NSRange(location: 0, length: currentText.count)
                    textField.setSelectedRange(range)
                    self.selectedRange = range
                    self.updateKeyboard()
                },
                dismissKeyboard: { [weak textField] in
                    textField?.resignFirstResponder()
                }
            )
        }
    }
}

@available(iOS 14.0, *)
private extension UITextField {
    var currentSelectedRange: NSRange? {
        guard let selectedTextRange else { return nil }
        let location = offset(from: beginningOfDocument, to: selectedTextRange.start)
        let length = offset(from: selectedTextRange.start, to: selectedTextRange.end)
        return NSRange(location: location, length: length)
    }

    func setSelectedRange(_ range: NSRange) {
        guard let start = position(from: beginningOfDocument, offset: range.location),
            let end = position(from: start, offset: range.length),
            let textRange = textRange(from: start, to: end)
        else { return }
        selectedTextRange = textRange
    }
}

@available(iOS 14.0, *)
private extension NSRange {
    func clamped(to textCount: Int) -> NSRange {
        let safeLocation = max(0, min(location, textCount))
        let safeLength = max(0, min(length, textCount - safeLocation))
        return NSRange(location: safeLocation, length: safeLength)
    }
}

@available(iOS 14.0, *)
private extension String {
    func safeIndex(offset: Int) -> String.Index {
        let safeOffset = max(0, min(offset, count))
        return index(startIndex, offsetBy: safeOffset, limitedBy: endIndex) ?? endIndex
    }
}

@available(iOS 14.0, *)
#Preview {
    struct ExampleKeyboard: View {
        @Binding var text: String

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
            .padding()
        }
    }

    return ExampleKeyboard(text: .constant(""))
}

#endif
