import SwiftUI
import UIKit

public struct ACustomKeyboardInputContext {
    /// 当前文本
    public let text: String
    /// 当前选区（location 为起始，length 为长度）
    public let selectedRange: NSRange
    /// 是否处于聚焦（第一响应者）状态
    public let isFocused: Bool

    /// 当前选中的文本（若无选区则为空）
    public var selectedText: Substring {
        let start = text.safeIndex(offset: selectedRange.location)
        let end = text.safeIndex(offset: selectedRange.location + selectedRange.length)
        return text[min(start, end)..<max(start, end)]
    }

    /// 当前选区（基于 String.Index），不可用时为 nil
    public var selectedTextRange: Range<String.Index>? {
        guard selectedRange.location != NSNotFound else { return nil }
        let start = text.safeIndex(offset: selectedRange.location)
        let end = text.safeIndex(offset: selectedRange.location + selectedRange.length)
        let lower = min(start, end)
        let upper = max(start, end)
        return lower <= upper ? lower..<upper : nil
    }

    /// 插入文本（等价于系统键盘输入）
    public let insertText: (String) -> Void
    /// 删除光标前字符（退格）
    public let deleteBackward: () -> Void
    /// 替换当前选区
    public let replaceSelection: (String) -> Void
    /// 按偏移移动光标（负数向左，正数向右）
    public let moveCursor: (Int) -> Void
    /// 直接设置选区
    public let setSelection: (NSRange) -> Void
    /// 直接设置文本（可用于清空、全量替换）
    public let setText: (String) -> Void
    /// 清空文本
    public let clear: () -> Void
    /// 全选
    public let selectAll: () -> Void
    /// 收起键盘
    public let dismissKeyboard: () -> Void

    public init(
        text: String,
        selectedRange: NSRange,
        isFocused: Bool,
        insertText: @escaping (String) -> Void,
        deleteBackward: @escaping () -> Void,
        replaceSelection: @escaping (String) -> Void,
        moveCursor: @escaping (Int) -> Void,
        setSelection: @escaping (NSRange) -> Void,
        setText: @escaping (String) -> Void,
        clear: @escaping () -> Void,
        selectAll: @escaping () -> Void,
        dismissKeyboard: @escaping () -> Void
    ) {
        self.text = text
        self.selectedRange = selectedRange
        self.isFocused = isFocused
        self.insertText = insertText
        self.deleteBackward = deleteBackward
        self.replaceSelection = replaceSelection
        self.moveCursor = moveCursor
        self.setSelection = setSelection
        self.setText = setText
        self.clear = clear
        self.selectAll = selectAll
        self.dismissKeyboard = dismissKeyboard
    }

    /// 直接从 UITextField 构建上下文（用于桥接原生 TextField）。
    @available(iOS 14.0, *)
    public init(_ textField: UITextField) {
        let text = textField.text ?? ""
        let selectedRange = textField.currentSelectedRange ?? NSRange(location: text.count, length: 0)
        self.init(
            text: text,
            selectedRange: selectedRange,
            isFocused: textField.isFirstResponder,
            insertText: { textField.insertText($0) },
            deleteBackward: { textField.deleteBackward() },
            replaceSelection: { input in
                guard let selected = textField.selectedTextRange else {
                    textField.insertText(input)
                    return
                }
                textField.replace(selected, withText: input)
            },
            moveCursor: { offset in
                let base = textField.currentSelectedRange ?? selectedRange
                let textCount = textField.text?.count ?? 0
                let newLocation = max(0, min(textCount, base.location + offset))
                textField.setSelectedRange(NSRange(location: newLocation, length: 0))
            },
            setSelection: { range in
                let textCount = textField.text?.count ?? 0
                let clamped = range.clamped(to: textCount)
                textField.setSelectedRange(clamped)
            },
            setText: { newText in
                textField.text = newText
            },
            clear: {
                textField.text = ""
            },
            selectAll: {
                let textCount = textField.text?.count ?? 0
                textField.setSelectedRange(NSRange(location: 0, length: textCount))
            },
            dismissKeyboard: {
                textField.resignFirstResponder()
            }
        )
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension ACustomKeyboardInputContext {
    static func make(textField: UITextField, bindString: Binding<String>? = nil) -> ACustomKeyboardInputContext {
        let text = textField.text ?? ""
        let selectedRange = textField.currentSelectedRange ?? NSRange(location: text.count, length: 0)
        let setString: (String) -> Void = { newText in
            textField.text = newText
            bindString?.wrappedValue = newText
        }

        return ACustomKeyboardInputContext(
            text: text,
            selectedRange: selectedRange,
            isFocused: textField.isFirstResponder,
            insertText: { textField.insertText($0) },
            deleteBackward: { textField.deleteBackward() },
            replaceSelection: { input in
                guard let selected = textField.selectedTextRange else {
                    textField.insertText(input)
                    return
                }
                textField.replace(selected, withText: input)
            },
            moveCursor: { offset in
                let base = textField.currentSelectedRange ?? selectedRange
                let textCount = textField.text?.count ?? 0
                let newLocation = max(0, min(textCount, base.location + offset))
                textField.setSelectedRange(NSRange(location: newLocation, length: 0))
            },
            setSelection: { range in
                let textCount = textField.text?.count ?? 0
                let clamped = range.clamped(to: textCount)
                textField.setSelectedRange(clamped)
            },
            setText: { newText in
                setString(newText)
            },
            clear: {
                setString("")
            },
            selectAll: {
                let textCount = textField.text?.count ?? 0
                textField.setSelectedRange(NSRange(location: 0, length: textCount))
            },
            dismissKeyboard: {
                textField.resignFirstResponder()
            }
        )
    }
}

private extension String {
    func safeIndex(offset: Int) -> String.Index {
        let safeOffset = max(0, min(offset, count))
        return index(startIndex, offsetBy: safeOffset, limitedBy: endIndex) ?? endIndex
    }
}
