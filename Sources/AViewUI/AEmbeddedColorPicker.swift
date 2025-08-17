import SwiftUI

#if os(iOS)

@available(iOS 14, *)
private func showPicker(picker: UIColorPickerViewController, color: Color) {
    // 设置初始颜色
    picker.selectedColor = UIColor(color)
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootVC = windowScene.windows.first?.rootViewController
    {
        rootVC.present(picker, animated: true)
    }
}

// 自定义颜色选择器，支持监听显示状态
@available(iOS 14, *)
public struct AEmbeddedColorPicker<SomeLabel: View>: View {
    @Binding var color: Color
    @Binding var isPresented: Bool // 用于跟踪是否打开的状态

    private let picker: UIColorPickerViewController
    // 将coordinator改为实例属性
    private let coordinator: Coordinator

    var makeView: () -> SomeLabel

    public var body: some View {
        makeView()
            .onChange(of: isPresented) { newValue in
                if newValue {
                    showPicker(picker: picker, color: color)
                }
            }
    }

    // 初始化方法中创建coordinator
    public init(color: Binding<Color>, isPresented: Binding<Bool>, makeView: @escaping () -> SomeLabel) {
        _color = color
        _isPresented = isPresented
        self.makeView = makeView
        coordinator = Coordinator(color, presented: isPresented)
        picker = UIColorPickerViewController()
        picker.delegate = coordinator

        if isPresented.wrappedValue {
            showPicker(picker: picker, color: color.wrappedValue)
        }
    }

    public init(color: Binding<Color>, isPresented: Binding<Bool>) where SomeLabel == EmptyView {
        self.init(color: color, isPresented: isPresented, makeView: { EmptyView() })
    }

    // 定义Coordinator类，使用命名参数避免歧义
    public class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        var bindColor: Binding<Color>
        var bindPresented: Binding<Bool>

        init(_ bindColor: Binding<Color>, presented bindPresented: Binding<Bool>) {
            self.bindColor = bindColor
            self.bindPresented = bindPresented
        }

        // 颜色选择变化时调用
        public func colorPickerViewController(
            _ viewController: UIColorPickerViewController, didSelect color: UIColor,
            continuously: Bool
        ) {
            bindColor.wrappedValue = Color(color)
        }

        // 选择器即将显示时调用
        public func colorPickerViewControllerDidFinish(
            _ viewController: UIColorPickerViewController
        ) {
            // 选择器关闭时更新状态
            bindPresented.wrappedValue = false
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
