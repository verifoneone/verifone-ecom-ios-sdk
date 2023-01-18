import Foundation
import UIKit

@IBDesignable
@objc(VFCVVTextField) public class CVVTextField: BaseTextField {
    private let validLengths = 3...4

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

    public override init(frame: CGRect) {
        super.init(frame: frame)
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
        guard range.length >= 0 else {
            return true
        }
        let maxLength = 4

        return maxLength >= (self.text?.count ?? 0) - range.length + string.count
    }
}
