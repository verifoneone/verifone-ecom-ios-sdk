//
//  Extensions.swift
//  Verifone
//
//  Created by Oraz Atakishiyev on 20.08.2021.
//

import UIKit

extension Optional where Wrapped == String {
    public var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}

extension Calendar {
    /// Calendar used in the Credit Card information which is Gregorian Calendar
    public static let creditCardInformationCalendar = Calendar(identifier: .gregorian)
    /// Range contains the valid range of the expiration month value
    public static let validExpirationMonthRange: Range<Int> = Calendar.creditCardInformationCalendar.maximumRange(of: .month)!
}

extension NSCalendar {
    @objc(creditCardInformationCalendar) public static var __creditCardInformationCalendar: Calendar {
        return Calendar.creditCardInformationCalendar
    }
}

extension ControlState: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension CreditCardViewController {
    func updateInputAccessoryViewWithFirstResponder(_ firstResponder: BaseTextField) {
        guard cardFormInputFields.contains(firstResponder) else { return }
        
        currentEditingTextField = firstResponder
        gotoPreviousFieldBarButtonItem.isEnabled = firstResponder !== cardFormInputFields.first
        gotoNextFieldBarButtonItem.isEnabled = firstResponder !== cardFormInputFields.last
    }
    
    func gotoPreviousField() {
        guard let currentTextField = currentEditingTextField, let index = cardFormInputFields.firstIndex(of: currentTextField) else {
            return
        }
        
        let prevIndex = index - 1
        guard prevIndex >= 0 else { return }
        cardFormInputFields[prevIndex].becomeFirstResponder()
    }
    
    func gotoNextField() {
        guard let currentTextField = currentEditingTextField, let index = cardFormInputFields.firstIndex(of: currentTextField) else {
            return
        }
        
        let nextIndex = index + 1
        guard nextIndex < cardFormInputFields.count else { return }
        cardFormInputFields[nextIndex].becomeFirstResponder()
    }
    
    func doneEditing() {
        view.endEditing(true)
    }
}

extension Array where Element: BaseTextField {
    func areFieldsValid() -> Bool {
        return self.reduce(into: true, { (valid, field) in
            return valid = valid && field.isValid
        })
    }
}

extension UIViewController {
  func alert(title: String, message: String = "") {
      DispatchQueue.main.async {
          let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
          let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
          alertController.addAction(OKAction)
          self.present(alertController, animated: true, completion: nil)
      }
  }
}
