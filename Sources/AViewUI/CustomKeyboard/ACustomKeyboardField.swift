import SwiftUI

#if os(iOS)

@available(iOS 15.0, *)
public extension TextField {
    /// 为 TextField 附加自定义键盘视图
    /// - Parameter makeContent: 闭包，接收 UITextField 作为参数并生成自定义键盘视图
    /// - Returns: 带有自定义键盘的 TextField 视图
    @ViewBuilder
    func aKeyboardView<Content: View>(@ViewBuilder makeContent: @escaping (UITextField, Binding<String>) -> Content) -> some View {
        // 使用 SetCustomKeyboard 视图作为背景视图
        background {
            SetCustomKeyboard(keyboardContent: makeContent)
        }
    }


    @ViewBuilder
    /// 创建一个具有指定内容的自定义键盘视图。
    ///
    /// - Parameter makeContent: 一个闭包，接受一个 `UITextField` 作为参数，并返回一个将用作自定义键盘内容的视图。
    /// - Returns: 一个包含具有指定内容的自定义键盘的视图。
    func aKeyboardView<Content: View>(@ViewBuilder makeContent: @escaping (UITextField) -> Content) -> some View {
        // 使用 SetCustomKeyboard 视图作为背景视图
        background {
            SetCustomKeyboard { uiTextField, _ in
                makeContent(uiTextField)
            }
        }
    }
}

@available(iOS 13.0, *)
/// 一个 UIViewRepresentable 结构体，用于为 SwiftUI 视图设置自定义键盘。
///
/// - 参数:
///   - Content: 将使用自定义键盘的 SwiftUI 视图。
private struct SetCustomKeyboard<Content: View>: UIViewRepresentable {
    // 闭包，用于生成自定义键盘视图
    @ViewBuilder
    var keyboardContent: (UITextField, Binding<String>) -> Content

    // 保存 UIHostingController 的状态
    @State
    private var hostingController: UIHostingController<Content>?

    // 保存 UITextField 的引用
    @State
    private var textFieldReference: UITextField?

    @State var textInTheTextfield = String()

    // 保存 TextfieldCoordinator 的实例
    @State private var textfieldCoordinator: TextfieldCoordinator?

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        // 监听应用从后台返回前台的通知
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(context.coordinator.applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )

        return view
    }

    // 重新加载自定义键盘视图
    func reloadTheKeyboard() {
        guard let textFieldReference = textFieldReference else { return }
        hostingController = UIHostingController(rootView: keyboardContent(textFieldReference, $textInTheTextfield))
        hostingController?.view.frame = CGRect(origin: .zero, size: hostingController?.view.intrinsicContentSize ?? .zero)
        textFieldReference.inputView = hostingController?.view
        textInTheTextfield = textFieldReference.text ?? ""
        let coordinator = TextfieldCoordinator(self)
        textFieldReference.delegate = coordinator
        textfieldCoordinator = coordinator // 保存对 TextfieldCoordinator 的引用
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            guard let textFieldContainerView = uiView.superview?.superview,
                  let uiTextField = textFieldContainerView.foundTextfield
            else {
                return
            }
            self.textFieldReference = uiTextField // 保存对 UITextField 的引用
            reloadTheKeyboard()
        }
    }

    // 创建 Coordinator 类来处理通知
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class TextfieldCoordinator: NSObject, UITextFieldDelegate {
        var parent: SetCustomKeyboard

        init(_ parent: SetCustomKeyboard) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.textInTheTextfield = textField.text ?? ""
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // 获取当前文本
            let currentText = textField.text ?? ""
            // 计算新的文本
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            // 更新绑定的文本
            parent.textInTheTextfield = updatedText
            return true
        }
    }

    class Coordinator: NSObject {
        var parent: SetCustomKeyboard

        init(_ parent: SetCustomKeyboard) {
            self.parent = parent
        }

        @objc func applicationWillEnterForeground() {
            // 当应用从后台返回前台时重设 inputView
            parent.reloadTheKeyboard()
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

@available(iOS 13.0, *)
private extension UIView {
    // 获取所有子视图
    var allSubViews: [UIView] {
        subviews.flatMap { [$0] + $0.subviews }
    }

    // 查找 UITextField 视图
    var foundTextfield: UITextField? {
        for someUIView in allSubViews {
            guard let textField = someUIView as? UITextField
            else { continue }
            return textField
        }
        return nil
    }
}

@available(iOS 15.0, *)
#Preview {
    List {
        TextField("Hello", text: .constant("1"))
            .aKeyboardView { _, _ in
                Text("1")
            }
    }
}

#endif
