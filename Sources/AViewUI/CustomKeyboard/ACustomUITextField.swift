import SwiftUI

#if os(iOS)
/// 自定义文本字段组件
/// Custom text field component
///
/// 一个支持自定义键盘的通用文本输入组件，使用UITextField作为底层实现
/// A generic text input component that supports custom keyboards, using UITextField as the underlying implementation
@available(iOS 14, *)
public struct ACustomUITextField<KeyboardView: View>: UIViewRepresentable {
    /// 绑定的文本 / Bound text
    @Binding var text: String

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

    /// 键盘视图构建器 / Keyboard view builder
    /// - Parameters:
    ///   - textField: 关联的UITextField实例 / Associated UITextField instance
    /// - Returns: 键盘视图 / Keyboard view
    var keyboardViewBuilder: (UITextField) -> KeyboardView

    /// 显式定义初始化函数
    /// Explicit initialization function
    public init(
        text: Binding<String>,
        startIndex: Binding<String.Index>,
        endIndex: Binding<String.Index>,
        focused: Binding<Bool>,
        isRightAligned: Bool? = nil,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView,
        makeTextfield: @escaping () -> ACustomKeyboardTextField = { ACustomKeyboardTextField() }
    ) {
        self._text = text
        self._startIndex = startIndex
        self._endIndex = endIndex
        self._focused = focused
        self.isRightAligned = isRightAligned
        self.keyboardViewBuilder = keyboardViewBuilder
        self.makeTextfield = makeTextfield
    }

    /// 便捷初始化方法，无需手动管理编辑状态
    /// Convenient initialization method, no need to manually manage editing state
    public init(
        text: Binding<String>,
        focused: Binding<Bool>,
        isRightAligned: Bool? = nil,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView
    ) {
        self._text = text

        var startIndex = text.wrappedValue.startIndex
        var endIndex = text.wrappedValue.endIndex

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

        self._focused = focused
        self.isRightAligned = isRightAligned
        self.keyboardViewBuilder = keyboardViewBuilder
        self.makeTextfield = { ACustomKeyboardTextField() }
    }

    /// 最简初始化方法，仅需提供文本绑定
    /// Simplest initialization method, only need to provide text binding
    public init(
        text: Binding<String>,
        isRightAligned: Bool? = nil,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView
    ) {
        self._text = text

        var startIndex = text.wrappedValue.startIndex
        var endIndex = text.wrappedValue.endIndex
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
        self.keyboardViewBuilder = keyboardViewBuilder
        self.makeTextfield = { ACustomKeyboardTextField() }
    }

    /// 初始化函数，接受Binding<ACustomKeyboardEditingStatus>参数
    /// Initialization function accepting Binding<ACustomKeyboardEditingStatus> parameter
    public init(
        editingStatus: Binding<ACustomKeyboardEditingStatus>,
        isRightAligned: Bool? = nil,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView,
        makeTextfield: @escaping () -> ACustomKeyboardTextField = { ACustomKeyboardTextField() }
    ) {
        self._text = Binding {
            editingStatus.wrappedValue.text
        } set: {
            editingStatus.text.wrappedValue = $0
        }
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
        self.isRightAligned = isRightAligned
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

        textField.text = text
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
        if let isRightAligned = isRightAligned {
            uiView.textAlignment = isRightAligned ? .right : .left
        }

        // 当未聚焦时，保持与绑定值同步；聚焦时以TextField为主，避免跳动
        if !focused {
            if uiView.text != text {
                uiView.text = text
                context.coordinator.recordText(uiView.text)
            }
        } else if uiView.text == nil {
            uiView.text = text
            context.coordinator.recordText(uiView.text)
        }

        if focused != uiView.isFirstResponder {
            if focused {
                uiView.becomeFirstResponder()
            } else {
                uiView.resignFirstResponder()
            }
        }

        // 不在更新周期内重建或更新inputView，避免键盘收起
        // Avoid rebuilding/updating inputView during updates to prevent dismissal
    }

    /// 更新选区索引 / Update selection indices
    /// - Parameter textField: 关联的文本框 / Associated text field
    private func updateSelectionIndices(from textField: UITextField) {
        let selectedRange = textField.selectedTextRange ?? textField.textRange(
            from: textField.beginningOfDocument,
            to: textField.beginningOfDocument
        )!

        let startOffset = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
        let endOffset = textField.offset(from: textField.beginningOfDocument, to: selectedRange.end)

        let currentText = textField.text ?? text
        startIndex = currentText.index(currentText.startIndex, offsetBy: min(startOffset, currentText.count))
        endIndex = currentText.index(currentText.startIndex, offsetBy: min(endOffset, currentText.count))
    }

    private func buildKeyboardView(textField: UITextField) -> KeyboardWrapperView<KeyboardView> {
        updateSelectionIndices(from: textField)
        return KeyboardWrapperView(
            text: $text,
            textField: textField,
            startIndex: $startIndex,
            endIndex: $endIndex,
            focused: $focused,
            builder: keyboardViewBuilder
        )
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        public var parent: ACustomUITextField
        weak var textField: UITextField?
        fileprivate var keyboardHostingController: UIHostingController<KeyboardWrapperView<KeyboardView>>?
        private var lastKnownText: String = ""

        public init(parent: ACustomUITextField) {
            self.parent = parent
            super.init()
        }

        public func recordText(_ text: String?) {
            lastKnownText = text ?? ""
        }

        public func handleTextChange(_ newText: String, in textField: UITextField) {
            guard newText != lastKnownText else { return }
            lastKnownText = newText
            if parent.text != newText {
                parent.text = newText
            }
        }

        public func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.updateSelectionIndices(from: textField)
        }

        public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            parent.focused = true
            return true
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            parent.focused = false
        }
    }
}

@available(iOS 14, *)
fileprivate struct KeyboardWrapperView<KeyboardView: View>: View {
    @Binding var text: String
    let textField: UITextField
    @Binding var startIndex: String.Index
    @Binding var endIndex: String.Index
    @Binding var focused: Bool
    let builder: (UITextField) -> KeyboardView

    var body: some View {
        return builder(textField)
    }
}

@available(iOS 14, *)
private struct Example: View {
    @State private var editingStatus1 = ACustomKeyboardEditingStatus("123+15")
    @State private var editingStatus2 = ACustomKeyboardEditingStatus("456-78")
    @State private var isRightAligned = false

    var body: some View {
        List {
            ACustomUITextField(
                editingStatus: $editingStatus1
            ) { uiTextfield in
                if #available(iOS 16, *) {
                    AMathExpressionKeyboard(uiTextfield, .precision(.fractionLength(0...3)))
                        .frame(height: 270)
                }
            }
            ACustomUITextField(
                editingStatus: $editingStatus2,
                isRightAligned: isRightAligned
            ) { uiTextfield in
                if #available(iOS 16, *) {
                    AMathExpressionKeyboard(uiTextfield, .precision(.fractionLength(0...3)))
                        .frame(height: 270)
                }
            }
            Text("第一个输入框已选文字: " + editingStatus1.selectedString)
            Text("第二个输入框已选文字: " + editingStatus2.selectedString)
            Toggle("第一个输入框是否聚焦", isOn: $editingStatus1.focused)
            Toggle("第二个输入框是否聚焦", isOn: $editingStatus2.focused)
            Toggle("是否靠右对齐", isOn: $isRightAligned)
            Button("删除") {
                editingStatus1.backDelete()
            }
            Button("键入123") {
                editingStatus1.insertOrReplace("123")
            }
        }
    }
}

@available(iOS 14, *)
#Preview {
    Example()
}

#endif
