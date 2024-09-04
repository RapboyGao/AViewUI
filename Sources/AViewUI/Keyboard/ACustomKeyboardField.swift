import SwiftUI

/// 一个通用的自定义键盘视图结构体，适用于 iOS 15.0 及以上版本
/// - Parameters:
///   - SomeTextField: 泛型参数，表示文本输入框的视图类型
///   - Keyboard: 泛型参数，表示自定义键盘的视图类型
@available(iOS 15.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct ACustomKeyboardField<SomeTextField: View, Keyboard: View>: View {
    var makeTextfieldView: () -> TextField<SomeTextField>
    var keyboard: (UITextField) -> Keyboard

    public var body: some View {
        makeTextfieldView()
            .aKeyboardView(makeContent: keyboard)
    }

    /// 自定义键盘视图的初始化方法
    /// - Parameters:
    ///   - makeTextfieldView: 闭包，用于生成 TextField 视图
    ///   - keyboard: 闭包，用于生成自定义键盘视图
    public init(makeTextfieldView: @escaping () -> TextField<SomeTextField>, @ViewBuilder keyboard: @escaping (UITextField) -> Keyboard) {
        self.makeTextfieldView = makeTextfieldView
        self.keyboard = keyboard
    }
}

@available(iOS 15.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public extension TextField {
    /// 为 TextField 附加自定义键盘视图
    /// - Parameter makeContent: 闭包，接收 UITextField 作为参数并生成自定义键盘视图
    /// - Returns: 带有自定义键盘的 TextField 视图
    @ViewBuilder
    func aKeyboardView<Content: View>(@ViewBuilder makeContent: @escaping (UITextField) -> Content) -> some View {
        background {
            SetCustomKeyboard(keyboardContent: makeContent)
        }
    }
}

@available(iOS 13.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
private struct SetCustomKeyboard<Content: View>: UIViewRepresentable {
    @ViewBuilder
    var keyboardContent: (UITextField) -> Content

    @State
    private var hostingController: UIHostingController<Content>?

    @State
    private var textFieldReference: UITextField?

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

    func reloadTheKeyboard() {
        guard let textFieldReference = textFieldReference else { return }
        hostingController = UIHostingController(rootView: keyboardContent(textFieldReference))
        hostingController?.view.frame = CGRect(origin: .zero, size: hostingController?.view.intrinsicContentSize ?? .zero)
        textFieldReference.inputView = hostingController?.view
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

    class Coordinator: NSObject {
        var parent: SetCustomKeyboard

        init(_ parent: SetCustomKeyboard) {
            self.parent = parent
        }

        @objc func applicationWillEnterForeground() {
            // 当应用从后台返回前台时重设 inputView
//            parent.textFieldReference?.reloadInputViews()
            parent.reloadTheKeyboard()
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

@available(iOS 13.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
private extension UIView {
    var allSubViews: [UIView] {
        subviews.flatMap { [$0] + $0.subviews }
    }

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
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
#Preview {
    List {
        ACustomKeyboardField {
            TextField("Hello", text: .constant("1"))
        } keyboard: { _ in
            Text("1")
        }
    }
}
