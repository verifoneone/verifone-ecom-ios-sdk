//
//  Extensions.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 21.03.2023.
//

import UIKit

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

func format(with mask: String, hex: String) -> String {
    let hexStr = hex.replacingOccurrences(of: "[^0-9A-Za-z]", with: "", options: .regularExpression)
    var result = ""
    var index = hexStr.startIndex

    for ch in mask where index < hexStr.endIndex {
        if ch == "X" {
            result.append(hexStr[index])
            index = hexStr.index(after: index)
        } else {
            result.append(ch)
        }
    }

    return result
}

extension String {
    func getCurrency() -> String {
        return "\(self) \(UserDefaults.standard.getCurrency(fromKey: Keys.currency))"
    }
}
