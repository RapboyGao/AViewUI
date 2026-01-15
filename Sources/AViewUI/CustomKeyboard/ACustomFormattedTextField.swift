import AMathExpression
import SwiftUI

#if os(iOS)
@available(iOS 15, *)
public struct ACustomFormattedTextField<T: Equatable & Sendable, S: ParseableFormatStyle, KeyboardView: View>:
    UIViewRepresentable
where S.FormatInput == T, S.FormatOutput == String {
    @Binding var value: T
    @Binding var startIndex: String.Index
    @Binding var endIndex: String.Index
    @Binding var focused: Bool
    private var isRightAligned: Bool?

    var makeTextfield: () -> UITextField
    var formatStyle: S

    /// 键盘视图构建器
    var keyboardViewBuilder: (UITextField) -> KeyboardView

    // 显式定义初始化函数 - 直接绑定值
    public init(
        value: Binding<T>,
        startIndex: Binding<String.Index>,
        endIndex: Binding<String.Index>,
        focused: Binding<Bool>,
        formatStyle: S,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView,
        makeTextfield: @escaping () -> UITextField = { UITextField() }
    ) {
        self._value = value
        self._startIndex = startIndex
        self._endIndex = endIndex
        self._focused = focused
        self.formatStyle = formatStyle
        self.keyboardViewBuilder = keyboardViewBuilder
        self.makeTextfield = makeTextfield
    }

    // 新增初始化函数，包含isRightAligned参数 - 直接绑定值
    public init(
        value: Binding<T>,
        startIndex: Binding<String.Index>,
        endIndex: Binding<String.Index>,
        focused: Binding<Bool>,
        isRightAligned: Bool,
        formatStyle: S,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView
    ) {
        self.init(
            value: value,
            startIndex: startIndex,
            endIndex: endIndex,
            focused: focused,
            formatStyle: formatStyle,
            keyboardViewBuilder: keyboardViewBuilder,
            makeTextfield: {
                let textField = UITextField()
                textField.textAlignment = isRightAligned ? .right : .left
                return textField
            }
        )
        self.isRightAligned = isRightAligned
    }

    // 新增初始化函数，接受value和外部ACustomKeyboardEditingStatus
    public init(
        value: Binding<T>,
        editingStatus: Binding<ACustomKeyboardEditingStatus>,
        formatStyle: S,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView,
        makeTextfield: @escaping () -> UITextField = { UITextField() }
    ) {
        self._value = value

        // 使用外部编辑状态的索引和焦点
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

        // 初始化编辑状态的文本
        editingStatus.wrappedValue.text = formatStyle.format(value.wrappedValue)

        self.formatStyle = formatStyle
        self.keyboardViewBuilder = keyboardViewBuilder
        self.makeTextfield = makeTextfield
    }

    // 新增初始化函数，接受value、外部ACustomKeyboardEditingStatus和isRightAligned
    public init(
        value: Binding<T>,
        editingStatus: Binding<ACustomKeyboardEditingStatus>,
        isRightAligned: Bool,
        formatStyle: S,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView
    ) {
        self._value = value

        // 使用外部编辑状态的索引和焦点
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

        // 初始化编辑状态的文本
        editingStatus.wrappedValue.text = formatStyle.format(value.wrappedValue)

        self.formatStyle = formatStyle
        self.keyboardViewBuilder = keyboardViewBuilder
        self.makeTextfield = {
            let textField = UITextField()
            textField.textAlignment = isRightAligned ? .right : .left
            return textField
        }
        self.isRightAligned = isRightAligned
    }

    public func makeUIView(context: Context) -> UITextField {
        let textField = makeTextfield()
        textField.delegate = context.coordinator
        textField.inputView = createKeyboardView(textField: textField)
        context.coordinator.textField = textField

        // 设置初始文本和焦点状态
        textField.text = formatStyle.format(value)
        if focused {
            textField.becomeFirstResponder()
        }

        return textField
    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        // 仅在值实际变化时更新文本
        let formattedText = formatStyle.format(value)
        if uiView.text != formattedText {
            uiView.text = formattedText
        }

        // 更新焦点状态
        if focused != (uiView.isFirstResponder) {
            if focused {
                uiView.becomeFirstResponder()
            } else {
                uiView.resignFirstResponder()
            }
        }

        // 更新文本对齐方式
        if let isRightAligned = isRightAligned {
            uiView.textAlignment = isRightAligned ? .right : .left
        }

        // 强制更新键盘视图
        uiView.inputView = createKeyboardView(textField: uiView)
    }

    // 更新键盘视图方法
    public func updateKeyboardView(_ textField: UITextField) {
        textField.inputView = createKeyboardView(textField: textField)
    }

    // 监听绑定值变化并更新键盘视图
    public func updateBindings() {
        // 使用正确的方式获取当前窗口
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first,
            let textField = window.rootViewController?.view.subviews
                .compactMap({ $0 as? UITextField }).first(where: { $0.delegate is Coordinator })
        {
            updateKeyboardView(textField)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    /// 创建自定义键盘视图
    private func createKeyboardView(textField: UITextField) -> UIView? {
        let selectedRange =
            textField.selectedTextRange ?? textField.textRange(
                from: textField.beginningOfDocument, to: textField.beginningOfDocument
            )!

        let startOffset = textField.offset(
            from: textField.beginningOfDocument, to: selectedRange.start
        )
        let endOffset = textField.offset(
            from: textField.beginningOfDocument, to: selectedRange.end
        )

        let currentText = textField.text ?? ""
        startIndex = currentText.index(currentText.startIndex, offsetBy: min(startOffset, currentText.count))
        endIndex = currentText.index(currentText.startIndex, offsetBy: min(endOffset, currentText.count))

        let keyboardView = KeyboardWrapperView<KeyboardView>(
            value: $value,
            textField: textField,
            startIndex: $startIndex,
            endIndex: $endIndex,
            focused: $focused,
            formatStyle: formatStyle,
            builder: keyboardViewBuilder
        )
        let hostingController = UIHostingController(rootView: keyboardView)

        hostingController.view.frame = CGRect(origin: .zero, size: hostingController.view.intrinsicContentSize)

        return hostingController.view
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        public var parent: ACustomFormattedTextField
        weak var textField: UITextField?

        public init(parent: ACustomFormattedTextField) {
            self.parent = parent
            super.init()
        }

        // 当选择范围变化时更新键盘
        public func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.updateKeyboardView(textField)
        }

        // 处理文本变化
        public func textField(
            _ textField: UITextField, shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            if let currentText = textField.text as NSString? {
                let updatedText = currentText.replacingCharacters(in: range, with: string)

                // 尝试解析更新后的文本
                if let parsedValue = try? parent.formatStyle.parseStrategy.parse(updatedText) {
                    parent.value = parsedValue
                }

                // 更新文本字段的实际文本
                textField.text = updatedText
            }
            return false
        }

        // 文本字段将要开始编辑
        public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            parent.focused = true
            return true
        }

        // 文本字段结束编辑
        public func textFieldDidEndEditing(_ textField: UITextField) {
            parent.focused = false
        }
    }

    // 包装视图，用于监听绑定值变化
    private struct KeyboardWrapperView<BuilderKeyboardView: View>: View {
        @Binding var value: T
        let textField: UITextField
        @Binding var startIndex: String.Index
        @Binding var endIndex: String.Index
        @Binding var focused: Bool
        let formatStyle: S
        let builder: (UITextField) -> BuilderKeyboardView

        var body: some View {
            return builder(textField)
        }
    }
}

// 示例结构体
@available(iOS 15, *)
private struct ACustomFormattedTextFieldExample: View {
    // 使用浮点数类型的示例
    @State private var doubleValue = 123.45
    @State private var startIndex = String.Index(utf16Offset: 0, in: "123.45")
    @State private var endIndex = String.Index(utf16Offset: 6, in: "123.45")
    @State private var focused = false

    // 右对齐选项
    @State private var isRightAligned = false

    // 格式化样式
    private var formatStyle = AMathFormatStyle.fractionLength(5)

    var body: some View {
        List {
            // 浮点数输入示例，使用简单的自定义键盘
            ACustomFormattedTextField(
                value: $doubleValue,
                startIndex: $startIndex,
                endIndex: $endIndex,
                focused: $focused,
                isRightAligned: isRightAligned,
                formatStyle: formatStyle
            ) { uiTextfield in
                // 简单的数字键盘示例
                VStack {
                    HStack {
                        ForEach(1...3, id: \.self) { i in
                            Button("\(i)") {
                                uiTextfield.insertText("\(i)")
                            }
                            .frame(height: 50)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    HStack {
                        Button(".") {
                            uiTextfield.insertText(".")
                        }
                        .frame(height: 50)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)

                        Button("0") {
                            uiTextfield.insertText("0")
                        }
                        .frame(height: 50)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)

                        Button("删除") {
                            uiTextfield.deleteBackward()
                        }
                        .frame(height: 50)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.red)
                    }
                    HStack {
                        Button("完成") {
                            uiTextfield.resignFirstResponder()
                        }
                        .frame(height: 50)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .frame(height: 200)
            }

            // 显示当前值
            Text("输入值: \(doubleValue)")

            // 控制选项
            Toggle("是否靠右对齐", isOn: $isRightAligned)
            Toggle("输入框是否聚焦", isOn: $focused)

            // 手动更新按钮
            Button("重置为0.0") {
                doubleValue = 0.0
            }
        }
    }
}

@available(iOS 15, *)
#Preview {
    ACustomFormattedTextFieldExample()
}
#endif
