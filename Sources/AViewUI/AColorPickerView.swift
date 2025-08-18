import SwiftUI
import UIKit

#if canImport(UIKit)
@available(iOS 14, tvOS 14, watchOS 7, *)
public struct AColorPickerView: UIViewControllerRepresentable {
    @Binding private var color: Color?

    private var onPickerClose: (Color?) -> Void
    private var supportsAlpha: Bool
    private var defaultColor: Color
    private var selectedColor: Color?

    // 初始化方法
    public init(
        color: Binding<Color?>,
        supportsAlpha: Bool = true,
        defaultColor: Color = .clear,
        onPickerClose: @escaping (Color?) -> Void = { _ in }
    ) {
        _color = color
        self.onPickerClose = onPickerClose
        self.supportsAlpha = supportsAlpha
        self.defaultColor = defaultColor
        self.selectedColor = color.wrappedValue
    }

    // 创建Coordinator类来处理颜色选择器的委托方法
    public class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        var parent: AColorPickerView

        init(_ parent: AColorPickerView) {
            self.parent = parent
        }

        // 颜色选择变化时调用
        public func colorPickerViewController(
            _ viewController: UIColorPickerViewController,
            didSelect color: UIColor,
            continuously: Bool
        ) {
            parent.color = Color(color)
        }

        // 选择器关闭时调用
        public func colorPickerViewControllerDidFinish(
            _ viewController: UIColorPickerViewController
        ) {
            parent.onPickerClose(Color(viewController.selectedColor))
        }
    }

    // 创建Coordinator实例
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // 创建并配置颜色选择器视图控制器
    public func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = context.coordinator
        colorPicker.selectedColor = selectedColor.map { UIColor($0) } ?? UIColor(defaultColor)
        colorPicker.supportsAlpha = supportsAlpha
        return colorPicker
    }

    // 更新颜色选择器视图控制器
    public func updateUIViewController(
        _ uiViewController: UIColorPickerViewController,
        context: Context
    ) {
        uiViewController.selectedColor = color.map { UIColor($0) } ?? UIColor(defaultColor)
        uiViewController.supportsAlpha = supportsAlpha
    }
}

#endif

#if canImport(UIKit) && DEBUG

// 示例视图，展示如何使用AColorPickerView
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct Example: View {
    @State private var color: Color? = Color.red
    @State private var isPresented = false
    @State private var lastSelectedColor: Color?

    var body: some View {
        VStack {
            Button("Open Color Picker") {
                isPresented.toggle()
            }
            .buttonStyle(.borderedProminent)

            if let lastColor = lastSelectedColor {
                Text("Last selected color")
                Rectangle()
                    .fill(lastColor)
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
            }

            Text("Current color")
            Rectangle()
                .fill(color ?? .gray.opacity(0.3))
                .frame(width: 100, height: 100)
                .cornerRadius(10)
                .overlay {
                    if color == nil {
                        Text("No color")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
        }
        .sheet(isPresented: $isPresented) { 
            NavigationStack { 
                AColorPickerView(
                    color: $color,
                    supportsAlpha: true,
                    defaultColor: .blue,
                    onPickerClose: { closedWithColor in
                        lastSelectedColor = closedWithColor
                    }
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { 
                    ToolbarItem(placement: .cancellationAction) { 
                        Button("Cancel") { 
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
#Preview { 
    Example()
}

#endif
