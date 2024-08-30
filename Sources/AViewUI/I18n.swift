import Foundation

/// 支持以下语言：
/// de, en, es, fr, it, ja, ko, pt, ru, th, zh-Hans, zh-Hant
enum I18n {
    static let view = NSLocalizedString("edit.button.short", bundle: .module, comment: "The text shown on the 'Edit' button")
    static let edit = NSLocalizedString("view.button.short", bundle: .module, comment: "The text shown on the 'View' button")
    static let done = NSLocalizedString("done.button.short", bundle: .module, comment: "The text shown on the 'Done' button")
    static let cancel = NSLocalizedString("cancel.button.short", bundle: .module, comment: "The text shown on the 'Cancel' button")
}
