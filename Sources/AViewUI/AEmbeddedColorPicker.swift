import SwiftUI

#if os(iOS)
// 自定义颜色选择器，支持监听显示状态
@available(iOS 14, *)
public struct AEmbeddedColorPicker<SomeLabel: View>: View {
    @Binding var color: Color
    @Binding var isPresented: Bool // 用于跟踪是否打开的状态

    var picker = UIColorPickerViewController()

    var makeView: () -> SomeLabel

    var coordinator: Coordinator {
        Coordinator(self)
    }

    func showPicker() {
        picker.delegate = coordinator
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController
        {
            rootVC.present(picker, animated: true)
        }
    }

    public var body: some View {
        makeView()
            .onChange(of: isPresented) { newValue in
                if newValue {
                    showPicker()
                }
            }
    }

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

    public class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        var parent: AEmbeddedColorPicker

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
