import Foundation

/// 支持以下语言：
/// de, en, es, fr, it, ja, ko, pt, ru, th, zh-Hans, zh-Hant
enum I18n {
    static let view = NSLocalizedString("edit.button.short", bundle: .module, comment: "The text shown on the edit button")
    static let edit = NSLocalizedString("view.button.short", bundle: .module, comment: "The text shown on the view button")
}
