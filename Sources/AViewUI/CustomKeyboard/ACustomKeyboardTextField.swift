import UIKit

#if os(iOS)
/// UITextField subclass that reliably emits text change callbacks for custom keyboards.
@available(iOS 14, *)
public final class ACustomKeyboardTextField: UITextField {
    public var onTextChange: ((String, UITextField) -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addTarget(self, action: #selector(handleEditingChanged), for: .editingChanged)
    }

    @objc private func handleEditingChanged() {
        notifyTextChange()
    }

    private func notifyTextChange() {
        onTextChange?(text ?? "", self)
    }

    public override func insertText(_ text: String) {
        super.insertText(text)
        notifyTextChange()
    }

    public override func deleteBackward() {
        super.deleteBackward()
        notifyTextChange()
    }

    public override func cut(_ sender: Any?) {
        super.cut(sender)
        notifyTextChange()
    }

    public override func paste(_ sender: Any?) {
        super.paste(sender)
        notifyTextChange()
    }

    public override func replace(_ range: UITextRange, withText text: String) {
        super.replace(range, withText: text)
        notifyTextChange()
    }
}
#endif
