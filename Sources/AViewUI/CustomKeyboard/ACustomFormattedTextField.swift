import AMathExpression
import SwiftUI

#if os(iOS)
/// 自定义格式化文本字段组件
/// Custom formatted text field component
///
/// 一个支持自定义键盘和格式化的通用文本输入组件，使用ParseableFormatStyle进行值绑定和格式化
/// A generic text input component that supports custom keyboards and formatting, using ParseableFormatStyle for value binding and formatting
///
/// ## 功能特性 / Features
/// - 支持自定义键盘视图 / Supports custom keyboard views
/// - 使用ParseableFormatStyle进行值格式化 / Uses ParseableFormatStyle for value formatting
/// - 实时解析和格式化 / Real-time parsing and formatting
/// - 支持焦点状态管理 / Supports focus state management
/// - 支持文本对齐设置 / Supports text alignment settings
///
/// ## 使用示例 / Usage Example
/// ```swift
/// @State private var doubleValue = 123.45
/// let formatStyle = AMathFormatStyle.fractionLength(5)
///
/// ACustomFormattedTextField(
///     value: $doubleValue,
///     formatStyle: formatStyle
/// ) { uiTextField in
///     AMathExpressionKeyboard(uiTextField, formatStyle)
/// }
/// ```
///
/// ## 参数说明 / Parameter Description
/// - Value: 绑定的值类型，必须遵循Equatable和Sendable协议 / The bound value type, must conform to Equatable and Sendable protocols
/// - Format: 格式化样式类型，必须遵循ParseableFormatStyle协议 / The format style type, must conform to ParseableFormatStyle protocol
/// - KeyboardView: 键盘视图类型，必须是View / The keyboard view type, must be a View
///
/// ## 注意事项 / Notes
/// - 仅支持iOS 15.0及以上版本 / Only supports iOS 15.0 and above
/// - Format的FormatInput必须等于Value，FormatOutput必须等于String / Format's FormatInput must equal Value, FormatOutput must equal String
@available(iOS 15, *)
public struct ACustomFormattedTextField<Value: Equatable & Sendable, Format: ParseableFormatStyle, KeyboardView: View>:
    UIViewRepresentable
where Format.FormatInput == Value, Format.FormatOutput == String {
    
    /// 绑定的值 / Bound value
    @Binding var value: Value
    
    /// 文本选择起始索引 / Text selection start index
    @Binding var startIndex: String.Index
    
    /// 文本选择结束索引 / Text selection end index
    @Binding var endIndex: String.Index
    
    /// 焦点状态 / Focus state
    @Binding var focused: Bool
    
    /// 文本对齐方式 / Text alignment
    private var isRightAligned: Bool?

    /// 文本框创建函数 / Text field creation function
    var makeTextfield: () -> UITextField
    
    /// 格式化样式 / Format style
    var formatStyle: Format

    /// 键盘视图构建器 / Keyboard view builder
    /// - Parameters:
    ///   - textField: 关联的UITextField实例 / Associated UITextField instance
    /// - Returns: 键盘视图 / Keyboard view
    var keyboardViewBuilder: (UITextField) -> KeyboardView

    /// 显式定义初始化函数 - 直接绑定值
    /// Explicit initialization function - direct value binding
    ///
    /// ## 使用场景 / Usage Scenario
    /// 当需要完全控制编辑状态时使用此初始化方法
    /// Use this initialization method when you need full control over editing state
    ///
    /// ## 参数说明 / Parameters
    /// - value: 绑定的值 / Bound value
    /// - startIndex: 文本选择起始索引 / Text selection start index
    /// - endIndex: 文本选择结束索引 / Text selection end index
    /// - focused: 焦点状态 / Focus state
    /// - formatStyle: 格式化样式 / Format style
    /// - keyboardViewBuilder: 键盘视图构建器 / Keyboard view builder
    /// - makeTextfield: 文本框创建函数 / Text field creation function
    public init(
        value: Binding<Value>,
        startIndex: Binding<String.Index>,
        endIndex: Binding<String.Index>,
        focused: Binding<Bool>,
        formatStyle: Format,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView,
        makeTextfield: @escaping () -> UITextField = { UITextField() }
    ) {
        self._value = value
        self._startIndex = startIndex
        self._endIndex = endIndex
        self._focused = focused
        self.formatStyle = formatStyle
        self.keyboardViewBuilder = keyboardViewBuilder
        self.makeTextfield = makeTextfield
    }
    
    /// 简化的初始化函数 - 自动管理编辑状态
    /// Simplified initialization function - automatic editing state management
    ///
    /// ## 使用场景 / Usage Scenario
    /// 当不需要手动管理编辑状态时使用此初始化方法，组件会自动创建和管理内部状态
    /// Use this initialization method when you don't need to manually manage editing state, the component will automatically create and manage internal state
    ///
    /// ## 参数说明 / Parameters
    /// - value: 绑定的值 / Bound value
    /// - formatStyle: 格式化样式 / Format style
    /// - keyboardViewBuilder: 键盘视图构建器 / Keyboard view builder
    /// - makeTextfield: 文本框创建函数 / Text field creation function
    public init(
        value: Binding<Value>,
        formatStyle: Format,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView,
        makeTextfield: @escaping () -> UITextField = { UITextField() }
    ) {
        self._value = value
        
        // 创建可变的状态存储 / Create mutable state storage
        let initialText = formatStyle.format(value.wrappedValue)
        var startIndex = initialText.startIndex
        var endIndex = initialText.endIndex
        var focused = false
        
        // 创建可变绑定 / Create mutable bindings
        self._startIndex = Binding {
            startIndex
        } set: {
            startIndex = $0
        }
        
        self._endIndex = Binding {
            endIndex
        } set: {
            endIndex = $0
        }
        
        self._focused = Binding {
            focused
        } set: {
            focused = $0
        }
        
        self.formatStyle = formatStyle
        self.keyboardViewBuilder = keyboardViewBuilder
        self.makeTextfield = makeTextfield
    }

    /// 新增初始化函数，包含isRightAligned参数 - 直接绑定值
    /// Initialization function with isRightAligned parameter - direct value binding
    ///
    /// ## 使用场景 / Usage Scenario
    /// 当需要设置文本对齐方式时使用此初始化方法
    /// Use this initialization method when you need to set text alignment
    ///
    /// ## 参数说明 / Parameters
    /// - value: 绑定的值 / Bound value
    /// - startIndex: 文本选择起始索引 / Text selection start index
    /// - endIndex: 文本选择结束索引 / Text selection end index
    /// - focused: 焦点状态 / Focus state
    /// - isRightAligned: 是否右对齐 / Whether right aligned
    /// - formatStyle: 格式化样式 / Format style
    /// - keyboardViewBuilder: 键盘视图构建器 / Keyboard view builder
    public init(
        value: Binding<Value>,
        startIndex: Binding<String.Index>,
        endIndex: Binding<String.Index>,
        focused: Binding<Bool>,
        isRightAligned: Bool,
        formatStyle: Format,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView
    ) {
        self.init(
            value: value,
            startIndex: startIndex,
            endIndex: endIndex,
            focused: focused,
            formatStyle: formatStyle,
            keyboardViewBuilder: keyboardViewBuilder,
            makeTextfield: {
                let textField = UITextField()
                textField.textAlignment = isRightAligned ? .right : .left
                return textField
            }
        )
        self.isRightAligned = isRightAligned
    }

    /// 新增初始化函数，接受value和外部ACustomKeyboardEditingStatus
    /// Initialization function accepting value and external ACustomKeyboardEditingStatus
    ///
    /// ## 使用场景 / Usage Scenario
    /// 当需要在外部管理编辑状态时使用此初始化方法，适用于多个组件共享编辑状态
    /// Use this initialization method when you need to manage editing state externally, suitable for multiple components sharing editing state
    ///
    /// ## 参数说明 / Parameters
    /// - value: 绑定的值 / Bound value
    /// - editingStatus: 外部编辑状态 / External editing status
    /// - formatStyle: 格式化样式 / Format style
    /// - keyboardViewBuilder: 键盘视图构建器 / Keyboard view builder
    /// - makeTextfield: 文本框创建函数 / Text field creation function
    public init(
        value: Binding<Value>,
        editingStatus: Binding<ACustomKeyboardEditingStatus>,
        formatStyle: Format,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView,
        makeTextfield: @escaping () -> UITextField = { UITextField() }
    ) {
        self._value = value

        // 使用外部编辑状态的索引和焦点 / Use external editing status for index and focus
        self._startIndex = Binding {
            editingStatus.wrappedValue.startIndex
        } set: {
            editingStatus.startIndex.wrappedValue = $0
        }

        self._endIndex = Binding {
            editingStatus.wrappedValue.endIndex
        } set: {
            editingStatus.endIndex.wrappedValue = $0
        }

        self._focused = Binding {
            editingStatus.wrappedValue.focused
        } set: {
            editingStatus.focused.wrappedValue = $0
        }

        // 初始化编辑状态的文本 / Initialize editing status text
        editingStatus.wrappedValue.text = formatStyle.format(value.wrappedValue)

        self.formatStyle = formatStyle
        self.keyboardViewBuilder = keyboardViewBuilder
        self.makeTextfield = makeTextfield
    }

    /// 新增初始化函数，接受value、外部ACustomKeyboardEditingStatus和isRightAligned
    /// Initialization function accepting value, external ACustomKeyboardEditingStatus, and isRightAligned
    ///
    /// ## 使用场景 / Usage Scenario
    /// 当需要在外部管理编辑状态并设置文本对齐方式时使用此初始化方法
    /// Use this initialization method when you need to manage editing state externally and set text alignment
    ///
    /// ## 参数说明 / Parameters
    /// - value: 绑定的值 / Bound value
    /// - editingStatus: 外部编辑状态 / External editing status
    /// - isRightAligned: 是否右对齐 / Whether right aligned
    /// - formatStyle: 格式化样式 / Format style
    /// - keyboardViewBuilder: 键盘视图构建器 / Keyboard view builder
    public init(
        value: Binding<Value>,
        editingStatus: Binding<ACustomKeyboardEditingStatus>,
        isRightAligned: Bool,
        formatStyle: Format,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView
    ) {
        self._value = value

        // 使用外部编辑状态的索引和焦点 / Use external editing status for index and focus
        self._startIndex = Binding {
            editingStatus.wrappedValue.startIndex
        } set: {
            editingStatus.startIndex.wrappedValue = $0
        }

        self._endIndex = Binding {
            editingStatus.wrappedValue.endIndex
        } set: {
            editingStatus.endIndex.wrappedValue = $0
        }

        self._focused = Binding {
            editingStatus.wrappedValue.focused
        } set: {
            editingStatus.focused.wrappedValue = $0
        }

        // 初始化编辑状态的文本 / Initialize editing status text
        editingStatus.wrappedValue.text = formatStyle.format(value.wrappedValue)

        self.formatStyle = formatStyle
        self.keyboardViewBuilder = keyboardViewBuilder
        self.makeTextfield = {
            let textField = UITextField()
            textField.textAlignment = isRightAligned ? .right : .left
            return textField
        }
        self.isRightAligned = isRightAligned
    }

    /// 创建UITextField视图 / Create UITextField view
    /// - Parameter context: UIViewRepresentable上下文 / UIViewRepresentable context
    /// - Returns: 配置好的UITextField实例 / Configured UITextField instance
    public func makeUIView(context: Context) -> UITextField {
        // 使用makeTextfield函数创建文本框 / Create text field using makeTextfield function
        let textField = makeTextfield()
        // 设置代理为协调器 / Set delegate to coordinator
        textField.delegate = context.coordinator
        // 监听文本变化 / Observe text changes
        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.handleEditingChanged(_:)),
            for: .editingChanged
        )
        // 设置自定义键盘视图 / Set custom keyboard view
        textField.inputView = createKeyboardView(textField: textField)
        // 保存文本框引用 / Save text field reference
        context.coordinator.textField = textField

        // 设置初始文本和焦点状态 / Set initial text and focus state
        textField.text = formatStyle.format(value)
        if focused {
            // 如果需要聚焦，则成为第一响应者 / If focus is needed, become first responder
            textField.becomeFirstResponder()
        }
        
        // 记录初始文本 / Record initial text
        context.coordinator.recordText(textField.text)

        return textField
    }

    /// 更新UITextField视图 / Update UITextField view
    /// - Parameters:
    ///   - uiView: 要更新的UITextField / UITextField to update
    ///   - context: UIViewRepresentable上下文 / UIViewRepresentable context
    public func updateUIView(_ uiView: UITextField, context: Context) {
        // 只有当textfield未聚焦或者值从外部变化且与当前文本解析结果不一致时，才更新文本
        // Only update text when textfield is not focused or value changed externally and differs from current text parsing result
        let formattedText = formatStyle.format(value)
        if !focused {
            // 未聚焦时，始终保持与value同步 / When not focused, always keep in sync with value
            uiView.text = formattedText
            context.coordinator.recordText(uiView.text)
        } else if uiView.text == nil {
            // 文本为空时初始化 / Initialize when text is empty
            uiView.text = formattedText
            context.coordinator.recordText(uiView.text)
        }

        // 更新焦点状态 / Update focus state
        if focused != (uiView.isFirstResponder) {
            if focused {
                // 需要聚焦时成为第一响应者 / Become first responder when focus is needed
                uiView.becomeFirstResponder()
            } else {
                // 不需要聚焦时放弃第一响应者 / Resign first responder when focus is not needed
                uiView.resignFirstResponder()
            }
        }

        // 更新文本对齐方式 / Update text alignment
        if let isRightAligned = isRightAligned {
            uiView.textAlignment = isRightAligned ? .right : .left
        }

        // 强制更新键盘视图 / Force update keyboard view
        uiView.inputView = createKeyboardView(textField: uiView)
    }

    /// 手动触发解析当前文本 / Manually trigger parsing of current text
    /// - Parameter textField: 要解析的文本框 / Text field to parse
    public func parseCurrentText(_ textField: UITextField) {
        if let currentText = textField.text {
            // 尝试解析当前文本 / Try to parse current text
            if let parsedValue = try? formatStyle.parseStrategy.parse(currentText) {
                // 更新绑定的值 / Update bound value
                value = parsedValue
            }
        }
    }

    /// 更新键盘视图方法 / Update keyboard view method
    /// - Parameter textField: 要更新键盘的文本框 / Text field to update keyboard for
    public func updateKeyboardView(_ textField: UITextField) {
        // 重新创建键盘视图 / Recreate keyboard view
        textField.inputView = createKeyboardView(textField: textField)
    }

    /// 监听绑定值变化并更新键盘视图 / Listen for binding value changes and update keyboard view
    public func updateBindings() {
        // 使用正确的方式获取当前窗口 / Use correct way to get current window
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first,
            let textField = window.rootViewController?.view.subviews
                .compactMap({ $0 as? UITextField }).first(where: { $0.delegate is Coordinator })
        {
            // 找到文本框后更新键盘视图 / Update keyboard view after finding text field
            updateKeyboardView(textField)
        }
    }

    /// 创建协调器 / Create coordinator
    /// - Returns: 协调器实例 / Coordinator instance
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    /// 创建自定义键盘视图 / Create custom keyboard view
    /// - Parameter textField: 关联的文本框 / Associated text field
    /// - Returns: 键盘视图的UIView / UIView for keyboard view
    private func createKeyboardView(textField: UITextField) -> UIView? {
        // 获取当前选中范围 / Get current selection range
        let selectedRange =
            textField.selectedTextRange ?? textField.textRange(
                from: textField.beginningOfDocument, to: textField.beginningOfDocument
            )!

        // 计算选中范围在文本中的偏移量 / Calculate offset of selection range in text
        let startOffset = textField.offset(
            from: textField.beginningOfDocument, to: selectedRange.start
        )
        let endOffset = textField.offset(
            from: textField.beginningOfDocument, to: selectedRange.end
        )

        // 将偏移量转换为String.Index / Convert offsets to String.Index
        let currentText = textField.text ?? ""
        startIndex = currentText.index(currentText.startIndex, offsetBy: min(startOffset, currentText.count))
        endIndex = currentText.index(currentText.startIndex, offsetBy: min(endOffset, currentText.count))

        // 创建键盘包装视图 / Create keyboard wrapper view
        let keyboardView = KeyboardWrapperView<KeyboardView>(
            value: $value,
            textField: textField,
            startIndex: $startIndex,
            endIndex: $endIndex,
            focused: $focused,
            formatStyle: formatStyle,
            builder: keyboardViewBuilder
        )
        // 创建UIHostingController来包装SwiftUI视图 / Create UIHostingController to wrap SwiftUI view
        let hostingController = UIHostingController(rootView: keyboardView)

        // 设置键盘视图的frame / Set keyboard view frame
        hostingController.view.frame = CGRect(origin: .zero, size: hostingController.view.intrinsicContentSize)

        return hostingController.view
    }

    /// 协调器类，处理UITextField代理方法
    /// Coordinator class that handles UITextField delegate methods
    public class Coordinator: NSObject, UITextFieldDelegate {
        /// 父组件引用 / Parent component reference
        public var parent: ACustomFormattedTextField
        
        /// 弱引用的文本框 / Weak reference to text field
        weak var textField: UITextField?
        
        /// 记录上一次已知的文本，用于判断文本是否发生变化
        /// Track last known text to detect changes
        private var lastKnownText: String = ""

        /// 初始化协调器 / Initialize coordinator
        /// - Parameter parent: 父组件 / Parent component
        public init(parent: ACustomFormattedTextField) {
            self.parent = parent
            super.init()
        }
        
        /// 记录当前文本，避免重复同步
        /// Record current text to avoid redundant sync
        public func recordText(_ text: String?) {
            lastKnownText = text ?? ""
        }
        
        /// 当文本来源于UITextField时，同步绑定值
        /// Sync binding when text changes are sourced from UITextField
        private func syncValueIfNeeded(from textField: UITextField) {
            let currentText = textField.text ?? ""
            guard currentText != lastKnownText else { return }
            lastKnownText = currentText
            if let parsedValue = try? parent.formatStyle.parseStrategy.parse(currentText) {
                if parsedValue != parent.value {
                    parent.value = parsedValue
                }
            }
        }

        /// 监听文本变化事件 / Observe editing changed events
        @objc public func handleEditingChanged(_ textField: UITextField) {
            syncValueIfNeeded(from: textField)
        }

        /// 当选择范围变化时更新键盘 / Update keyboard when selection range changes
        /// - Parameter textField: 文本框 / Text field
        public func textFieldDidChangeSelection(_ textField: UITextField) {
            syncValueIfNeeded(from: textField)
            parent.updateKeyboardView(textField)
        }

        /// 处理文本变化 / Handle text changes
        /// - Parameters:
        ///   - textField: 文本框 / Text field
        ///   - range: 要修改的范围 / Range to modify
        ///   - string: 替换字符串 / Replacement string
        /// - Returns: 是否允许修改 / Whether modification is allowed
        public func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            if let currentText = textField.text as NSString? {
                // 计算更新后的文本 / Calculate updated text
                let updatedText = currentText.replacingCharacters(in: range, with: string)
                
                // 更新文本字段 / Update text field
                textField.text = updatedText
                recordText(updatedText)
                
                // 实时解析文本并更新value，但不影响用户输入
                // Parse text in real-time and update value, but don't affect user input
                if let parsedValue = try? parent.formatStyle.parseStrategy.parse(updatedText) {
                    parent.value = parsedValue
                }
            }
            return false
        }

        /// 文本字段将要开始编辑 / Text field will begin editing
        /// - Parameters:
        ///   - textField: 文本框 / Text field
        /// - Returns: 是否允许开始编辑 / Whether editing is allowed
        public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            parent.focused = true
            return true
        }

        /// 处理回车键 / Handle return key
        /// - Parameter textField: 文本框 / Text field
        /// - Returns: 是否允许回车 / Whether return is allowed
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // 回车时解析文本并更新value / Parse text and update value when return is pressed
            if let currentText = textField.text {
                if let parsedValue = try? parent.formatStyle.parseStrategy.parse(currentText) {
                    parent.value = parsedValue
                }
            }
            
            // 更新textfield内容为格式化后的value，确保显示一致
            // Update textfield content to formatted value, ensuring display consistency
            textField.text = parent.formatStyle.format(parent.value)
            recordText(textField.text)
            
            return true
        }
        
        /// 文本字段结束编辑 / Text field ended editing
        /// - Parameter textField: 文本框 / Text field
        public func textFieldDidEndEditing(_ textField: UITextField) {
            parent.focused = false

            // 失去焦点时解析文本并更新value / Parse text and update value when losing focus
            if let currentText = textField.text {
                if let parsedValue = try? parent.formatStyle.parseStrategy.parse(currentText) {
                    parent.value = parsedValue
                }
            }
            
            // 更新textfield内容为格式化后的value，确保显示一致
            // Update textfield content to formatted value, ensuring display consistency
            textField.text = parent.formatStyle.format(parent.value)
            recordText(textField.text)
        }
    }

    /// 包装视图，用于监听绑定值变化
    /// Wrapper view for monitoring binding value changes
    ///
    /// ## 参数说明 / Parameters
    /// - BuilderKeyboardView: 构建的键盘视图类型 / Built keyboard view type
    private struct KeyboardWrapperView<BuilderKeyboardView: View>: View {
        /// 绑定的值 / Bound value
        @Binding var value: Value
        
        /// 文本框 / Text field
        let textField: UITextField
        
        /// 文本选择起始索引 / Text selection start index
        @Binding var startIndex: String.Index
        
        /// 文本选择结束索引 / Text selection end index
        @Binding var endIndex: String.Index
        
        /// 焦点状态 / Focus state
        @Binding var focused: Bool
        
        /// 格式化样式 / Format style
        let formatStyle: Format
        
        /// 构建器函数 / Builder function
        /// - Parameter textField: 文本框 / Text field
        /// - Returns: 键盘视图 / Keyboard view
        let builder: (UITextField) -> BuilderKeyboardView

        /// 视图主体 / View body
        /// - Returns: 构建的键盘视图 / Built keyboard view
        var body: some View {
            return builder(textField)
        }
    }
}

// 示例结构体 / Example structure
/// ACustomFormattedTextField组件的使用示例
/// Usage example for ACustomFormattedTextField component
///
/// ## 功能演示 / Features Demonstration
/// - 展示浮点数输入和格式化 / Demonstrates floating-point input and formatting
/// - 展示自定义键盘集成 / Demonstrates custom keyboard integration
/// - 展示文本对齐控制 / Demonstrates text alignment control
/// - 展示焦点状态管理 / Demonstrates focus state management
@available(iOS 16, *)
private struct ACustomFormattedTextFieldExample: View {
    // 使用浮点数类型的示例 / Example using floating-point type
    /// 当前输入的数值 / Currently input numeric value
    @State private var doubleValue = 123.45
    
    /// 文本选择起始索引 / Text selection start index
    @State private var startIndex = String.Index(utf16Offset: 0, in: "123.45")
    
    /// 文本选择结束索引 / Text selection end index
    @State private var endIndex = String.Index(utf16Offset: 6, in: "123.45")
    
    /// 焦点状态 / Focus state
    @State private var focused = false

    // 右对齐选项 / Right alignment option
    /// 是否右对齐文本 / Whether to right-align text
    @State private var isRightAligned = false

    // 格式化样式 / Format style
    /// 数学表达式格式化样式，设置小数位数为5 / Math expression format style, setting decimal places to 5
    private var formatStyle = AMathFormatStyle.fractionLength(5)

    /// 视图主体 / View body
    /// - Returns: 包含示例界面的视图 / View containing example interface
    var body: some View {
        List {
            // 浮点数输入示例，使用AMathExpressionKeyboard
            // Floating-point input example, using AMathExpressionKeyboard
            ACustomFormattedTextField(
                value: $doubleValue,
                startIndex: $startIndex,
                endIndex: $endIndex,
                focused: $focused,
                isRightAligned: isRightAligned,
                formatStyle: formatStyle
            ) { uiTextfield in
                // 使用AMathExpressionKeyboard / Use AMathExpressionKeyboard
                AMathExpressionKeyboard(uiTextfield, formatStyle)
            }

            // 显示当前值 / Display current value
            Text("输入值: \(doubleValue)")

            // 控制选项 / Control options
            /// 切换文本对齐方式 / Toggle text alignment
            Toggle("是否靠右对齐", isOn: $isRightAligned)
            
            /// 切换焦点状态 / Toggle focus state
            Toggle("输入框是否聚焦", isOn: $focused)

            // 手动更新按钮 / Manual update buttons
            /// 重置数值为0.0 / Reset value to 0.0
            Button("重置为0.0") {
                doubleValue = 0.0
            }
        }
    }
}

@available(iOS 16, *)
#Preview {
    ACustomFormattedTextFieldExample()
}
#endif
