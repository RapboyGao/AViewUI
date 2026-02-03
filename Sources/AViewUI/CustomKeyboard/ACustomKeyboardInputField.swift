import SwiftUI
import UIKit

#if os(iOS)

/// 可自定义键盘界面的文本输入框。
/// 使用 `keyboard` 构建键盘界面，并通过 `ACustomKeyboardInputContext` 操作输入。
@available(iOS 14.0, *)
public struct ACustomKeyboardInputField<Keyboard: View>: UIViewRepresentable {
    @Binding private var text: String
    private var placeholder: String
    private var keyboard: (ACustomKeyboardInputContext) -> Keyboard
    private var configure: (ACustomKeyboardTextField) -> Void
    private var focused: Binding<Bool>?

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

    public func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, focused: focused, keyboard: keyboard)
    }

    public func makeUIView(context: Context) -> ACustomKeyboardTextField {
        let textField = ACustomKeyboardTextField(frame: .zero)
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.onTextChange = { [weak coordinator = context.coordinator] newText, textField in
            coordinator?.handleTextChange(newText, textField: textField)
        }
        context.coordinator.startObservingForeground()
        configure(textField)
        context.coordinator.attach(textField)
        context.coordinator.updateKeyboard()
        return textField
    }

    public func updateUIView(_ uiView: ACustomKeyboardTextField, context: Context) {
        context.coordinator.updateTextIfNeeded(uiView, externalText: text)
        uiView.placeholder = placeholder
        configure(uiView)
        context.coordinator.keyboard = keyboard
        context.coordinator.focused = focused
        context.coordinator.syncFocus(with: uiView)
        context.coordinator.updateKeyboard()
    }

    public final class Coordinator: NSObject, UITextFieldDelegate {
        private var text: Binding<String>
        fileprivate var focused: Binding<Bool>?
        fileprivate var keyboard: (ACustomKeyboardInputContext) -> Keyboard
        private weak var textField: ACustomKeyboardTextField?
        private var hostingController: UIHostingController<Keyboard>?
        private var selectedRange: NSRange = .init(location: 0, length: 0)
        private var isFocused: Bool = false
        private var lastExternalText: String = ""
        private var foregroundObserver: NSObjectProtocol?
        private var didBecomeActiveObserver: NSObjectProtocol?

        init(
            text: Binding<String>,
            focused: Binding<Bool>?,
            keyboard: @escaping (ACustomKeyboardInputContext) -> Keyboard
        ) {
            self.text = text
            self.focused = focused
            self.keyboard = keyboard
        }

        func attach(_ textField: ACustomKeyboardTextField) {
            self.textField = textField
            lastExternalText = text.wrappedValue
            selectedRange = textField.currentSelectedRange ?? NSRange(location: 0, length: 0)
        }

        func handleTextChange(_ newText: String, textField: UITextField) {
            text.wrappedValue = newText
            lastExternalText = newText
            selectedRange = textField.currentSelectedRange ?? NSRange(location: newText.count, length: 0)
            updateKeyboard()
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            isFocused = true
            focused?.wrappedValue = true
            selectedRange = textField.currentSelectedRange ?? NSRange(location: 0, length: 0)
            updateKeyboard()
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            isFocused = false
            focused?.wrappedValue = false
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

        func startObservingForeground() {
            guard foregroundObserver == nil else { return }
            foregroundObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateKeyboard()
            }
            didBecomeActiveObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.restoreKeyboardIfNeeded()
            }
        }

        deinit {
            if let foregroundObserver {
                NotificationCenter.default.removeObserver(foregroundObserver)
            }
            if let didBecomeActiveObserver {
                NotificationCenter.default.removeObserver(didBecomeActiveObserver)
            }
        }

        private func restoreKeyboardIfNeeded() {
            guard let textField else { return }
            if textField.isFirstResponder || focused?.wrappedValue == true {
                updateKeyboard()
                if focused?.wrappedValue == true, !textField.isFirstResponder {
                    textField.becomeFirstResponder()
                }
            }
        }

        func syncFocus(with textField: UITextField) {
            guard let focused else { return }
            if focused.wrappedValue, !textField.isFirstResponder {
                textField.becomeFirstResponder()
            } else if !focused.wrappedValue, textField.isFirstResponder {
                textField.resignFirstResponder()
            }
        }

        func updateTextIfNeeded(_ textField: UITextField, externalText: String) {
            if isFocused {
                if externalText != lastExternalText {
                    textField.text = externalText
                    lastExternalText = externalText
                }
            } else {
                textField.text = externalText
                lastExternalText = externalText
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
                    let textCount = textField.text?.count ?? 0
                    let newLocation = max(0, min(textCount, base.location + offset))
                    let newRange = NSRange(location: newLocation, length: 0)
                    textField.setSelectedRange(newRange)
                    self.selectedRange = newRange
                    self.updateKeyboard()
                },
                setSelection: { [weak self, weak textField] range in
                    guard let self, let textField else { return }
                    let textCount = textField.text?.count ?? 0
                    let clamped = range.clamped(to: textCount)
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
                    let textCount = textField.text?.count ?? 0
                    let range = NSRange(location: 0, length: textCount)
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
