import SwiftUI

#if os(iOS)
/// 自定义文本字段组件
/// Custom text field component
///
/// 一个支持自定义键盘的通用文本输入组件，使用UITextField作为底层实现
/// A generic text input component that supports custom keyboards, using UITextField as the underlying implementation
///
/// ## 功能特性 / Features
/// - 支持自定义键盘视图 / Supports custom keyboard views
/// - 支持文本选择管理 / Supports text selection management
/// - 支持焦点状态管理 / Supports focus state management
/// - 支持文本对齐设置 / Supports text alignment settings
/// - 支持外部编辑状态管理 / Supports external editing state management
///
/// ## 使用示例 / Usage Example
/// ```swift
/// @State private var text = "Hello"
/// 
/// ACustomUITextField(
///     text: $text
/// ) { uiTextField in
///     AMathExpressionKeyboard(uiTextField, formatStyle)
/// }
/// ```
///
/// ## 参数说明 / Parameter Description
/// - KeyboardView: 键盘视图类型，必须是View / The keyboard view type, must be a View
///
/// ## 注意事项 / Notes
/// - 仅支持iOS 14.0及以上版本 / Only supports iOS 14.0 and above
/// - 与ACustomFormattedTextField不同，此组件不进行值格式化 / Unlike ACustomFormattedTextField, this component doesn't perform value formatting
@available(iOS 14, *)
public struct ACustomUITextField<KeyboardView: View>: UIViewRepresentable {
    
    /// 绑定的文本 / Bound text
    @Binding var text: String
    
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

    /// 键盘视图构建器 / Keyboard view builder
    /// - Parameters:
    ///   - textField: 关联的UITextField实例 / Associated UITextField instance
    /// - Returns: 键盘视图 / Keyboard view
    var keyboardViewBuilder: (UITextField) -> KeyboardView

    /// 显式定义初始化函数
    /// Explicit initialization function
    ///
    /// ## 使用场景 / Usage Scenario
    /// 当需要完全控制编辑状态时使用此初始化方法
    /// Use this initialization method when you need full control over editing state
    ///
    /// ## 参数说明 / Parameters
    /// - text: 绑定的文本 / Bound text
    /// - startIndex: 文本选择起始索引 / Text selection start index
    /// - endIndex: 文本选择结束索引 / Text selection end index
    /// - focused: 焦点状态 / Focus state
    /// - keyboardViewBuilder: 键盘视图构建器 / Keyboard view builder
    /// - makeTextfield: 文本框创建函数 / Text field creation function
    public init(
        text: Binding<String>,
        startIndex: Binding<String.Index>,
        endIndex: Binding<String.Index>,
        focused: Binding<Bool>,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView,
        makeTextfield: @escaping () -> UITextField = { UITextField() }
    ) {
        self._text = text
        self._startIndex = startIndex
        self._endIndex = endIndex
        self._focused = focused
        self.keyboardViewBuilder = keyboardViewBuilder
        self.makeTextfield = makeTextfield
    }
    
    /// 便捷初始化方法，无需手动管理编辑状态
    /// Convenient initialization method, no need to manually manage editing state
    ///
    /// ## 使用场景 / Usage Scenario
    /// 当不需要手动管理编辑状态时使用此初始化方法，组件会自动创建和管理内部状态
    /// Use this initialization method when you don't need to manually manage editing state, component will automatically create and manage internal state
    ///
    /// ## 参数说明 / Parameters
    /// - text: 绑定的文本 / Bound text
    /// - focused: 焦点状态 / Focus state
    /// - keyboardViewBuilder: 键盘视图构建器 / Keyboard view builder
    /// - makeTextfield: 文本框创建函数 / Text field creation function
    public init(
        text: Binding<String>,
        focused: Binding<Bool>,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView,
        makeTextfield: @escaping () -> UITextField = { UITextField() }
    ) {
        self._text = text
        // 创建可变的状态存储 / Create mutable state storage
        var startIndex = text.wrappedValue.startIndex
        var endIndex = text.wrappedValue.endIndex
        
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
        
        self._focused = focused
        self.keyboardViewBuilder = keyboardViewBuilder
        self.makeTextfield = makeTextfield
    }
    
    /// 最简初始化方法，仅需提供文本绑定
    /// Simplest initialization method, only need to provide text binding
    ///
    /// ## 使用场景 / Usage Scenario
    /// 当只需要基本的文本输入功能时使用此初始化方法
    /// Use this initialization method when you only need basic text input functionality
    ///
    /// ## 参数说明 / Parameters
    /// - text: 绑定的文本 / Bound text
    /// - keyboardViewBuilder: 键盘视图构建器 / Keyboard view builder
    public init(
        text: Binding<String>,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView
    ) {
        self._text = text
        // 创建可变的状态存储 / Create mutable state storage
        var startIndex = text.wrappedValue.startIndex
        var endIndex = text.wrappedValue.endIndex
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
        
        self.keyboardViewBuilder = keyboardViewBuilder
        self.makeTextfield = { UITextField() }
    }

    /// 新增初始化函数，包含isRightAligned参数
    /// Initialization function with isRightAligned parameter
    ///
    /// ## 使用场景 / Usage Scenario
    /// 当需要设置文本对齐方式时使用此初始化方法
    /// Use this initialization method when you need to set text alignment
    ///
    /// ## 参数说明 / Parameters
    /// - text: 绑定的文本 / Bound text
    /// - startIndex: 文本选择起始索引 / Text selection start index
    /// - endIndex: 文本选择结束索引 / Text selection end index
    /// - focused: 焦点状态 / Focus state
    /// - isRightAligned: 是否右对齐 / Whether right aligned
    /// - keyboardViewBuilder: 键盘视图构建器 / Keyboard view builder
    public init(
        text: Binding<String>,
        startIndex: Binding<String.Index>,
        endIndex: Binding<String.Index>,
        focused: Binding<Bool>,
        isRightAligned: Bool,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView
    ) {
        self.init(
            text: text,
            startIndex: startIndex,
            endIndex: endIndex,
            focused: focused,
            keyboardViewBuilder: keyboardViewBuilder
        ) {
            let textField = UITextField()
            textField.textAlignment = isRightAligned ? .right : .left
            return textField
        }
        self.isRightAligned = isRightAligned  // 存储isRightAligned的值 / Store isRightAligned value
    }

    /// 新增初始化函数，接受Binding<ACustomKeyboardEditingStatus>参数
    /// Initialization function accepting Binding<ACustomKeyboardEditingStatus> parameter
    ///
    /// ## 使用场景 / Usage Scenario
    /// 当需要在外部管理编辑状态时使用此初始化方法，适用于多个组件共享编辑状态
    /// Use this initialization method when you need to manage editing state externally, suitable for multiple components sharing editing state
    ///
    /// ## 参数说明 / Parameters
    /// - editingStatus: 外部编辑状态 / External editing status
    /// - keyboardViewBuilder: 键盘视图构建器 / Keyboard view builder
    /// - makeTextfield: 文本框创建函数 / Text field creation function
    public init(
        editingStatus: Binding<ACustomKeyboardEditingStatus>,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView,
        makeTextfield: @escaping () -> UITextField = { UITextField() }
    ) {
        self._text = Binding {
            editingStatus.wrappedValue.text
        } set: {
            editingStatus.text.wrappedValue = $0
        }
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
        self.keyboardViewBuilder = keyboardViewBuilder
        self.makeTextfield = makeTextfield
    }

    /// 新增初始化函数，接受editingStatus和isRightAligned参数
    /// Initialization function accepting editingStatus and isRightAligned parameters
    ///
    /// ## 使用场景 / Usage Scenario
    /// 当需要在外部管理编辑状态并设置文本对齐方式时使用此初始化方法
    /// Use this initialization method when you need to manage editing state externally and set text alignment
    ///
    /// ## 参数说明 / Parameters
    /// - editingStatus: 外部编辑状态 / External editing status
    /// - isRightAligned: 是否右对齐 / Whether right aligned
    /// - keyboardViewBuilder: 键盘视图构建器 / Keyboard view builder
    public init(
        editingStatus: Binding<ACustomKeyboardEditingStatus>,
        isRightAligned: Bool,
        @ViewBuilder keyboardViewBuilder: @escaping (UITextField) -> KeyboardView
    ) {
        self.init(
            editingStatus: editingStatus,
            keyboardViewBuilder: keyboardViewBuilder
        ) {
            let textField = UITextField()
            textField.textAlignment = isRightAligned ? .right : .left
            return textField
        }
        self.isRightAligned = isRightAligned  // 存储isRightAligned的值 / Store isRightAligned value
    }

    /// 创建UITextField视图 / Create UITextField view
    /// - Parameter context: UIViewRepresentable上下文 / UIViewRepresentable context
    /// - Returns: 配置好的UITextField实例 / Configured UITextField instance
    public func makeUIView(context: Context) -> UITextField {
        // 使用makeTextfield函数创建文本框 / Create text field using makeTextfield function
        let textField = makeTextfield()  // 使用makeTextfield函数创建文本框
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
        // 设置初始焦点状态 / Set initial focus state
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
        // 仅在文本实际变化时更新，避免不必要的刷新
        // Only update when text actually changes, avoiding unnecessary refreshes
        if uiView.text != text {
            uiView.text = text
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
        // 更新文本对齐方式（如果isRightAligned有值）/ Update text alignment (if isRightAligned has value)
        if let isRightAligned = isRightAligned {
            uiView.textAlignment = isRightAligned ? .right : .left
        }
        // 强制更新键盘视图，确保响应绑定变化 / Force update keyboard view, ensuring binding changes are responded to
        uiView.inputView = createKeyboardView(textField: uiView)
    }

    /// 添加新方法用于直接更新键盘视图
    /// Add new method for directly updating keyboard view
    /// - Parameter textField: 要更新键盘的文本框 / Text field to update keyboard for
    public func updateKeyboardView(_ textField: UITextField) {
        // 重新创建键盘视图 / Recreate keyboard view
        textField.inputView = createKeyboardView(textField: textField)
    }

    /// 添加一个方法来监听绑定值变化并更新键盘视图
    /// Add a method to listen for binding value changes and update keyboard view
    public func updateBindings() {
        // 当绑定值变化时，我们需要更新键盘视图
        // When binding values change, we need to update the keyboard view
        if let textField = UIApplication.shared.windows.first?.rootViewController?.view.subviews
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
        startIndex = text.index(text.startIndex, offsetBy: min(startOffset, text.count))
        endIndex = text.index(text.startIndex, offsetBy: min(endOffset, text.count))

        // 创建一个包装视图，用于监听绑定值变化
        // Create a wrapper view for monitoring binding value changes
        let keyboardView = KeyboardWrapperView(
            text: $text,
            textField: textField,
            startIndex: $startIndex,
            endIndex: $endIndex,
            focused: $focused,
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
        public var parent: ACustomUITextField
        
        /// 弱引用的文本框 / Weak reference to text field
        weak var textField: UITextField?
        
        /// 记录上一次已知的文本，用于判断文本是否发生变化
        /// Track last known text to detect changes
        private var lastKnownText: String = ""

        /// 初始化协调器 / Initialize coordinator
        /// - Parameter parent: 父组件 / Parent component
        public init(parent: ACustomUITextField) {
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
        private func syncTextIfNeeded(from textField: UITextField) {
            let currentText = textField.text ?? ""
            guard currentText != lastKnownText else { return }
            lastKnownText = currentText
            if parent.text != currentText {
                parent.text = currentText
            }
        }

        /// 监听文本变化事件 / Observe editing changed events
        @objc public func handleEditingChanged(_ textField: UITextField) {
            syncTextIfNeeded(from: textField)
        }

        /// 当选择范围变化时更新键盘 / Update keyboard when selection range changes
        /// - Parameter textField: 文本框 / Text field
        public func textFieldDidChangeSelection(_ textField: UITextField) {
            syncTextIfNeeded(from: textField)
            parent.updateKeyboardView(textField)
        }

        /// 处理文本变化 / Handle text changes
        /// - Parameters:
        ///   - textField: 文本框 / Text field
        ///   - range: 要修改的范围 / Range to modify
        ///   - string: 替换字符串 / Replacement string
        /// - Returns: 是否允许修改 / Whether modification is allowed
        public func textField(
            _ textField: UITextField, shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            // 更新绑定的文本值 / Update bound text value
            if let currentText = textField.text as NSString? {
                let updatedText = currentText.replacingCharacters(in: range, with: string)
                parent.text = updatedText
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

        /// 文本字段结束编辑 / Text field ended editing
        /// - Parameter textField: 文本框 / Text field
        public func textFieldDidEndEditing(_ textField: UITextField) {
            parent.focused = false
        }
    }
}

// 添加一个包装视图，用于监听绑定值变化
/// Add a wrapper view for monitoring binding value changes
///
/// ## 参数说明 / Parameters
/// - KeyboardView: 键盘视图类型 / Keyboard view type
@available(iOS 14, *)
private struct KeyboardWrapperView<KeyboardView: View>: View {
    /// 绑定的文本 / Bound text
    @Binding var text: String
    
    /// 文本框 / Text field
    let textField: UITextField
    
    /// 文本选择起始索引 / Text selection start index
    @Binding var startIndex: String.Index
    
    /// 文本选择结束索引 / Text selection end index
    @Binding var endIndex: String.Index
    
    /// 焦点状态 / Focus state
    @Binding var focused: Bool
    
    /// 构建器函数 / Builder function
    /// - Parameter textField: 文本框 / Text field
    /// - Returns: 键盘视图 / Keyboard view
    let builder: (UITextField) -> KeyboardView

    /// 视图主体 / View body
    /// - Returns: 构建的键盘视图 / Built keyboard view
    var body: some View {
        return builder(textField)
    }
}

// 更新Example结构体以使用ACustomKeyboardEditingStatus
@available(iOS 14, *)
private struct Example: View {
    // 创建两个编辑状态实例
    @State private var editingStatus1 = ACustomKeyboardEditingStatus("123+15")
    @State private var editingStatus2 = ACustomKeyboardEditingStatus("456-78")
    @State private var isRightAligned = false  // 保留此状态变量来控制对齐方式

    var body: some View {
        List {
            ACustomUITextField(
                editingStatus: $editingStatus1
            ) { uiTextfield in
                if #available(iOS 16, *) {
                    AMathExpressionKeyboard(uiTextfield, .precision(.fractionLength(0...3)))
                        .frame(height: 270)
                } else {
                    // Fallback on earlier versions
                }
            }
            ACustomUITextField(
                editingStatus: $editingStatus2,
                isRightAligned: isRightAligned
            ) { uiTextfield in
                if #available(iOS 16, *) {
                    AMathExpressionKeyboard(uiTextfield, .precision(.fractionLength(0...3)))
                        .frame(height: 270)
                } else {
                    // Fallback on earlier versions
                }
            }
            Text("第一个输入框已选文字: " + editingStatus1.selectedString)
            Text("第二个输入框已选文字: " + editingStatus2.selectedString)
            Toggle("第一个输入框是否聚焦", isOn: $editingStatus1.focused)
            Toggle("第二个输入框是否聚焦", isOn: $editingStatus2.focused)
            Toggle("是否靠右对齐", isOn: $isRightAligned)
            Button("删除") {
                editingStatus1.backDelete()
            }
            Button("键入123") {
                editingStatus1.insertOrReplace("123")
            }
        }
    }
}

@available(iOS 14, *)
#Preview {
    Example()
}

#endif
