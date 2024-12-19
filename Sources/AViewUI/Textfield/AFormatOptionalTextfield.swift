import SwiftUI

/// AFormatOptionalTextfield 是一个自定义的 SwiftUI 视图，用于根据指定的格式化风格处理可选值，并与 `TextField` 配合显示格式化后的文本。
/// 支持格式化输入的显示和编辑，适用于具有可选值的情况，支持多种格式化类型。
/// - Format: 格式化样式类型，遵循 `ParseableFormatStyle` 协议
/// - Input: 输入值的类型
/// - ModifiedView: 用于修饰 `TextField` 的视图类型
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct AFormatOptionalTextfield<Format: ParseableFormatStyle, Input, ModifiedView: View>: View where Format.FormatInput == Input, Format.FormatOutput == String {
    // 占位符文本
    var placeholder: String

    // 绑定的可选输入值
    @Binding private var originalValue: Input?

    // 格式化对象
    private var format: Format

    // 用于修饰 TextField 的闭包
    private var modifier: (TextField<Text>) -> ModifiedView

    // 焦点状态，用于确定输入框是否被聚焦
    @FocusState private var isFocused: Bool

    // 用于绑定和显示的字符串值
    @State private var string: String

    /// 计算得到一个绑定的字符串，用于与 `TextField` 交互
    private var bindString: Binding<String> {
        Binding {
            // 当文本框处于聚焦状态时，返回当前编辑的字符串
            if isFocused {
                return string
            }
            // 如果原始值存在，则使用格式化器将其转换为字符串
            else if let value = originalValue {
                return format.format(value)
            }
            // 否则返回空字符串
            else {
                return ""
            }
        } set: {
            // 更新字符串值，并尝试解析新的输入值为原始类型
            string = $0
            originalValue = try? format.parseStrategy.parse($0)
        }
    }

    public var body: some View {
        modifier(
            TextField(text: bindString) {
                // 设置文本框的占位符
                Text(self.placeholder)
            }
        )
        .focused($isFocused) // 绑定焦点状态
    }

    /// 初始化方法，创建一个格式化文本框
    /// - Parameters:
    ///   - placeholder: 文本框的占位符文本
    ///   - bindValue: 绑定的可选输入值
    ///   - format: 格式化样式
    ///   - modifier: 用于修饰 TextField 的视图闭包
    public init(_ placeholder: String, value bindValue: Binding<Input?>, format: Format, @ViewBuilder modifier: @escaping (TextField<Text>) -> ModifiedView) {
        self.placeholder = placeholder
        self._originalValue = bindValue
        self.format = format
        // 如果原始值存在，则初始化 `string` 为格式化后的值，否则为空字符串
        if let value = bindValue.wrappedValue {
            self._string = State(initialValue: format.format(value))
        }
        else {
            self._string = State(initialValue: "")
        }
        self.modifier = modifier
    }

    /// 默认初始化方法，创建一个标准的格式化文本框，不添加任何自定义修饰符
    /// - Parameters:
    ///   - placeholder: 文本框的占位符文本
    ///   - bindValue: 绑定的可选输入值
    ///   - format: 格式化样式
    public init(_ placeholder: String, value bindValue: Binding<Input?>, format: Format) where ModifiedView == TextField<Text> {
        self.init(placeholder, value: bindValue, format: format) {
            $0 // 默认返回 TextField 本身
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
/// 示例视图，展示了如何使用 AFormatOptionalTextfield 和标准 TextField
private struct Example: View {
    // 使用可选的 Double 类型作为输入值
    @State private var number: Double? = 0.0

    var body: some View {
        List {
            // 使用 AFormatOptionalTextfield 来显示和编辑格式化后的 Double 值
            AFormatOptionalTextfield("number", value: $number, format: .number)

            // 使用标准的 TextField 来显示和编辑 Double 值
            TextField("number", value: $number, format: .number)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
#Preview {
    Example() // 预览示例视图
}
