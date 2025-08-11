import SwiftUI

#if os(iOS)
    @available(iOS 14, *)
    public struct ACustomKeyboardTextField<KeyboardView: View>: UIViewRepresentable {
        @Binding var text: String
        /// 键盘视图构建器
        /// - Parameters:
        ///   - text: 文本绑定值
        ///   - textField: 关联的UITextField实例
        ///   - selectionStart: 选中文字的开始位置
        ///   - selectionEnd: 选中文字的结束位置
        var keyboardViewBuilder:
            (Binding<String>, UITextField, String.Index, String.Index) -> KeyboardView

        public func makeUIView(context: Context) -> UITextField {
            let textField = UITextField()
            textField.delegate = context.coordinator
            textField.inputView = createKeyboardView(textField: textField)
            context.coordinator.textField = textField
            return textField
        }

        public func updateUIView(_ uiView: UITextField, context: Context) {
            // 仅在文本实际变化时更新，避免不必要的刷新
            if uiView.text != text {
                uiView.text = text
            }
            // 更新键盘视图，确保选中位置正确
            uiView.inputView = createKeyboardView(textField: uiView)
        }

        // 添加新方法用于直接更新键盘视图
        public func updateKeyboardView(_ textField: UITextField) {
            textField.inputView = createKeyboardView(textField: textField)
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
            let startIndex = text.index(text.startIndex, offsetBy: min(startOffset, text.count))
            let endIndex = text.index(text.startIndex, offsetBy: min(endOffset, text.count))

            // 创建键盘视图
            let keyboardView = keyboardViewBuilder($text, textField, startIndex, endIndex)
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
        }
    }

    @available(iOS 14, *)
    private struct Example: View {
        @State private var text = "123+15"
        @State private var startIndex = String.Index(utf16Offset: 0, in: "")
        @State private var endIndex = String.Index(utf16Offset: 0, in: "")

        private var selectedText: Substring {
            text[startIndex ..< endIndex]
        }

        var body: some View {
            List {
                ACustomKeyboardTextField(text: $text) { _, _, _, _ in
                    Rectangle()
                        .frame(height: 200)
                        .background(Color.red)
                }
                Text(selectedText)
            }
        }
    }

    @available(iOS 14, *)
    #Preview {
        Example()
    }

#endif
