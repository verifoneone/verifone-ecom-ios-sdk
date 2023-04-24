import Foundation
import UIKit

@IBDesignable
public class CardFormExpiryDateTextField: BaseTextField {

    public private(set) var selectedMonth: Int? {
        didSet {
            guard let selectedMonth = self.selectedMonth else {
                return
            }
            if !(Calendar.validExpirationMonthRange ~= selectedMonth) {
                self.selectedMonth = nil
            }
        }
    }

    public private(set) var selectedYear: Int?

    public override var keyboardType: UIKeyboardType {
        didSet {
            super.keyboardType = .numberPad
        }
    }

    @available(iOS, unavailable)
    public override var delegate: UITextFieldDelegate? {
        get {
            return self
        }
        set {}
    }

    public override init() {
        super.init(frame: CGRect.zero)
        initializeInstance()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeInstance()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInstance()
    }

    private func initializeInstance() {
        super.delegate = self
    }

    public override func validate() throws {
        try super.validate()

        guard let year = self.selectedYear, let month = self.selectedMonth else {
            throw VFTextFieldValidationError.invalidData
        }

        let now = Date()
        let calendar = Calendar.creditCardInformationCalendar
        let thisMonth = calendar.component(.month, from: now)
        let thisYear = calendar.component(.year, from: now)

        if (year == thisYear && thisMonth > month) || thisYear > year {
            throw VFTextFieldValidationError.invalidData
        }
    }

    private var isDeletingDateSeparator = false

    override func textDidChange() {
        super.textDidChange()
        formatExpiryDate(self)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }
}

extension CardFormExpiryDateTextField: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }

    func formatExpiryDate(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let dividerString = "/"
        var str = text.replacingOccurrences(of: dividerString, with: "", options: .literal)
        let month = Int(str)

        if str.count == 1 && month != nil && month! > 1 {
          let formattedMonth = String(format: "%02d", month!)
          str = formattedMonth
        }

        if str.count >= 3 {
            let expiryMonth = str[Range(0...1)]
            var expiryYear: String
            if str.count == 3 {
                expiryYear = str[2]
            } else {
                expiryYear = str[Range(2...3)]
            }
            guard let expiryMonthDigits = Int(expiryMonth) else { return }
            guard let expiryYearDigits = Int(expiryYear) else { return }
            selectedMonth = expiryMonthDigits
            selectedYear = 2000 + expiryYearDigits
            textField.text = expiryMonth + dividerString + expiryYear
        } else {
            textField.text = str
        }
    }
}
