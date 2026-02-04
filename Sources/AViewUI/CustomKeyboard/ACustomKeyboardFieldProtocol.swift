import SwiftUI
import UIKit

#if os(iOS)

/// 共享的自定义键盘输入框协议（提取公共行为）。
@available(iOS 14.0, *)
public protocol ACustomKeyboardFieldProtocol: UIViewRepresentable
where UIViewType == ACustomKeyboardTextField {
    associatedtype Keyboard: View
    associatedtype Coordinator = ACustomKeyboardCoordinator<Keyboard>

    var placeholder: String { get }
    var focused: Binding<Bool>? { get }
    var configure: (ACustomKeyboardTextField) -> Void { get }

    /// 键盘构建函数（统一为 context -> Keyboard）
    func makeKeyboard(context: ACustomKeyboardInputContext) -> Keyboard

    /// 当前外部文本（用于更新展示）
    func externalText() -> String

    /// 将输入文本写回外部值
    func setExternalTextFromInput(_ text: String)

    /// 输入中是否需要抑制一次格式化回写（格式化字段需要，普通文本不需要）
    var suppressNextFocusedUpdate: Bool { get }
}

@available(iOS 14.0, *)
public extension ACustomKeyboardFieldProtocol where Coordinator == ACustomKeyboardCoordinator<Keyboard> {
    func makeCoordinator() -> Coordinator {
        ACustomKeyboardCoordinator(
            externalTextProvider: { self.externalText() },
            setExternalTextFromInput: { self.setExternalTextFromInput($0) },
            focused: focused,
            keyboard: { context in self.makeKeyboard(context: context) },
            suppressNextFocusedUpdate: suppressNextFocusedUpdate
        )
    }

    func makeUIView(context: Context) -> ACustomKeyboardTextField {
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

    func updateUIView(_ uiView: ACustomKeyboardTextField, context: Context) {
        context.coordinator.updateTextIfNeeded(uiView, externalText: externalText())
        uiView.placeholder = placeholder
        configure(uiView)
        context.coordinator.keyboard = { context in self.makeKeyboard(context: context) }
        context.coordinator.focused = focused
        context.coordinator.syncFocus(with: uiView)
        context.coordinator.updateKeyboard()
    }
}

/// 共享的 Coordinator，实现输入框与自定义键盘的通用逻辑
@available(iOS 14.0, *)
public final class ACustomKeyboardCoordinator<Keyboard: View>: NSObject, UITextFieldDelegate {
    fileprivate var keyboard: (ACustomKeyboardInputContext) -> Keyboard
    fileprivate var focused: Binding<Bool>?

    private let externalTextProvider: () -> String
    private let setExternalTextFromInput: (String) -> Void
    private let suppressNextFocusedUpdate: Bool

    private weak var textField: ACustomKeyboardTextField?
    private var hostingController: UIHostingController<Keyboard>?
    private var selectedRange: NSRange = .init(location: 0, length: 0)
    private var isFocused: Bool = false
    private var lastExternalText: String = ""
    private var didUpdateFromInput: Bool = false
    private var didEnterBackgroundObserver: NSObjectProtocol?

    init(
        externalTextProvider: @escaping () -> String,
        setExternalTextFromInput: @escaping (String) -> Void,
        focused: Binding<Bool>?,
        keyboard: @escaping (ACustomKeyboardInputContext) -> Keyboard,
        suppressNextFocusedUpdate: Bool
    ) {
        self.externalTextProvider = externalTextProvider
        self.setExternalTextFromInput = setExternalTextFromInput
        self.focused = focused
        self.keyboard = keyboard
        self.suppressNextFocusedUpdate = suppressNextFocusedUpdate
    }

    func attach(_ textField: ACustomKeyboardTextField) {
        self.textField = textField
        let text = externalTextProvider()
        lastExternalText = text
        selectedRange = textField.currentSelectedRange ?? NSRange(location: text.count, length: 0)

        if didEnterBackgroundObserver == nil {
            didEnterBackgroundObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.didEnterBackgroundNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                // 当 App 退到后台时，自动收起键盘
                self?.textField?.resignFirstResponder()
            }
        }
    }

    deinit {
        if let didEnterBackgroundObserver {
            NotificationCenter.default.removeObserver(didEnterBackgroundObserver)
        }
    }

    func handleTextChange(_ newText: String, textField: UITextField) {
        setExternalTextFromInput(newText)
        if suppressNextFocusedUpdate {
            didUpdateFromInput = true
        }
        selectedRange = textField.currentSelectedRange ?? NSRange(location: newText.count, length: 0)
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
        didUpdateFromInput = false
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
//            textField.reloadInputViews()
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
            if suppressNextFocusedUpdate, didUpdateFromInput {
                didUpdateFromInput = false
                return
            }
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
        let currentText = textField.text ?? externalTextProvider()
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
                self.setExternalTextFromInput(newText)
                if self.suppressNextFocusedUpdate {
                    self.didUpdateFromInput = true
                }
                let end = NSRange(location: newText.count, length: 0)
                textField.setSelectedRange(end)
                self.selectedRange = end
                self.updateKeyboard()
            },
            clear: { [weak self, weak textField] in
                guard let self, let textField else { return }
                textField.text = ""
                self.setExternalTextFromInput("")
                if self.suppressNextFocusedUpdate {
                    self.didUpdateFromInput = true
                }
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

#endif
