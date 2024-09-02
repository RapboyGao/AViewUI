import SwiftUI

@available(iOS 15.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct ACustomKeyboard<SomeTextField: View, Keyboard: View>: View {
    var makeTextfieldView: () -> TextField<SomeTextField>
    var keyboard: (UITextField) -> Keyboard

    public var body: some View {
        makeTextfieldView()
            .aKeyboardView(makeContent: keyboard)
    }

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
    @State private var hostingController: UIHostingController<Content>?

    func makeUIView(context: Context) -> UIView {
        return UIView()
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            guard let textFieldContainerView = uiView.superview?.superview,
                  let uiTextField = textFieldContainerView.foundTextfield
            else {
                return
            }
            hostingController = UIHostingController(rootView: keyboardContent(uiTextField))
            hostingController?.view.frame = CGRect(origin: .zero, size: hostingController?.view.intrinsicContentSize ?? .zero)
            uiTextField.inputView = hostingController?.view
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
    ACustomKeyboard {
        TextField("Hello", text: .constant("1"))
    } keyboard: { _ in
        Text("1")
    }
}
