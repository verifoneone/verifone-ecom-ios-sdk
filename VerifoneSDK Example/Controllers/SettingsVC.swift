//
//  SettingsVC.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 08.12.2021.
//

import UIKit
import VerifoneSDK

fileprivate var defaultValues = ["FFFFFF", "FFFFFF", "000000", "364049", "007AFF", "E4E7ED", "FFFFFF", "000000"]

class SettingsVC: UITableViewController {
    
    @IBOutlet var formFields: [UITextField]!
    @IBOutlet weak var textfieldCardFormbackgroundColor: UITextField!
    @IBOutlet weak var textfieldCardTextFieldBackColor: UITextField!
    @IBOutlet weak var textFieldCardTextfieldTextColor: UITextField!
    @IBOutlet weak var textfieldCardLabelColor: UITextField!
    @IBOutlet weak var textfieldPayButtonBackColor: UITextField!
    @IBOutlet weak var textfieldPayButtonDisabledBackColor: UITextField!
    @IBOutlet weak var textfieldPayButtonTextColor: UITextField!
    @IBOutlet weak var textfieldCardTitleColor: UITextField!
    
    @IBOutlet weak var storeValues: UIBarButtonItem!
    @IBOutlet weak var switchCardSave: UISwitch!
    @IBOutlet weak var deleteReuseTokenBtn: UIButton!

    @IBOutlet weak var currentLangName: UILabel!
    @IBOutlet weak var fontLabel: UILabel!
    
    let defaults = UserDefaults.standard
    fileprivate var saveVal: Bool = false
    fileprivate var fontFamilyName: String?
    fileprivate var selectLanguageCode: String?
    @IBOutlet weak var paymentMethod1: UITableViewCell!
    @IBOutlet weak var paymentMethodCell2: UITableViewCell!
    @IBOutlet weak var applepayCell: UITableViewCell!
    @IBOutlet weak var klarnaCell: UITableViewCell!
    
    var allowedPaymentMethods: Set<VerifoneSDKPaymentTypeValue> = [] {
        willSet {
            guard isViewLoaded else {
                return
            }
            let removingPaymentMethods = allowedPaymentMethods.subtracting(newValue)
            removingPaymentMethods.compactMap(self.cell(for:)).forEach {
                $0.accessoryType = .none
            }
        }
        didSet {
            guard isViewLoaded else {
                return
            }
            let addingPaymentMethods = allowedPaymentMethods.subtracting(oldValue)
            addingPaymentMethods.compactMap(self.cell(for:)).forEach {
                $0.accessoryType = .checkmark
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reset()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Settings"
    }
    
    func setup() {
        self.currentLangName.text = MerchantAppConfig.shared.getCurrentLangName()
        self.fontLabel.text = "Font: \(MerchantAppConfig.shared.getFontName())"
        storeValues.isEnabled = false
        formFields.forEach { textfield in
            textfield.tintColor = UIColor.lightGray
            textfield.setIcon(UIImage(named: "edit")!)
            textfield.leftView?.tintColor = UIColor.lightGray
            textfield.layer.cornerRadius = 8
            textfield.layer.borderColor = UIColorFromRGB(0xE4E4E6).cgColor
            textfield.layer.borderWidth = 0.5
            
            if let value = defaults.string(forKey: "textfield_\(textfield.tag)") {
                textfield.text = format(with: "#XXXXXX", phone: value)
            } else {
                defaults.set(textfield.text!.replacingOccurrences(of: "#", with: ""), forKey: "textfield_\(textfield.tag)")
            }
            
            if let hex = Int(textfield.text!.replacingOccurrences(of: "#", with: ""), radix: 16) {
                textfield.setRightIcon(UIColorFromRGB(hex))
            }
        }
        
        if let value = defaults.string(forKey: "switch_\(switchCardSave.tag)") {
            if (value == "checked") {
                switchCardSave.isOn = true
            } else {
                switchCardSave.isOn = false
            }
        } else {
            defaults.set("checked", forKey: "switch_\(switchCardSave.tag)")
        }
        
        // Enable button if we have saved token(card details)
        do {
            let _ = try defaults.getObject(forKey: "reuseToken", castTo: ResponseReuseToken.self)
            deleteReuseTokenBtn.isEnabled = true
        } catch {
            
        }
        
        // Load saved payment methods. if no saved payment methods then load all.
        if let arr = defaults.stringArray(forKey: "paymentMethods") {
            arr.forEach { element in
                allowedPaymentMethods.insert(VerifoneSDKPaymentTypeValue(element))
            }
        } else {
            allowedPaymentMethods = Set(MerchantAppConfig.shared.allowedPaymentMethods)
        }
        
        allowedPaymentMethods.compactMap(self.cell(for:)).forEach {
            $0.accessoryType = .checkmark
        }
    }
    
    @IBAction func enableCardSave(_ sender: UISwitch) {
        storeValues.isEnabled = true
        if sender.isOn {
            defaults.set("checked", forKey: "switch_\(switchCardSave.tag)")
        } else {
            defaults.set("unchecked", forKey: "switch_\(switchCardSave.tag)")
        }
    }
    
    func reset() {
        // if closed without saving
        if (!saveVal) {
            for (index, item) in defaultValues.enumerated() {
                defaults.set(item, forKey: "textfield_\(100+index)")
            }
        }
    }
    
    @IBAction func saveValues() {
        storeValues.isEnabled = false
        saveVal = true
        formFields.forEach { textfield in
            defaults.set(textfield.text!.replacingOccurrences(of: "#", with: ""), forKey: "textfield_\(textfield.tag)")
        }
        
        if let val = fontFamilyName {
            MerchantAppConfig.shared.setFont(familyName: val)
        }
        
        if let val = selectLanguageCode {
            MerchantAppConfig.shared.setLang(lang: val)
            let vm = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
            guard let settingsVC = storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC else {
                return
            }
            vm.pushViewController(settingsVC, animated: false)
            let appDlg = UIApplication.shared.delegate as? AppDelegate
            appDlg?.window?.rootViewController = vm
        }
    
        defaults.set(Array(allowedPaymentMethods), forKey: "paymentMethods")
    }
    
    @IBAction func defaulValues() {
        storeValues.isEnabled = true
        defaults.set("checked", forKey: "switch_\(switchCardSave.tag)")
        switchCardSave.isOn = true
        for (index, item) in defaultValues.enumerated() {
            defaults.set(item, forKey: "textfield_\(100+index)")
            formFields[index].text =  format(with: "#XXXXXX", phone: item)
            if let hex = Int(item, radix: 16) {
                formFields[index].setRightIcon(UIColorFromRGB(hex))
            }
        }
    }
    
    @IBAction func deleteReuseToken(_ sender: Any) {
        deleteReuseTokenBtn.isEnabled = false
        defaults.set(nil, forKey: "reuseToken")
    }
    
    @IBAction func changeFont(_ sender: UIButton) {
        storeValues.isEnabled = true
        let fontsVC = FontsTableViewController()
        fontsVC.delegate = self
        self.navigationController?.pushViewController(fontsVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "creditcard":
            let vc = segue.destination as! ConfigurationParamsVC
            vc.title = "Credit Card Config"
        case "paypal":
            let vc = segue.destination as! ConfigurationParamsVC
            vc.title = "Paypal Config"
        case "applepay":
            let vc = segue.destination as! ConfigurationParamsVC
            vc.title = "Apple Pay Config"
        case "klarna":
            let vc = segue.destination as! ConfigurationParamsVC
            vc.title = "Klarna Config"
        case "LanguageList":
            storeValues.isEnabled = true
            let langVC = segue.destination as! ListOfLanguagesVCTableViewController
            langVC.delegate = self
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 5 {
            storeValues.isEnabled = true
            guard let cell = tableView.cellForRow(at: indexPath),
                let sourceType = paymentSource(for: cell) else {
                    assertionFailure("Invalid cell configuration in the Setting scene")
                    return
            }
            if allowedPaymentMethods.contains(sourceType) {
                allowedPaymentMethods.remove(sourceType)
            } else {
                allowedPaymentMethods.insert(sourceType)
            }
        }
    }
    
    func paymentSource(for cell: UITableViewCell) -> VerifoneSDKPaymentTypeValue? {
        switch cell {
        case paymentMethod1:
            return .creditCard
        case paymentMethodCell2:
            return .paypal
        case applepayCell:
            return .applePay
        case klarnaCell:
            return .klarna
        default:
            return nil
        }
    }
    
    func cell(for paymentSource: VerifoneSDKPaymentTypeValue) -> UITableViewCell? {
        switch paymentSource {
        case .creditCard:
            return paymentMethod1
        case .paypal:
            return paymentMethodCell2
        case .applePay:
            return applepayCell
        case .klarna:
            return klarnaCell
        default:
            return nil
        }
    }
    
}

extension SettingsVC: FontsTableViewControllerDelegate, ListOfLanguagesVCTableViewControllerDelegate {
    func didSelectFont(familyName: String) {
        self.fontFamilyName = familyName
        self.fontLabel.text = "Font: \(familyName)"
    }
    
    func didSelectLanguage(selectedLanguageCode: String) {
        self.selectLanguageCode = selectedLanguageCode
        self.currentLangName.text = Locale.current.localizedString(forIdentifier: selectedLanguageCode)!
    }
}

extension SettingsVC: UITextFieldDelegate  {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        storeValues.isEnabled = true
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        
        textField.text = format(with: "#XXXXXX", phone: newString)
        
        if (newString.count <= 7) {
            if let hex = Int(newString.replacingOccurrences(of: "#", with: ""), radix: 16) {
                textField.setRightIcon(UIColorFromRGB(hex))
            }
        }
        return false
    }
    
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9A-Za-z]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator

        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])

                // move numbers iterator to the next index
                index = numbers.index(after: index)

            } else {
                result.append(ch) // just append a mask character
            }
        }

        return result
    }
}

func UIColorFromRGB(_ rgbValue: Int) -> UIColor! {
    return UIColor(
        red: CGFloat((Float((rgbValue & 0xff0000) >> 16)) / 255.0),
        green: CGFloat((Float((rgbValue & 0x00ff00) >> 8)) / 255.0),
        blue: CGFloat((Float((rgbValue & 0x0000ff) >> 0)) / 255.0),
        alpha: 1.0)
}

extension UITextField {
    func setIcon(_ image: UIImage) {
        let iconView = UIImageView(frame:
                                    CGRect(x: 10, y: 5, width: 20, height: 20))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame:
                                                CGRect(x: 20, y: 0, width: 35, height: 30))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }
    
    func setRightIcon(_ color: UIColor) {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 30))
        let colorContainerView: UIView = UIView(frame: CGRect(x: -5, y: 0, width: 30, height: 30))
        colorContainerView.backgroundColor = color
        colorContainerView.layer.cornerRadius = 15
        colorContainerView.layer.masksToBounds = true
        colorContainerView.layer.borderWidth = 0.2
        colorContainerView.layer.borderColor = UIColor.gray.cgColor
        containerView.addSubview(colorContainerView)
        rightView = containerView
        rightViewMode = .always
    }
}
