import UIKit

#if os(iOS)
// 自定义颜色选择器，支持监听显示状态
@available(iOS 14, *)
public struct AEmbeddedColorPicker: UIViewRepresentable {
    @Binding var color: Color
    @Binding var isPresented: Bool // 用于跟踪是否打开的状态

    public init(color: Binding<Color>, isPresented: Binding<Bool>) {
        self._color = color
        self._isPresented = isPresented
    }

    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        // 检查是否需要显示颜色选择器
        if isPresented && context.coordinator.picker == nil {
            let picker = UIColorPickerViewController()
            picker.selectedColor = UIColor(color)
            picker.delegate = context.coordinator
            context.coordinator.picker = picker

            // 获取当前的UIViewController并 present 选择器
            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                rootVC.present(picker, animated: true)
            }
        }
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
            Button("Open Color Picker") {
                isPresented.toggle()
            }
            Text("Hello")
                .foregroundStyle(color)
            AEmbeddedColorPicker(color: $color, isPresented: $isPresented)
        }
    }
}

@available(iOS 15, *)
#Preview {
    Example()
}

#endif
