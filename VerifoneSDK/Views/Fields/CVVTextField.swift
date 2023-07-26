import Foundation
import UIKit

@IBDesignable
public class CVVTextField: BaseTextField {
    private var validLengths = 3...4

    @available(iOS, unavailable)
    public override var delegate: UITextFieldDelegate? {
        get {
            return self
        }
        set {}
    }

    public override var keyboardType: UIKeyboardType {
        didSet {
            super.keyboardType = .numberPad
        }
    }

    public required init(frame: CGRect, onlyLengthCheck: Bool = false) {
        super.init(frame: frame)
        self.onlyLenthCheck = onlyLengthCheck
        initializeInstance()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInstance()
    }

    public override init() {
        super.init(frame: CGRect.zero)
        initializeInstance()
    }

    private func initializeInstance() {
        if onlyLenthCheck {
            validLengths = 7...8
        }

        super.keyboardType = .numberPad
        super.delegate = self
    }

    public override func validate() throws {
        try super.validate()

        guard let text = self.text else {
            throw VFTextFieldValidationError.emptyText
        }
        if !(validLengths ~= text.count) {
            throw VFTextFieldValidationError.invalidData
        }
    }
}

extension CVVTextField: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharacters.isSuperset(of: characterSet) {
            return false
        }
        guard range.length >= 0 else {
            return true
        }
        let maxLength = validLengths.upperBound

        return maxLength >= (self.text?.count ?? 0) - range.length + string.count
    }
}
