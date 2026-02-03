import SwiftUI
import UIKit

#if os(iOS)

/// 使用自定义键盘的格式化输入框（UIViewRepresentable 版本）。
/// - 适用于任何支持 ParseableFormatStyle 的 value + format。
@available(iOS 15.0, *)
public struct ACustomKeyboardFormatField<Format: ParseableFormatStyle, Input, Keyboard: View>: UIViewRepresentable
where Format.FormatInput == Input, Format.FormatOutput == String {
    private var placeholder: String
    @Binding private var value: Input
    private var format: Format
    private var configure: (ACustomKeyboardTextField) -> Void
    private var keyboard: (ACustomKeyboardInputContext, Input) -> Keyboard
    private var focused: Binding<Bool>?
    private var dismissOnBackground: Bool

    /// - Parameters:
    ///   - placeholder: 占位文字
    ///   - value: 绑定值
    ///   - format: 格式化与解析
    ///   - focused: 双向焦点绑定
    ///   - dismissOnBackground: App 进入后台时是否自动收起键盘，避免恢复时系统 inputView 被清空导致显示系统键盘
    ///   - configure: 额外配置 `UITextField`（注意：不要覆盖 delegate）
    ///   - keyboard: 自定义键盘构建函数
    public init(
        _ placeholder: String = "",
        value: Binding<Input>,
        format: Format,
        focused: Binding<Bool>? = nil,
        dismissOnBackground: Bool = true,
        configure: @escaping (ACustomKeyboardTextField) -> Void = { _ in },
        @ViewBuilder keyboard: @escaping (ACustomKeyboardInputContext, Input) -> Keyboard
    ) {
        self.placeholder = placeholder
        self._value = value
        self.format = format
        self.focused = focused
        self.dismissOnBackground = dismissOnBackground
        self.configure = configure
        self.keyboard = keyboard
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            value: $value,
            format: format,
            focused: focused,
            keyboard: keyboard,
            dismissOnBackground: dismissOnBackground
        )
    }

    public func makeUIView(context: Context) -> ACustomKeyboardTextField {
        let textField = ACustomKeyboardTextField(frame: .zero)
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.layer.cornerRadius = 0
        textField.layer.borderWidth = 0
        // 禁用系统输入辅助条/输入栏，避免在自定义键盘上方出现额外圆角条
        context.coordinator.disableSystemAccessory(for: textField)
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
        let formatted = format.format(value)
        context.coordinator.updateTextIfNeeded(uiView, externalText: formatted)
        uiView.placeholder = placeholder
        context.coordinator.disableSystemAccessory(for: uiView)
        configure(uiView)
        context.coordinator.keyboard = keyboard
        context.coordinator.format = format
        context.coordinator.focused = focused
        context.coordinator.dismissOnBackground = dismissOnBackground
        context.coordinator.syncFocus(with: uiView)
        context.coordinator.updateKeyboard()
    }

    public final class Coordinator: NSObject, UITextFieldDelegate {
        private var value: Binding<Input>
        fileprivate var format: Format
        fileprivate var keyboard: (ACustomKeyboardInputContext, Input) -> Keyboard
        fileprivate var focused: Binding<Bool>?
        private weak var textField: ACustomKeyboardTextField?
        private var hostingController: UIHostingController<Keyboard>?
        private var selectedRange: NSRange = .init(location: 0, length: 0)
        private var isFocused: Bool = false
        private var lastExternalText: String = ""
        private var didUpdateValueFromInput: Bool = false
        private var foregroundObserver: NSObjectProtocol?
        private var didBecomeActiveObserver: NSObjectProtocol?
        private var didEnterBackgroundObserver: NSObjectProtocol?
        fileprivate var dismissOnBackground: Bool
        private var inputViewContainer: UIView?

        init(
            value: Binding<Input>,
            format: Format,
            focused: Binding<Bool>?,
            keyboard: @escaping (ACustomKeyboardInputContext, Input) -> Keyboard,
            dismissOnBackground: Bool
        ) {
            self.value = value
            self.format = format
            self.focused = focused
            self.keyboard = keyboard
            self.dismissOnBackground = dismissOnBackground
        }

        func attach(_ textField: ACustomKeyboardTextField) {
            self.textField = textField
            let text = format.format(value.wrappedValue)
            textField.text = text
            lastExternalText = text
            selectedRange = textField.currentSelectedRange ?? NSRange(location: text.count, length: 0)
        }

        func handleTextChange(_ newText: String, textField: UITextField) {
            if let newValue = try? format.parseStrategy.parse(newText) {
                didUpdateValueFromInput = true
                value.wrappedValue = newValue
            }
            selectedRange = textField.currentSelectedRange ?? NSRange(location: newText.count, length: 0)
            updateKeyboard()
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            isFocused = true
            focused?.wrappedValue = true
            selectedRange = textField.currentSelectedRange ?? NSRange(location: 0, length: 0)
            disableSystemAccessory(for: textField)
            updateKeyboard()
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            isFocused = false
            focused?.wrappedValue = false
            didUpdateValueFromInput = false
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
                hostingController.rootView = keyboard(context, value.wrappedValue)
            } else {
                let hosting = UIHostingController(rootView: keyboard(context, value.wrappedValue))
                hosting.view.backgroundColor = .clear
                hostingController = hosting
            }

            if let view = hostingController?.view {
                let container = ensureInputViewContainer(for: view)
                resizeInputViewContainer(container, hostingView: view)
                textField.inputView = container
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
            didEnterBackgroundObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.didEnterBackgroundNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                if self.dismissOnBackground {
                    self.textField?.resignFirstResponder()
                }
            }
        }

        deinit {
            if let foregroundObserver {
                NotificationCenter.default.removeObserver(foregroundObserver)
            }
            if let didBecomeActiveObserver {
                NotificationCenter.default.removeObserver(didBecomeActiveObserver)
            }
            if let didEnterBackgroundObserver {
                NotificationCenter.default.removeObserver(didEnterBackgroundObserver)
            }
        }

        private func restoreKeyboardIfNeeded() {
            guard let textField else { return }
            if textField.isFirstResponder || focused?.wrappedValue == true {
                DispatchQueue.main.async {
                    self.disableSystemAccessory(for: textField)
                    self.updateKeyboard()
                }
                if focused?.wrappedValue == true, !textField.isFirstResponder {
                    textField.becomeFirstResponder()
                }
            }
        }

        func disableSystemAccessory(for textField: UITextField) {
            textField.inputAssistantItem.leadingBarButtonGroups = []
            textField.inputAssistantItem.trailingBarButtonGroups = []
            textField.inputAssistantItem.allowsHidingShortcuts = true
            textField.inputAccessoryView = nil
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
            textField.smartQuotesType = .no
            textField.smartDashesType = .no
            textField.smartInsertDeleteType = .no
            textField.textContentType = .none
        }

        private func ensureInputViewContainer(for hostingView: UIView) -> UIView {
            if let container = inputViewContainer {
                return container
            }
            let container = UIView()
            container.backgroundColor = .clear
            container.layer.cornerRadius = 0
            container.layer.masksToBounds = false
            container.clipsToBounds = false

            hostingView.translatesAutoresizingMaskIntoConstraints = false
            hostingView.backgroundColor = .clear
            container.addSubview(hostingView)
            NSLayoutConstraint.activate([
                hostingView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                hostingView.topAnchor.constraint(equalTo: container.topAnchor),
                hostingView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ])

            inputViewContainer = container
            return container
        }

        private func resizeInputViewContainer(_ container: UIView, hostingView: UIView) {
            let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIView.layoutFittingCompressedSize.height)
            let size = hostingView.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            container.frame = CGRect(origin: .zero, size: CGSize(width: size.width, height: size.height))
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
                if didUpdateValueFromInput {
                    didUpdateValueFromInput = false
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
            let currentText = textField.text ?? format.format(value.wrappedValue)
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
                    if let newValue = try? format.parseStrategy.parse(newText) {
                        didUpdateValueFromInput = true
                        value.wrappedValue = newValue
                    }
                    let end = NSRange(location: newText.count, length: 0)
                    textField.setSelectedRange(end)
                    self.selectedRange = end
                    self.updateKeyboard()
                },
                clear: { [weak self, weak textField] in
                    guard let self, let textField else { return }
                    textField.text = ""
                    didUpdateValueFromInput = true
                    value.wrappedValue = (try? format.parseStrategy.parse("")) ?? value.wrappedValue
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
