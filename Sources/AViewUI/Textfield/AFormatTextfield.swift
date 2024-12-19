import SwiftUI

/// 一个自定义视图，支持格式化输入框，并根据给定的格式处理输入数据。
/// - Format: 用于解析和格式化输入的格式化风格类型。
/// - Input: 输入数据的类型。
/// - ModifiedView: 修改视图外观的类型，通常是一个视图修饰符。
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct AFormatTextfield<Format: ParseableFormatStyle, Input, ModifiedView: View>: View where Format.FormatInput == Input, Format.FormatOutput == String {
    /// 占位符文本，用于在文本框为空时显示。
    var placeholder: String

    /// 绑定到输入数据的 `Input` 类型的变量。
    @Binding private var value: Input

    /// 用于格式化输入的格式化风格。
    private var format: Format

    /// 用来修改 `TextField` 样式的闭包。
    private var modifier: (TextField<Text>) -> ModifiedView

    /// 用来追踪输入框的焦点状态。
    @FocusState private var isFocused: Bool

    /// 用来存储和管理输入框中显示的字符串。
    @State private var string: String

    /// 绑定到字符串的值，根据焦点状态来返回不同的值。
    /// 主要是为了防止输入过程中外部绑定值的变化，导致 `string` 突然被覆盖，影响输入体验。
    /// - 如果输入框是聚焦状态，则返回当前输入的字符串；否则，返回格式化后的绑定值。
    private var bindString: Binding<String> {
        Binding {
            // 如果输入框聚焦，返回用户当前输入的字符串
            if isFocused {
                return string
            } else {
                // 否则，返回格式化后的绑定值
                return format.format(value)
            }
        } set: {
            // 更新输入框的字符串值
            string = $0
            // 尝试将字符串解析回原始输入值，并更新绑定的值
            guard let newValue = try? format.parseStrategy.parse($0) else { return }
            value = newValue
        }
    }

    /// 构建视图的主体部分，返回修改后的 `TextField` 视图。
    public var body: some View {
        modifier(
            TextField(text: bindString) {
                Text(self.placeholder) // 设置占位符
            }
        )
        .focused($isFocused) // 绑定焦点状态
    }

    /// 初始化方法，允许自定义 `TextField` 样式的修改。
    /// - Parameters:
    ///   - placeholder: 输入框的占位符文本。
    ///   - bindValue: 绑定到输入数据的 `Input` 类型的 `Binding`。
    ///   - format: 用于格式化和解析输入的格式化风格。
    ///   - modifier: 一个视图修饰符，修改 `TextField` 样式。
    public init(_ placeholder: String, value bindValue: Binding<Input>, format: Format, @ViewBuilder modifier: @escaping (TextField<Text>) -> ModifiedView) {
        self.placeholder = placeholder
        self._value = bindValue
        self.format = format
        // 初始化时，将绑定值格式化为字符串并保存为 `string`，以防外部值变动时影响输入框的体验
        self._string = State(initialValue: format.format(bindValue.wrappedValue))
        self.modifier = modifier
    }

    /// 初始化方法，使用默认的 `TextField` 样式。
    /// - Parameters:
    ///   - placeholder: 输入框的占位符文本。
    ///   - bindValue: 绑定到输入数据的 `Input` 类型的 `Binding`。
    ///   - format: 用于格式化和解析输入的格式化风格。
    public init(_ placeholder: String, value bindValue: Binding<Input>, format: Format) where ModifiedView == TextField<Text> {
        self.placeholder = placeholder
        self._value = bindValue
        self.format = format
        // 初始化时，将绑定值格式化为字符串并保存为 `string`，以防外部值变动时影响输入框的体验
        self._string = State(initialValue: format.format(bindValue.wrappedValue))
        self.modifier = { $0 } // 默认不修改样式
    }
}

/// 示例视图，展示如何使用 `AFormatTextfield` 进行格式化输入。
/// - 使用 `AFormatTextfield` 和原生 `TextField` 展示格式化文本框。
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct Example: View {
    @State private var number: Double = 0.0 // 用于绑定输入数据的状态变量

    /// 视图的主体部分，展示了两个不同的输入框。
    var body: some View {
        List {
            // 使用 AFormatTextfield 进行格式化输入框展示
            AFormatTextfield("number", value: $number, format: .number)
            // 使用原生 TextField 展示相同的绑定值
            TextField("number", value: $number, format: .number)
        }
    }
}

/// 预览代码，展示 `Example` 视图的 UI。
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
#Preview {
    Example() // 显示示例视图
}
