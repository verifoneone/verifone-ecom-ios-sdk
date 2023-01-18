import UIKit

public enum TextFieldStyle {
    case plain
    case border(width: CGFloat)
}

public enum VFTextFieldValidationError: Error {
    case emptyText
    case invalidData
}

@IBDesignable
@objc(BaseTextField) public class BaseTextField: UITextField {
    public var style: TextFieldStyle = .plain {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            switch style {
            case .plain:
                return 0
            case .border(width: let width):
                return width
            }
        }
        set {
            switch newValue {
            case let value where value <= 0:
                style = .plain
            case let value:
                style = .border(width: value)
            }
        }
    }

    @IBInspectable var borderColor: UIColor? {
        didSet {
            updateBorder()
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            updateBorder()
        }
    }

    @IBInspectable var errorTextColor: UIColor? {
        didSet {
            updateTextColor()
        }
    }

    @IBInspectable var placeholderTextColor: UIColor? {
        didSet {
            updatePlaceholderTextColor()
        }
    }

    public override var placeholder: String? {
        didSet {
            updatePlaceholderTextColor()
        }
    }

    private var normalTextColor: UIColor?

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
        guard let errorTextColor = errorTextColor else {
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

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    init() {
        super.init(frame: CGRect.zero)
        initialize()
    }

    private func initialize() {
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        addTarget(self, action: #selector(didEndEditing), for: .editingDidEnd)
    }

    public var isValid: Bool {
        do {
            try validate()
            return true
        } catch {
            return false
        }
    }

    @objc func didBeginEditing() {

    }

    @objc func didEndEditing() {

    }

    @objc func textDidChange() {}

    @objc public func validate() throws {
        guard let text = self.text else {
            throw VFTextFieldValidationError.emptyText
        }
        if text.isEmpty {
            throw VFTextFieldValidationError.emptyText
        }
    }

    private var insets: UIEdgeInsets {
        let edgeInsets: UIEdgeInsets
        switch style {
        case .plain:
            edgeInsets = UIEdgeInsets.zero
        case .border(width: let width):
            edgeInsets = UIEdgeInsets(
                top: layoutMargins.top + width,
                left: layoutMargins.left + width,
                bottom: layoutMargins.bottom + width,
                right: layoutMargins.right + width
            )
        }

        return edgeInsets
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
        return bounds.inset(by: insets)
    }

    private func updateBorder() {
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor?.cgColor
    }
}
