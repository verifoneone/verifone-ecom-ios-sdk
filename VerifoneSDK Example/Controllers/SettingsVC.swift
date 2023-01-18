//
//  SettingsVC.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 08.12.2021.
//

import UIKit
import VerifoneSDK

private var defaultValues = ["FFFFFF", "FFFFFF", "000000", "364049", "007AFF", "E4E7ED", "FFFFFF", "000000"]

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

    @IBOutlet weak var changeEnv: UIButton!

    let defaults = UserDefaults.standard
    fileprivate var saveVal: Bool = false
    fileprivate var fontFamilyName: String?
    fileprivate var selectLanguageCode: String?
    fileprivate var selectedEnvironment: String!

    @IBOutlet weak var creditCard: UITableViewCell!
    @IBOutlet weak var paypal: UITableViewCell!
    @IBOutlet weak var applepayCell: UITableViewCell!
    @IBOutlet weak var klarnaCell: UITableViewCell!
    @IBOutlet weak var swishCell: UITableViewCell!
    @IBOutlet weak var vippsCell: UITableViewCell!
    @IBOutlet weak var mobielPayCell: UITableViewCell!
    
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
            if value == "checked" {
                switchCardSave.isOn = true
            } else {
                switchCardSave.isOn = false
            }
        } else {
            defaults.set("checked", forKey: "switch_\(switchCardSave.tag)")
        }

        // Enable button if we have saved token(card details)
        do {
            _ = try defaults.getObject(forKey: "reuseToken", castTo: ResponseReuseToken.self)
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

        selectedEnvironment = defaults.getEnv(fromKey: Keys.environment)
        changeEnv.setTitle(selectedEnvironment, for: .normal)
    }

    @IBAction func enableCardSave(_ sender: UISwitch) {
        storeValues.isEnabled = true
        if sender.isOn {
            defaults.set("checked", forKey: "switch_\(switchCardSave.tag)")
        } else {
            defaults.set("unchecked", forKey: "switch_\(switchCardSave.tag)")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "LanguageList":
            storeValues.isEnabled = true
            let langVC = segue.destination as! ListOfLanguagesVCTableViewController
            langVC.delegate = self
        default:
            break
        }
    }

    func reset() {
        // if closed without saving
        if !saveVal {
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
        defaults.set(selectedEnvironment, forKey: Keys.environment)
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

    @IBAction func changeEnv(_ sender: Any) {

        let envvc = DropDownVC(items: MerchantAppConfig.shared.environments, dropDownType: .environment, hideTextfield: true)
        envvc.titleLabel.text = "Select Region"
        envvc.selectedValue = selectedEnvironment
        envvc.selectedItem = {[weak self] env in
            self?.storeValues.isEnabled = true
            self?.selectedEnvironment = env
            self?.changeEnv.setTitle(env, for: .normal)
        }
        if #available(iOS 15.0, *) {
            if let sheet = envvc.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.preferredCornerRadius = 20
            }
        }
        present(envvc, animated: true, completion: nil)
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 6 {
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

        if indexPath.section == 7 {
            let vc = ConfigurationParamsVC()
            switch tableView.cellForRow(at: indexPath)!.tag {
            case 1010:
                vc.title = "Credit Card Config"
                vc.paymentMethodType = .creditCard
            case 1011:
                vc.title = "Paypal Config"
                vc.paymentMethodType = .paypal
            case 1012:
                vc.title = "Apple Pay Config"
                vc.paymentMethodType = .applePay
            case 1013:
                vc.title = "Klarna Config"
                vc.paymentMethodType = .klarna
            case 1014:
                vc.title = "Swish Config"
                vc.paymentMethodType = .swish
            case 1015:
                vc.title = "Vipps Config"
                vc.paymentMethodType = .vipps
            case 1016:
                vc.title = "MobilePay Config"
                vc.paymentMethodType = .mobilePay
            default:
                break
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func paymentSource(for cell: UITableViewCell) -> VerifoneSDKPaymentTypeValue? {
        switch cell {
        case creditCard:
            return .creditCard
        case paypal:
            return .paypal
        case applepayCell:
            return .applePay
        case klarnaCell:
            return .klarna
        case swishCell:
            return .swish
        case vippsCell:
            return .vipps
        case mobielPayCell:
            return .mobilePay
        default:
            return nil
        }
    }

    func cell(for paymentSource: VerifoneSDKPaymentTypeValue) -> UITableViewCell? {
        switch paymentSource {
        case .creditCard:
            return creditCard
        case .paypal:
            return paypal
        case .applePay:
            return applepayCell
        case .klarna:
            return klarnaCell
        case .swish:
            return swishCell
        case .vipps:
            return vippsCell
        case .mobilePay:
            return mobielPayCell
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

extension SettingsVC: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        storeValues.isEnabled = true
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)

        textField.text = format(with: "#XXXXXX", phone: newString)

        if newString.count <= 7 {
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
