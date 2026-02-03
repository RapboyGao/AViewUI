import AMathExpression
import SwiftUI

#if os(iOS)
/// 自定义格式化可选文本字段组件
/// Custom formatted optional text field component
@available(iOS 15, *)
public struct ACustomFormattedOptionalTextField<Value: Equatable & Sendable, Format: ParseableFormatStyle, KeyboardView: View>:
    UIViewRepresentable
where Format.FormatInput == Value, Format.FormatOutput == String {
    /// 绑定的可选值 / Bound optional value
    @Binding var value: Value?

    /// 文本选择起始索引 / Text selection start index
    @Binding var startIndex: String.Index

    /// 文本选择结束索引 / Text selection end index
    @Binding var endIndex: String.Index

    /// 焦点状态 / Focus state
    @Binding var focused: Bool

    /// 文本对齐方式 / Text alignment
    private var isRightAligned: Bool?

    /// 文本框创建函数 / Text field creation function
    var makeTextfield: () -> ACustomKeyboardTextField

    /// 格式化样式 / Format style
    var formatStyle: Format

    /// 键盘视图构建器 / Keyboard view builder
    var keyboardViewBuilder: (UITextField) -> KeyboardView

    public init(
        value: Binding<Value?>,
        startIndex: Binding<String.Index>,
        endIndex: Binding<String.Index>,
        focused: Binding<Bool>,
        isRightAligned: Bool? = nil,
        formatStyle: Format,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView,
        makeTextfield: @escaping () -> ACustomKeyboardTextField = { ACustomKeyboardTextField() }
    ) {
        self._value = value
        self._startIndex = startIndex
        self._endIndex = endIndex
        self._focused = focused
        self.isRightAligned = isRightAligned
        self.formatStyle = formatStyle
        self.keyboardViewBuilder = keyboardViewBuilder
        self.makeTextfield = makeTextfield
    }

    public init(
        value: Binding<Value?>,
        formatStyle: Format,
        isRightAligned: Bool? = nil,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView
    ) {
        self._value = value

        let initialText = value.wrappedValue.map { formatStyle.format($0) } ?? ""
        var startIndex = initialText.startIndex
        var endIndex = initialText.endIndex
        var focused = false

        self._startIndex = Binding {
            startIndex
        } set: {
            startIndex = $0
        }

        self._endIndex = Binding {
            endIndex
        } set: {
            endIndex = $0
        }

        self._focused = Binding {
            focused
        } set: {
            focused = $0
        }

        self.isRightAligned = isRightAligned
        self.formatStyle = formatStyle
        self.keyboardViewBuilder = keyboardViewBuilder
        self.makeTextfield = { ACustomKeyboardTextField() }
    }

    public init(
        value: Binding<Value?>,
        editingStatus: Binding<ACustomKeyboardEditingStatus>,
        formatStyle: Format,
        isRightAligned: Bool? = nil,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView,
        makeTextfield: @escaping () -> ACustomKeyboardTextField = { ACustomKeyboardTextField() }
    ) {
        self._value = value

        self._startIndex = Binding {
            editingStatus.wrappedValue.startIndex
        } set: {
            editingStatus.startIndex.wrappedValue = $0
        }

        self._endIndex = Binding {
            editingStatus.wrappedValue.endIndex
        } set: {
            editingStatus.endIndex.wrappedValue = $0
        }

        self._focused = Binding {
            editingStatus.wrappedValue.focused
        } set: {
            editingStatus.focused.wrappedValue = $0
        }

        editingStatus.wrappedValue.text = value.wrappedValue.map { formatStyle.format($0) } ?? ""

        self.isRightAligned = isRightAligned
        self.formatStyle = formatStyle
        self.keyboardViewBuilder = keyboardViewBuilder
        self.makeTextfield = makeTextfield
    }

    public func makeUIView(context: Context) -> UITextField {
        let textField = makeTextfield()
        textField.delegate = context.coordinator
        textField.onTextChange = { [weak coordinator = context.coordinator] newText, field in
            coordinator?.handleTextChange(newText, in: field)
        }

        if let isRightAligned = isRightAligned {
            textField.textAlignment = isRightAligned ? .right : .left
        }

        textField.text = value.map { formatStyle.format($0) } ?? ""
        context.coordinator.recordText(textField.text)

        let keyboardView = buildKeyboardView(textField: textField)
        let hostingController = UIHostingController(rootView: keyboardView)
        hostingController.view.frame = CGRect(origin: .zero, size: hostingController.view.intrinsicContentSize)
        context.coordinator.keyboardHostingController = hostingController
        textField.inputView = hostingController.view

        context.coordinator.textField = textField

        if focused {
            textField.becomeFirstResponder()
        }

        return textField
    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        let formattedText = value.map { formatStyle.format($0) } ?? ""

        if let isRightAligned = isRightAligned {
            uiView.textAlignment = isRightAligned ? .right : .left
        }

        if !focused {
            if uiView.text != formattedText {
                uiView.text = formattedText
                context.coordinator.recordText(uiView.text)
            }
        } else if uiView.text == nil {
            uiView.text = formattedText
            context.coordinator.recordText(uiView.text)
        }

        if focused != uiView.isFirstResponder {
            if focused {
                uiView.becomeFirstResponder()
            } else {
                context.coordinator.allowsEndEditing = true
                uiView.resignFirstResponder()
            }
        }

        if let hostingController = context.coordinator.keyboardHostingController {
            hostingController.rootView = buildKeyboardView(textField: uiView)
            hostingController.view.frame = CGRect(origin: .zero, size: hostingController.view.intrinsicContentSize)
            if uiView.inputView !== hostingController.view {
                uiView.inputView = hostingController.view
            }
        }
    }

    private func updateSelectionIndices(from textField: UITextField) {
        let selectedRange = textField.selectedTextRange ?? textField.textRange(
            from: textField.beginningOfDocument,
            to: textField.beginningOfDocument
        )!

        let startOffset = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
        let endOffset = textField.offset(from: textField.beginningOfDocument, to: selectedRange.end)

        let currentText = textField.text ?? ""
        startIndex = currentText.index(currentText.startIndex, offsetBy: min(startOffset, currentText.count))
        endIndex = currentText.index(currentText.startIndex, offsetBy: min(endOffset, currentText.count))
    }

    private func buildKeyboardView(textField: UITextField) -> KeyboardWrapperView<KeyboardView> {
        updateSelectionIndices(from: textField)
        return KeyboardWrapperView<KeyboardView>(
            value: $value,
            textField: textField,
            startIndex: $startIndex,
            endIndex: $endIndex,
            focused: $focused,
            formatStyle: formatStyle,
            builder: keyboardViewBuilder
        )
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        public var parent: ACustomFormattedOptionalTextField
        weak var textField: UITextField?
        fileprivate var keyboardHostingController: UIHostingController<KeyboardWrapperView<KeyboardView>>?
        private var lastKnownText: String = ""
        fileprivate var allowsEndEditing: Bool = false

        public init(parent: ACustomFormattedOptionalTextField) {
            self.parent = parent
            super.init()
        }

        public func recordText(_ text: String?) {
            lastKnownText = text ?? ""
        }

        public func handleTextChange(_ newText: String, in textField: UITextField) {
            guard newText != lastKnownText else { return }
            lastKnownText = newText

            if newText.isEmpty {
                if parent.value != nil {
                    parent.value = nil
                }
                return
            }

            if let parsedValue = try? parent.formatStyle.parseStrategy.parse(newText) {
                if parsedValue != parent.value {
                    parent.value = parsedValue
                }
            }
        }

        public func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.updateSelectionIndices(from: textField)
        }

        public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            allowsEndEditing = false
            parent.focused = true
            return true
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            allowsEndEditing = false
        }

        public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            return allowsEndEditing
        }

        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if let currentText = textField.text,
                let parsedValue = try? parent.formatStyle.parseStrategy.parse(currentText) {
                parent.value = parsedValue
            }

            textField.text = parent.value.map { parent.formatStyle.format($0) } ?? ""
            recordText(textField.text)
            allowsEndEditing = true
            textField.resignFirstResponder()
            return true
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            parent.focused = false

            if let currentText = textField.text,
                let parsedValue = try? parent.formatStyle.parseStrategy.parse(currentText) {
                parent.value = parsedValue
            }

            textField.text = parent.value.map { parent.formatStyle.format($0) } ?? ""
            recordText(textField.text)
        }
    }

    fileprivate struct KeyboardWrapperView<BuilderKeyboardView: View>: View {
        @Binding var value: Value?
        let textField: UITextField
        @Binding var startIndex: String.Index
        @Binding var endIndex: String.Index
        @Binding var focused: Bool
        let formatStyle: Format
        let builder: (UITextField) -> BuilderKeyboardView

        var body: some View {
            return builder(textField)
        }
    }
}

@available(iOS 16, *)
private struct ACustomFormattedOptionalTextFieldExample: View {
    @State private var doubleValue: Double? = 123.45
    @State private var startIndex = String.Index(utf16Offset: 0, in: "123.45")
    @State private var endIndex = String.Index(utf16Offset: 6, in: "123.45")
    @State private var focused = false
    @State private var isRightAligned = false

    private var formatStyle = AMathFormatStyle.fractionLength(5)

    var body: some View {
        List {
            ACustomFormattedOptionalTextField(
                value: $doubleValue,
                startIndex: $startIndex,
                endIndex: $endIndex,
                focused: $focused,
                isRightAligned: isRightAligned,
                formatStyle: formatStyle
            ) { uiTextfield in
                AMathExpressionKeyboard(uiTextfield, formatStyle)
            }

            let displayValue = doubleValue?.description ?? "nil"
            Text("输入值: \(displayValue)")
            Toggle("是否靠右对齐", isOn: $isRightAligned)
            Toggle("输入框是否聚焦", isOn: $focused)
            Button("重置为nil") {
                doubleValue = nil
            }
            Button("重置为0.0") {
                doubleValue = 0.0
            }
        }
    }
}

@available(iOS 16, *)
#Preview {
    ACustomFormattedOptionalTextFieldExample()
}
#endif
