import SwiftUI

/// 自定义键盘编辑状态结构体
/// 用于封装文本输入框的编辑状态，包括文本内容、选中文本范围和焦点状态
public struct ACustomKeyboardEditingStatus: Sendable, Hashable {
    /// 当前文本内容
    public var text: String = ""
    /// 选中文本的起始索引
    public var startIndex: String.Index
    /// 选中文本的结束索引
    public var endIndex: String.Index
    /// 文本框是否处于聚焦状态
    public var focused: Bool

    /// 选中的文本子字符串
    /// 当 startIndex 和 endIndex 有效时，返回选中的文本子字符串；否则返回空字符串
    public var selectedString: Substring {
        // 确保 startIndex 和 endIndex 在有效范围内
        let safeStartIndex = min(max(startIndex, text.startIndex), text.endIndex)
        let safeEndIndex = min(max(endIndex, text.startIndex), text.endIndex)
        // 确保 startIndex 不大于 endIndex
        let finalStartIndex = min(safeStartIndex, safeEndIndex)
        let finalEndIndex = max(safeStartIndex, safeEndIndex)

        return text[finalStartIndex ..< finalEndIndex]
    }

    /// 初始化编辑状态
    /// - Parameters:
    ///   - text: 初始文本内容
    ///   - focused: 是否初始处于聚焦状态，默认为false
    public init(_ text: String, focused: Bool = false) {
        self.text = text
        startIndex = text.startIndex
        endIndex = text.endIndex
        self.focused = focused
    }

    /// 删除操作（退格键功能）
    public mutating func backDelete() {
        // 确保 startIndex 和 endIndex 在有效范围内
        let safeStartIndex = min(max(startIndex, text.startIndex), text.endIndex)
        let safeEndIndex = min(max(endIndex, text.startIndex), text.endIndex)
        let finalStartIndex = min(safeStartIndex, safeEndIndex)
        let finalEndIndex = max(safeStartIndex, safeEndIndex)
        
        // 如果有选中文本，删除选中的文本
        if finalStartIndex < finalEndIndex {
            text.removeSubrange(finalStartIndex..<finalEndIndex)
            startIndex = finalStartIndex
            endIndex = finalStartIndex
        }
        // 如果没有选中文本且文本不为空，删除光标前的一个字符
        else if finalStartIndex > text.startIndex {
            let newIndex = text.index(before: finalStartIndex)
            text.remove(at: newIndex)
            startIndex = newIndex
            endIndex = newIndex
        }
    }

    /// 插入或替换文本
    /// - Parameter newText: 要插入或替换的文本
    public mutating func insertOrReplace(_ newText: String) {
        // 确保 startIndex 和 endIndex 在有效范围内
        let safeStartIndex = min(max(startIndex, text.startIndex), text.endIndex)
        let safeEndIndex = min(max(endIndex, text.startIndex), text.endIndex)
        let finalStartIndex = min(safeStartIndex, safeEndIndex)
        let finalEndIndex = max(safeStartIndex, safeEndIndex)
        
        // 替换或插入文本
        text.replaceSubrange(finalStartIndex..<finalEndIndex, with: newText)
        
        // 更新光标位置到插入文本之后
        let newIndex = text.index(finalStartIndex, offsetBy: newText.count)
        startIndex = newIndex
        endIndex = newIndex
    }
}
