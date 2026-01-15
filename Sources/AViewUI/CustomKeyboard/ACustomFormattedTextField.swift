import AMathExpression
import SwiftUI

#if os(iOS)
@available(iOS 15, *)
public struct ACustomFormattedTextField<Value: Equatable & Sendable, Format: ParseableFormatStyle, KeyboardView: View>:
    UIViewRepresentable
where Format.FormatInput == Value, Format.FormatOutput == String {
    @Binding var value: Value
    @Binding var startIndex: String.Index
    @Binding var endIndex: String.Index
    @Binding var focused: Bool
    private var isRightAligned: Bool?

    var makeTextfield: () -> UITextField
    var formatStyle: Format

    /// 键盘视图构建器
    var keyboardViewBuilder: (UITextField) -> KeyboardView

    // 显式定义初始化函数 - 直接绑定值
    public init(
        value: Binding<Value>,
        startIndex: Binding<String.Index>,
        endIndex: Binding<String.Index>,
        focused: Binding<Bool>,
        formatStyle: Format,
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
        value: Binding<Value>,
        startIndex: Binding<String.Index>,
        endIndex: Binding<String.Index>,
        focused: Binding<Bool>,
        isRightAligned: Bool,
        formatStyle: Format,
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
        value: Binding<Value>,
        editingStatus: Binding<ACustomKeyboardEditingStatus>,
        formatStyle: Format,
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
        value: Binding<Value>,
        editingStatus: Binding<ACustomKeyboardEditingStatus>,
        isRightAligned: Bool,
        formatStyle: Format,
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
        // 只有当textfield未聚焦或者值从外部变化且与当前文本解析结果不一致时，才更新文本
        let formattedText = formatStyle.format(value)
        if !focused {
            // 未聚焦时，始终保持与value同步
            uiView.text = formattedText
        } else if uiView.text == nil {
            // 文本为空时初始化
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

    /// 手动触发解析当前文本
    public func parseCurrentText(_ textField: UITextField) {
        if let currentText = textField.text {
            if let parsedValue = try? formatStyle.parseStrategy.parse(currentText) {
                value = parsedValue
            }
        }
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
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            if let currentText = textField.text as NSString? {
                let updatedText = currentText.replacingCharacters(in: range, with: string)
                
                // 更新文本字段
                textField.text = updatedText
                
                // 实时解析文本并更新value，但不影响用户输入
                if let parsedValue = try? parent.formatStyle.parseStrategy.parse(updatedText) {
                    parent.value = parsedValue
                }
            }
            return false
        }

        // 文本字段将要开始编辑
        public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            parent.focused = true
            return true
        }

        // 处理回车键
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // 回车时解析文本并更新value
            if let currentText = textField.text {
                if let parsedValue = try? parent.formatStyle.parseStrategy.parse(currentText) {
                    parent.value = parsedValue
                }
            }
            
            // 更新textfield内容为格式化后的value，确保显示一致
            textField.text = parent.formatStyle.format(parent.value)
            
            return true
        }
        
        // 文本字段结束编辑
        public func textFieldDidEndEditing(_ textField: UITextField) {
            parent.focused = false

            // 失去焦点时解析文本并更新value
            if let currentText = textField.text {
                if let parsedValue = try? parent.formatStyle.parseStrategy.parse(currentText) {
                    parent.value = parsedValue
                }
            }
            
            // 更新textfield内容为格式化后的value，确保显示一致
            textField.text = parent.formatStyle.format(parent.value)
        }
    }

    // 包装视图，用于监听绑定值变化
    private struct KeyboardWrapperView<BuilderKeyboardView: View>: View {
        @Binding var value: Value
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

// 示例结构体
@available(iOS 16, *)
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
            // 浮点数输入示例，使用AMathExpressionKeyboard
            ACustomFormattedTextField(
                value: $doubleValue,
                startIndex: $startIndex,
                endIndex: $endIndex,
                focused: $focused,
                isRightAligned: isRightAligned,
                formatStyle: formatStyle
            ) { uiTextfield in
                // 使用AMathExpressionKeyboard
                AMathExpressionKeyboard(uiTextfield, formatStyle)
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

@available(iOS 16, *)
#Preview {
    ACustomFormattedTextFieldExample()
}
#endif
