import SwiftUI

public struct ACustomKeyboardEditingStatus: Sendable, Hashable {
    public var text: String = ""
    public var startIndex: String.Index
    public var endIndex: String.Index
    public var focused: Bool

    public init(string text: String, focused: Bool = false) {
        self.text = text
        startIndex = text.startIndex
        endIndex = text.endIndex
        self.focused = focused
    }
}
