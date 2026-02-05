import Foundation

#if canImport(UIKit) && !os(watchOS)
import UIKit

extension UITextField {
    var currentSelectedRange: NSRange? {
        guard let selectedTextRange else { return nil }
        let location = offset(from: beginningOfDocument, to: selectedTextRange.start)
        let length = offset(from: selectedTextRange.start, to: selectedTextRange.end)
        return NSRange(location: location, length: length)
    }

    func setSelectedRange(_ range: NSRange) {
        guard let start = position(from: beginningOfDocument, offset: range.location),
            let end = position(from: start, offset: range.length),
            let textRange = textRange(from: start, to: end)
        else { return }
        selectedTextRange = textRange
    }
}

#endif

extension NSRange {
    func clamped(to textCount: Int) -> NSRange {
        let safeLocation = max(0, min(location, textCount))
        let safeLength = max(0, min(length, textCount - safeLocation))
        return NSRange(location: safeLocation, length: safeLength)
    }
}
