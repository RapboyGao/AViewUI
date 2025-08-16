import SwiftUI

#if os(iOS)
// 自定义颜色选择器，支持监听显示状态
@available(iOS 14, *)
public struct AEmbeddedColorPicker<SomeLabel: View>: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIHostingController<SomeLabel>

    @Binding var color: Color
    @Binding var isPresented: Bool // 用于跟踪是否打开的状态

    var makeView: () -> SomeLabel

    public init(color: Binding<Color>, isPresented: Binding<Bool>, @ViewBuilder makeView: @escaping () -> SomeLabel) {
        self._color = color
        self._isPresented = isPresented
        self.makeView = makeView
    }

    public init(color: Binding<Color>, isPresented: Binding<Bool>) where SomeLabel == EmptyView {
        self._color = color
        self._isPresented = isPresented
        self.makeView = { EmptyView() }
    }

    public func makeUIView(context: Context) -> UIViewControllerType {
        let hostingController = UIHostingController(rootView: makeView())
        hostingController.view.frame = CGRect(origin: .zero, size: hostingController.view.intrinsicContentSize)
        return hostingController
    }

    public func makeUIViewController(context: Context) -> UIViewControllerType {
        makeUIView(context: context)
    }

    public func updateUIView(_ uiView: UIViewControllerType, context: Context) {
        // 检查是否需要显示颜色选择器
        if isPresented {
            // 如果picker不存在，创建一个新的
            if context.coordinator.picker == nil {
                let picker = UIColorPickerViewController()
                picker.selectedColor = UIColor(color)
                picker.delegate = context.coordinator
                context.coordinator.picker = picker

                // 获取当前的UIViewController并 present 选择器
                // 改进获取根视图控制器的方式
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController
                {
                    rootVC.present(picker, animated: true)
                }
            }
        } else {
            // 如果isPresented为false且picker存在，关闭picker
            if let picker = context.coordinator.picker {
                picker.dismiss(animated: true) {
                    context.coordinator.picker = nil
                }
            }
        }
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        updateUIView(uiViewController, context: context)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        var parent: AEmbeddedColorPicker
        var picker: UIColorPickerViewController?

        init(_ parent: AEmbeddedColorPicker) {
            self.parent = parent
        }

        // 颜色选择变化时调用
        public func colorPickerViewController(
            _ viewController: UIColorPickerViewController, didSelect color: UIColor,
            continuously: Bool
        ) {
            parent.color = Color(color)
        }

        // 选择器即将显示时调用
        public func colorPickerViewControllerDidFinish(
            _ viewController: UIColorPickerViewController
        ) {
            // 选择器关闭时更新状态
            parent.isPresented = false
            picker = nil
        }
    }
}

@available(iOS 15, *)
private struct Example: View {
    @State var color = Color.red
    @State var isPresented = false

    var body: some View {
        List {
            AEmbeddedColorPicker(color: $color, isPresented: $isPresented) {
                Button("Open Color Picker") {
                    isPresented.toggle()
                }
            }
            ColorPicker("Selector", selection: $color)
            Text("Hello")
                .foregroundStyle(color)
        }
    }
}

@available(iOS 15, *)
#Preview {
    Example()
}

#endif
