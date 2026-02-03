import UIKit

#if os(iOS)
/// UITextField subclass that reliably emits text change callbacks for custom keyboards.
@available(iOS 14, *)
public final class ACustomKeyboardTextField: UITextField {
    public var onTextChange: ((String, UITextField) -> Void)?
    /// 固定一个高度为 0 的 inputAccessoryView，避免系统二次聚焦时插入圆角工具条
    private let fixedAccessoryView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: 0).isActive = true
        return view
    }()

    public override var inputAccessoryView: UIView? {
        get { fixedAccessoryView }
        set { /* ignore */ }
    }

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
