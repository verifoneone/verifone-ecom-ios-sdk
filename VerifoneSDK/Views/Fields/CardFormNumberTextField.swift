import UIKit

@IBDesignable
@objc(VFCardFormNumberTextField) public class CardFormNumberTextField: BaseTextField {

    public var panNumber: PanNumber {
        return PanNumber(text ?? "")
    }
    
    public var cardBrand: String? {
        return CardValidator.getCardType(panNumber.panNumber)?.getName()
    }
    
    public override var selectedTextRange: UITextRange? {
        didSet {
            guard let selectedTextRange = self.selectedTextRange else {
                return
            }

            let kerningIndexes = IndexSet(panNumber.suggestedSpaceFormattedIndexes.map { $0 - 1 })

            let kerningKey = AttributedStringKey.kern
            if kerningIndexes.contains(self.offset(from: beginningOfDocument, to: selectedTextRange.start)) {
                typingAttributes?[kerningKey] = 5
            } else {
                typingAttributes?.removeValue(forKey: kerningKey)
            }
        }
    }
    
    @available(iOS, unavailable)
    public override var delegate: UITextFieldDelegate? {
        get {
            return self
        }
        set {}
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init() {
        super.init(frame: CGRect.zero)
        initialize()
    }
    
    private func initialize() {
        keyboardType = .numberPad
        super.delegate = self
        
        placeholder = placeholder
        
        textContentType = .creditCardNumber
    }

    public override func validate() throws {
        if !CardValidator.validateCardNumber(panNumber.panNumber) {
            throw VFTextFieldValidationError.invalidData
        }
    }
    
    public override func becomeFirstResponder() -> Bool {
        let spacingIndexes = panNumber.suggestedSpaceFormattedIndexes
        if let attributedText = attributedText, spacingIndexes.contains(attributedText.length) {
            let formattingAttributedText = NSMutableAttributedString(attributedString: attributedText)
            let range = NSRange(location: attributedText.length - 1, length: 1)
            formattingAttributedText.addAttribute(.kern, value: 5, range: range)
            self.attributedText = formattingAttributedText
        }

        defer {
            updateTypingAttributes()
        }

        return super.becomeFirstResponder()
    }
    
    public override func resignFirstResponder() -> Bool {
        let spacingIndexes = panNumber.suggestedSpaceFormattedIndexes
        if let attributedText = attributedText, spacingIndexes.contains(attributedText.length) {
            let formattingAttributedText = NSMutableAttributedString(attributedString: attributedText)
            let range = NSRange(location: attributedText.length - 1, length: 1)
            formattingAttributedText.removeAttribute(.kern, range: range)
            self.attributedText = formattingAttributedText
        }

        return super.resignFirstResponder()
    }
    
    public override func paste(_ sender: Any?) {
        let pasteboard = UIPasteboard.general

        guard let copiedText = pasteboard.string, let selectedTextRange = selectedTextRange else {
            return
        }

        let selectedTextLength = self.offset(from: selectedTextRange.start, to: selectedTextRange.end)
        let pan = copiedText.replacingOccurrences(
            of: "[^0-9]",
            with: "",
            options: .regularExpression,
            range: nil)

        let panLength = (self.panNumber.brand?.cardLength.upperBound ?? 16) - (self.text?.count ?? 0) + selectedTextLength
        let maxPastingPANLength = min(pan.count, panLength)
        guard maxPastingPANLength > 0 else {
            return
        }
        replace(selectedTextRange, withText: String(pan[pan.startIndex..<pan.index(pan.startIndex, offsetBy: maxPastingPANLength)]))

        guard let attributedText = attributedText else {
            return
        }

        let formattingAttributedText = NSMutableAttributedString(attributedString: attributedText)
        let kerningIndexes = IndexSet(PanNumber.suggestedSpaceFormattedIndexesForPANPrefix(attributedText.string).map { $0 - 1 })

        let range = NSRange(location: 0, length: formattingAttributedText.length)
        formattingAttributedText.removeAttribute(.kern, range: range)
        kerningIndexes[kerningIndexes.indexRange(in: 0..<attributedText.length)].forEach {
            formattingAttributedText.addAttribute(AttributedStringKey.kern, value: 5, range: NSRange(location: $0, length: 1))
        }
        let previousSelectedTextRange = self.selectedTextRange
        self.attributedText = formattingAttributedText
        self.selectedTextRange = previousSelectedTextRange
    }
    
    override func textDidChange() {
        super.textDidChange()

        guard let selectedTextRange = self.selectedTextRange else {
            return
        }

        updateTypingAttributes()

        if compare(selectedTextRange.start, to: endOfDocument) == ComparisonResult.orderedAscending, let attributedText = attributedText {
            let formattingAttributedText = NSMutableAttributedString(attributedString: attributedText)
            let formattingStartIndex = self.offset(from: beginningOfDocument,
                                                   to: self.position(from: selectedTextRange.start, offset: -1) ?? selectedTextRange.start)

            let kerningIndexes = IndexSet(panNumber.suggestedSpaceFormattedIndexes.map { $0 - 1 })

            let range = NSRange(location: formattingStartIndex, length: formattingAttributedText.length - formattingStartIndex)
            formattingAttributedText.removeAttribute(.kern, range: range)
            kerningIndexes[kerningIndexes.indexRange(in: formattingStartIndex..<formattingAttributedText.length)].forEach {
                formattingAttributedText.addAttribute(.kern, value: 5, range: NSRange(location: $0, length: 1))
            }

            self.attributedText = formattingAttributedText
            self.selectedTextRange = selectedTextRange
        }
    }
    
    private func updateTypingAttributes() {
        guard let selectedTextRange = self.selectedTextRange else {
            return
        }
        let kerningIndexes = IndexSet(panNumber.suggestedSpaceFormattedIndexes.map { $0 - 1 })

        let kerningKey = AttributedStringKey.kern
        if kerningIndexes.contains(self.offset(from: beginningOfDocument, to: selectedTextRange.start)) {
            typingAttributes?[kerningKey] = 5
        } else {
            typingAttributes?.removeValue(forKey: kerningKey)
        }

        if kerningIndexes.contains(self.offset(from: beginningOfDocument, to: selectedTextRange.start)) {
            typingAttributes?[AttributedStringKey.kern] = 5
        } else {
            typingAttributes?.removeValue(forKey: AttributedStringKey.kern)
        }
    }
}

extension CardFormNumberTextField: UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = CardValidator.getCardType(text!)?.cardLength.upperBound ?? 16
        
        return maxLength >= (text?.count ?? 0) - range.length + string.count
    }
}

