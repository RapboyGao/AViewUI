import SwiftUI

#if os(iOS)
@available(iOS 14, *)
public struct ACustomKeyboardTextField<KeyboardView: View>: UIViewRepresentable {
    @Binding var text: String
    @Binding var startIndex: String.Index
    @Binding var endIndex: String.Index
    @Binding var focused: Bool

    /// 键盘视图构建器
    /// - Parameters:
    ///   - text: 文本绑定值
    ///   - textField: 关联的UITextField实例
    ///   - selectionStart: 选中文字的开始位置
    ///   - selectionEnd: 选中文字的结束位置
    ///   - focused: 文本字段是否获得焦点
    var keyboardViewBuilder:
        (
            Binding<String>, UITextField, Binding<String.Index>, Binding<String.Index>,
            Binding<Bool>
        ) -> KeyboardView

    public func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.inputView = createKeyboardView(textField: textField)
        context.coordinator.textField = textField
        // 设置初始焦点状态
        if focused {
            textField.becomeFirstResponder()
        }
        return textField
    }

    public func updateUIView(_ uiView: UITextField, context: Context) {
        // 仅在文本实际变化时更新，避免不必要的刷新
        if uiView.text != text {
            uiView.text = text
        }
        // 更新焦点状态
        if focused != (uiView.isFirstResponder) {
            if focused {
                uiView.becomeFirstResponder()
            } else {
                uiView.resignFirstResponder()
            }
        }
        // 强制更新键盘视图，确保响应绑定变化
        uiView.inputView = createKeyboardView(textField: uiView)
    }

    // 添加新方法用于直接更新键盘视图
    public func updateKeyboardView(_ textField: UITextField) {
        textField.inputView = createKeyboardView(textField: textField)
    }

    // 添加一个方法来监听绑定值变化并更新键盘视图
    public func updateBindings() {
        // 当绑定值变化时，我们需要更新键盘视图
        if let textField = UIApplication.shared.windows.first?.rootViewController?.view.subviews.compactMap({ $0 as? UITextField }).first(where: { $0.delegate is Coordinator }) {
            updateKeyboardView(textField)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    /// 创建自定义键盘视图
    private func createKeyboardView(textField: UITextField) -> UIView? {
        // 获取当前选中范围
        let selectedRange =
            textField.selectedTextRange ?? textField.textRange(
                from: textField.beginningOfDocument, to: textField.beginningOfDocument)!

        // 计算选中范围在文本中的偏移量
        let startOffset = textField.offset(
            from: textField.beginningOfDocument, to: selectedRange.start)
        let endOffset = textField.offset(
            from: textField.beginningOfDocument, to: selectedRange.end)

        // 将偏移量转换为String.Index
        startIndex = text.index(text.startIndex, offsetBy: min(startOffset, text.count))
        endIndex = text.index(text.startIndex, offsetBy: min(endOffset, text.count))

        // 创建一个包装视图，用于监听绑定值变化
        let keyboardView = KeyboardWrapperView(
            text: $text,
            textField: textField,
            startIndex: $startIndex,
            endIndex: $endIndex,
            focused: $focused,
            builder: keyboardViewBuilder)

        return UIHostingController(rootView: keyboardView).view
    }

    public class Coordinator: NSObject, UITextFieldDelegate {
        public var parent: ACustomKeyboardTextField
        weak var textField: UITextField?

        public init(parent: ACustomKeyboardTextField) {
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
            // 更新绑定的文本值
            if let currentText = textField.text as NSString? {
                let updatedText = currentText.replacingCharacters(in: range, with: string)
                parent.text = updatedText
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
}


// 添加一个包装视图，用于监听绑定值变化
@available(iOS 14, *)
private struct KeyboardWrapperView<KeyboardView: View>: View {
    @Binding var text: String
    let textField: UITextField
    @Binding var startIndex: String.Index
    @Binding var endIndex: String.Index
    @Binding var focused: Bool
    let builder: (Binding<String>, UITextField, Binding<String.Index>, Binding<String.Index>, Binding<Bool>) -> KeyboardView

    var body: some View {
        // 监听所有绑定值的变化
        // 移除 _printChanges() 调用以支持 iOS 14

        return builder($text, textField, $startIndex, $endIndex, $focused)
            .onChange(of: text) { _ in
                // 文本变化时可以执行额外操作
            }
            .onChange(of: startIndex) { _ in
                // 选中开始位置变化时可以执行额外操作
            }
            .onChange(of: endIndex) { _ in
                // 选中结束位置变化时可以执行额外操作
            }
            .onChange(of: focused) { _ in
                // 焦点状态变化时可以执行额外操作
            }
    }
}


@available(iOS 14, *)
private struct Example: View {
    @State private var text = "123+15"
    @State private var startIndex = String.Index(utf16Offset: 0, in: "")
    @State private var endIndex = String.Index(utf16Offset: 0, in: "")
    @State private var focused = false

    private var selectedText: Substring {
        // 确保 startIndex 和 endIndex 在有效范围内
        let safeStartIndex = min(max(startIndex, text.startIndex), text.endIndex)
        let safeEndIndex = min(max(endIndex, text.startIndex), text.endIndex)
        // 确保 startIndex 不大于 endIndex
        let finalStartIndex = min(safeStartIndex, safeEndIndex)
        let finalEndIndex = max(safeStartIndex, safeEndIndex)

        return text[finalStartIndex ..< finalEndIndex]
    }

    var body: some View {
        List {
            ACustomKeyboardTextField(
                text: $text, startIndex: $startIndex, endIndex: $endIndex, focused: $focused)
            { _, _, _, _, focusedBinding in
                Rectangle()
                    .frame(height: 500)
                    .background(focusedBinding.wrappedValue ? Color.red : Color.blue)
            }
            .multilineTextAlignment(.trailing)
            Text(selectedText)
            Toggle("是否聚焦", isOn: $focused)
        }
    }
}

@available(iOS 14, *)
#Preview {
    Example()
}

#endif
