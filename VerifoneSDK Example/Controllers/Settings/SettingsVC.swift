//
//  SettingsVC.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 03.04.2023.
//

import UIKit
import VerifoneSDK

class SettingsVC: UIViewController {
    lazy var tableView: UITableView = {
        var tableView: UITableView!
        if #available(iOS 13.0, *) {
            tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
        } else {
            tableView = UITableView(frame: CGRect.zero, style: .grouped)
        }
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.estimatedSectionHeaderHeight = 50.0
        return tableView
    }()

    private(set) var parameters: Parameters! = Parameters()
    fileprivate var currentActiveParamType: SettingCellEvent!
    fileprivate var saveBarButton: UIBarButtonItem!
    fileprivate var selectLanguageCode: String?
    fileprivate var formFields: [UITextField]! = []
    fileprivate var defaults = UserDefaults.standard
    fileprivate var merchantAppConfig = MerchantAppConfig.shared
    
    fileprivate var viewModel = SettingsViewModel()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Settings"
    }

    private func setupTableView() {
        self.title = "Settings"
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        self.tableView.showsVerticalScrollIndicator = false
        self.navigationController?.navigationBar.topItem?.title = " "
        self.saveBarButton = UIBarButtonItem(title: "Save",
                                          style: .plain,
                                          target: self,
                                          action: #selector(saveValues))
        self.saveBarButton.isEnabled = false
        self.navigationItem.rightBarButtonItems = [saveBarButton]
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        self.tableView.allowsSelection = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(TextFeildCell.self, forCellReuseIdentifier: TextFeildCell.description())
        self.tableView.register(LinkButtonCell.self, forCellReuseIdentifier: LinkButtonCell.description())
        self.tableView.register(TextWithSwitchCell.self, forCellReuseIdentifier: TextWithSwitchCell.description())
        self.tableView.register(TextLabelCell.self, forCellReuseIdentifier: TextLabelCell.description())
        self.tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.description())
        self.tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.description())
        self.tableView.register(SeperatorLabelCell.self, forCellReuseIdentifier: SeperatorLabelCell.description())

    }

    @objc private func saveValues() {
        self.saveBarButton.isEnabled = false
        self.viewModel.saveValues()
        if self.viewModel.selectedLangCode != nil {
            let vm = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
            guard let settingsVC = storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC else {
                return
            }
            vm.pushViewController(settingsVC, animated: false)
            let appDlg = UIApplication.shared.delegate as? AppDelegate
            appDlg?.window?.rootViewController = vm
        }
    }

    @objc private func defaultValues() {
        self.saveBarButton.isEnabled = true
        // get cells total count for section and substract color textfields count, to get correct index
        let startIndex = viewModel.sections[SettingSections.cardCustomization.rawValue].cells.count - 9
        for i in 0..<self.viewModel.defaultColorValues.count {
            self.viewModel.sections[SettingSections.cardCustomization.rawValue].cells[startIndex+i].value = self.viewModel.defaultColorValues[i]
        }
        tableView.reloadData()
    }

    @objc private func endEditing() {
        self.view.endEditing(true)
    }

    func changeEnv() {
        let envvc = DropDownVC(items: MerchantAppConfig.shared.environments, dropDownType: .environment, hideTextfield: true)
        envvc.titleLabel.text = "Select Region"
        envvc.selectedValue = self.viewModel.selectedEnvironment
        envvc.selectedItem = {[weak self] env in
            self?.saveBarButton.isEnabled = true
            self?.viewModel.selectedEnvironment = env
            self?.viewModel.sections[SettingSections.Region.rawValue].cells[0].value = env
            self?.tableView.reloadRows(at: [IndexPath(row: 0, section: SettingSections.Region.rawValue)], with: .automatic)
        }
        if #available(iOS 15.0, *) {
            if let sheet = envvc.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.preferredCornerRadius = 20
            }
        }
        present(envvc, animated: true, completion: nil)
    }

    @objc func changeFont() {
        saveBarButton.isEnabled = true
        let fontsVC = ListVCTableViewController(isFontLoad: true)
        fontsVC.delegate = self
        self.navigationController?.pushViewController(fontsVC, animated: true)
    }

    @objc func chnageLang() {
        saveBarButton.isEnabled = true
        let langVC = ListVCTableViewController(isFontLoad: false)
        langVC.delegate = self
        self.navigationController?.pushViewController(langVC, animated: true)
    }

    @objc func deleteReuseToken() {
        defaults.set(false, forKey: Keys.reuseToken)
        self.viewModel.sections[SettingSections.ReuseToken.rawValue].cells[0].isOn = false
        self.tableView.reloadSections(IndexSet([SettingSections.ReuseToken.rawValue]), with: .automatic)
    }
}

extension SettingsVC: ListVCTableViewControllerDelegate {
    func didSelectFont(familyName: String) {
        self.viewModel.selectedFont = familyName
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [IndexPath(row: 1, section: SettingSections.LangFont.rawValue)], with: .none)
        }
    }

    func didSelectLanguage(selectedLanguageCode: String) {
        self.viewModel.selectedLangCode = selectedLanguageCode
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: SettingSections.LangFont.rawValue)], with: .none)
        }
    }
}

extension SettingsVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.sections[section].cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.viewModel.sections[indexPath.section].cells[indexPath.row]
        switch item.type {
        case .textfield:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TextFeildCell.description(),
                for: indexPath) as! TextFeildCell
            cell.leftTextLabel.text = item.placeholder
            cell.textfield.delegate = self
            cell.textfield.tag = 1000+indexPath.row
            cell.setColor(value: item.value)
            return cell
        case .linkButton:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: LinkButtonCell.description(),
                for: indexPath) as! LinkButtonCell
            cell.leftTextLabel.text = item.placeholder
            cell.button.setTitle(item.value, for: .normal)
            cell.infoButton.isHidden = true
            cell.selectionStyle = .none
            cell.actionBlock = { [weak self] in
                switch item.eventType {
                case .region:
                    self?.changeEnv()
                case .langChange:
                    self?.chnageLang()
                case .font:
                    self?.changeFont()
                case .defaultValues:
                    self?.defaultValues()
                case .reuseToken:
                    self?.deleteReuseToken()
                default: break
                }
            }
            cell.button.setTitleColor(UIColor.systemBlue, for: .normal)
            if item.placeholder == "Card details" && !item.isOn {
                cell.button.setTitleColor(.gray, for: .normal)
            }
            return cell
        case .switchButton:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TextWithSwitchCell.description(),
                for: indexPath) as! TextWithSwitchCell
            cell.leftTextLabel.text = item.placeholder
            cell.iconView.alpha = item.paymentType != nil ? 0.7 : 0.0
            cell.switchButton.isOn = item.isOn
            cell.switchButton.tag = 1000 * indexPath.section + indexPath.row
            cell.switchButton.addTarget(self, action: #selector(switchButtonValueChanged), for: .valueChanged)
            return cell
        case .textLabel:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TextLabelCell.description(),
                for: indexPath) as! TextLabelCell
            cell.leftTextLabel.text = item.placeholder
            cell.isUserInteractionEnabled = true
            return cell
        case .seperator:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SeperatorLabelCell.description(),
                for: indexPath) as! SeperatorLabelCell
            return cell
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections[section].header
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = self.viewModel.sections[indexPath.section].cells[indexPath.row]
        switch item.type {
        case .linkButton, .switchButton, .textLabel:
            return 50.0
        case .textfield:
            return 50.0
        case .seperator:
            return 10.0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == SettingSections.Options.rawValue {
            let item = self.viewModel.sections[indexPath.section].cells[indexPath.row]
            let vc = ConfigurationParamsVC()
            vc.paymentMethodType = item.paymentType
            vc.title = item.paymentType?.rawValue
            vc.didClose = { [weak self] in
                self?.viewModel.loadPaymentStates()
                self?.viewModel.sections[indexPath.section].cells[indexPath.row].isOn = self!.viewModel.paymentStateSwitchButtons[item.paymentType!.rawValue]!
                self?.tableView.reloadSections([SettingSections.Options.rawValue], with: .automatic)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc private func switchButtonValueChanged(sender: UISwitch) {
        self.saveBarButton.isEnabled = true
        if SettingSections.cardCustomization.rawValue == sender.tag/1000 {
            if sender.tag%1000 == 0 {
                defaults.set(sender.isOn, forKey: Keys.isCardSaveEnabled)
            }
            if sender.tag%1000 == 1 {
                defaults.set(sender.isOn, forKey: Keys.threedsEnabled)
            }
        }
        if SettingSections.Options.rawValue == sender.tag/1000 {
            let cellModel = viewModel.sections[sender.tag/1000].cells[sender.tag%1000]
            if !self.viewModel.isParamValid(cellModel.paymentType!) {
                self.alert(title: "Missing required parameters for \(cellModel.paymentType!.rawValue)")
                sender.isOn = false
            }
            let pmethod = cellModel.placeholder == "Credit card" ? "Card" : cellModel.placeholder
            self.viewModel.paymentStateSwitchButtons[pmethod] = sender.isOn
            self.viewModel.sections[sender.tag/1000].cells[sender.tag%1000].isOn = self.viewModel.paymentStateSwitchButtons[pmethod]!
        }
    }
}

// MARK: - UITextFieldDelegate
extension SettingsVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        saveBarButton.isEnabled = true
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        let positionOriginal = textField.beginningOfDocument
        let cursorLocation = textField.position(from: positionOriginal, offset: (range.location + string.count))
        textField.text = format(with: "#XXXXXX", hex: newString).uppercased()
        if let cursorLocation = cursorLocation {
            textField.selectedTextRange = textField.textRange(from: cursorLocation, to: cursorLocation)
        }
        if !viewModel.sections[SettingSections.cardCustomization.rawValue].cells.isEmpty {
            viewModel.sections[SettingSections.cardCustomization.rawValue].cells[textField.tag-1000].value = textField.text!
        }
        if textField.text!.dropFirst().count <= 7 {
            if let hex = Int(textField.text!.dropFirst(), radix: 16) {
                textField.setRightIcon(UIColor(hex))
            }
        }
        return false
    }
}
