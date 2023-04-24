import UIKit

public enum VFTextFieldValidationError: Error {
    case emptyText
    case invalidData
}

@IBDesignable
public class BaseTextField: UITextField {

    private var normalTextColor: UIColor?

    var padding: UIEdgeInsets!
    var borderWidth: CGFloat = 0.0

    public override var placeholder: String? {
        didSet {
            updatePlaceholderTextColor()
        }
    }

    var placeholderTextColor: UIColor? {
        didSet {
            updatePlaceholderTextColor()
        }
    }

    var errorHintColor: UIColor? {
        didSet {
            updateTextColor()
        }
    }

    var borderColor: UIColor? {
        didSet {
            updateBorder()
        }
    }

    var cornerRadius: CGFloat = 0 {
        didSet {
            updateBorder()
        }
    }

    public override var text: String? {
        didSet {
            updateTextColor()
        }
    }

    public override var textColor: UIColor? {
        get {
            return normalTextColor
        }
        set {
            normalTextColor = newValue
            updateTextColor()
        }
    }

    private func updateTextColor() {
        guard let errorTextColor = errorHintColor else {
            super.textColor = normalTextColor ?? .black
            return
        }
        super.textColor = isValid || isFirstResponder ? (normalTextColor ?? .black) : errorTextColor
    }

    func updatePlaceholderTextColor() {
        if let attributedPlaceholder = attributedPlaceholder, let placeholderColor = self.placeholderTextColor {
            let formattingAttributedText = NSMutableAttributedString(attributedString: attributedPlaceholder)

            let formattingPlaceholderString = formattingAttributedText.string
            let range = NSRange(formattingPlaceholderString.startIndex..<formattingPlaceholderString.endIndex,
                                in: formattingPlaceholderString)
            formattingAttributedText.addAttribute(.foregroundColor, value: placeholderColor, range: range)
            super.attributedPlaceholder = formattingAttributedText.copy() as? NSAttributedString
        }
    }

    public var isValid: Bool {
        do {
            try validate()
            return true
        } catch {
            return false
        }
    }

    // MARK: - Initializers
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    init() {
        super.init(frame: CGRect.zero)
        configure()
    }

    private func configure() {
        padding = UIEdgeInsets(
            top: layoutMargins.top,
            left: layoutMargins.left,
            bottom: layoutMargins.bottom,
            right: layoutMargins.right
        )
        addTarget(self,
                  action: #selector(self.textDidChange),
                  for: UIControl.Event.editingChanged)
        addTarget(self,
                  action: #selector(self.didBeginEditing),
                  for: UIControl.Event.editingDidBegin)
        addTarget(self,
                  action: #selector(self.didEndEditing),
                  for: UIControl.Event.editingDidEnd)
    }

    @objc func didBeginEditing() {}

    @objc func didEndEditing() {}

    @objc func textDidChange() {}

    @objc public func validate() throws {
        guard let text = self.text else {
            throw VFTextFieldValidationError.emptyText
        }
        if text.isEmpty {
            throw VFTextFieldValidationError.emptyText
        }
    }

    public override func borderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: textAreaViewRect(forBounds: bounds))
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: textAreaViewRect(forBounds: bounds))
    }

    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return super.clearButtonRect(forBounds: textAreaViewRect(forBounds: bounds))
    }

    public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.rightViewRect(forBounds: textAreaViewRect(forBounds: bounds))
    }

    public override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.leftViewRect(forBounds: textAreaViewRect(forBounds: bounds))
    }

    func textAreaViewRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    private func updateBorder() {
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor?.cgColor
    }
}
