//
//  ConfigurationParamsVC.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 09.05.2022.
//

import UIKit

final class ConfigurationParamsVC: UIViewController, UITableViewDataSource {

    var tableView: UITableView = {
        var t: UITableView! = UITableView(frame: .zero, style: .grouped)
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()

    var didClose: (() -> Void)?
    var paymentMethodType: AppPaymentMethodType!
    var viewModel = SettingsViewModel()

    private(set) var currentActiveParamType: ParamType!
    private(set) var rightBarItem: UIBarButtonItem!
    private(set) var parameters: Parameters! = Parameters()
    private(set) var items: [ConfigSection] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.tableView.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(ConfigurationParamsVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConfigurationParamsVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.view.addSubview(self.tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        self.tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.description())
        self.tableView.register(TextAreaTableViewCell.self, forCellReuseIdentifier: TextAreaTableViewCell.description())
        self.tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.description())
        setup()
    }

    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }

    @objc func keyboardWillShow(_ notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }

    @objc func keyboardWillHide(_ notification:Notification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    func setup() {
        rightBarItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveChanged))
        rightBarItem.isEnabled = false
        self.navigationItem.rightBarButtonItem = rightBarItem

        var params = ParameterByPaymentType(paymentMethodType: self.paymentMethodType)
        (self.parameters, self.items) = params.getFields()

        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        self.tableView.reloadData()
    }

    @objc func saveChanged() {
        self.rightBarItem.isEnabled = false
        UserDefaults.standard.save(customObject: self.parameters, inKey: paymentMethodType.rawValue)
        MerchantAppConfig.shared.setParams(paymentMethodType: paymentMethodType)
        // Check params if it's missing disable payment method
        if !self.viewModel.isParamValid(paymentMethodType) {
            self.viewModel.paymentStateSwitchButtons[paymentMethodType.rawValue] = false
            self.viewModel.saveValues()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.layoutIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            self.didClose?()
        }
    }
}

extension ConfigurationParamsVC: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = items[indexPath.section].cells[indexPath.row]

        switch cellModel.cell {
        case is TextField:
            guard let fieldData = cellModel.cell as? TextField else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TextFieldTableViewCell.description(),
                for: indexPath) as? TextFieldTableViewCell
            cell?.textfieldTitleLabel.text = fieldData.title
            cell?.textfield.placeholder = fieldData.placeholder
            cell?.textfield.backgroundColor = (cellModel.error != nil) ? UIColor.AppColors.textfieldRedColor : UIColor.AppColors.background
            cell?.textFieldTextChangeCallback = { [unowned self] text in
                self.currentActiveParamType = cellModel.paramType
                self.textChange(text: text)
                cell?.textfield.backgroundColor = UIColor.AppColors.background
            }
            cell?.textfield.text = ""
            guard let value = cellModel.value else { return cell! }
            cell?.textfield.text = value

            return cell!
        case is TextArea:
            guard let fieldData = cellModel.cell as? TextArea else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TextAreaTableViewCell.description(),
                for: indexPath) as! TextAreaTableViewCell
            cell.textfieldTitleLabel.text = fieldData.title
            cell.placeholderForTextView = fieldData.placeholder
            cell.textView.text = ""
            cell.textView.backgroundColor = (cellModel.error != nil) ? UIColor.AppColors.textfieldRedColor : UIColor.AppColors.background
            cell.textFieldTextChangeCallback = { [unowned self] text in
                self.currentActiveParamType = cellModel.paramType
                self.textChange(text: text)
                cell.textView.backgroundColor = UIColor.AppColors.background
            }
            guard let value = cellModel.value else { return cell }
            cell.textView.text = value
            cell.textView.textColor = UIColor.AppColors.defaultBlackLabelColor
            return cell
        case is ButtonItem:
            guard let fieldData = cellModel.cell as? ButtonItem else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ButtonTableViewCell.description(),
                for: indexPath) as! ButtonTableViewCell
            cell.titleStr = fieldData.title
            cell.button.addTarget(self, action: #selector(browseFiles(sender:)), for: .touchUpInside)
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellModel = items[indexPath.section].cells[indexPath.row]

        switch cellModel.cell {
        case is TextField:
            return 70.0
        case is TextArea:
            return 100.0
        case is ButtonItem:
            return 60.0
        default:
            return 0.0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items[section].header
    }

    @objc func browseFiles(sender: UIButton) {
        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.json"], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet

        if let popoverPresentationController = importMenu.popoverPresentationController {
            popoverPresentationController.sourceRect = sender.bounds
        }
        self.present(importMenu, animated: true, completion: nil)
    }

    private func textChange(text: String) {
        self.rightBarItem.isEnabled = true
        switch currentActiveParamType {
        case .publicKeyAlias:
            parameters.publicKeyAlias = text
        case .threedsContractId:
            parameters.threedsContractID = text
        case .encryptionKey:
            parameters.encryptionKey = text
        case .paymentProviderContract:
            parameters.paymentProviderContract = text
        case .apiUserID:
            parameters.apiUserID = text
        case .apiKey:
            parameters.apiKey = text
        case .tokenScope:
            parameters.tokenScope = text
        case .customer:
            parameters.customer = text
        case .entityId:
            parameters.entityId = text
        default: break
        }
    }
}

extension ConfigurationParamsVC: UIDocumentPickerDelegate, UINavigationControllerDelegate {

    func documentMenu(_ documentMenu: UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == .import {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                self.parameters = try decoder.decode(Parameters.self, from: data)

                let fields = parameters.validateByPayment(self.paymentMethodType)
                if let fields = fields, !fields.isEmpty {
                    // swiftlint:disable opening_brace
                    let fieldParams = fields.map{ "\n\($0.key)" }.joined(separator: ", ")
                    self.alert(title: "Warning", message: fields.count == 1 ? "Required parameter is missing: \(fieldParams)" : "Some required parameters are missing: \(fieldParams)")
                }

                guard let firstSection: ConfigSection = items.first, !items.isEmpty else { return }
                // swiftlint:disable identifier_name
                for (i, cell) in firstSection.cells.enumerated() {
                    switch cell.paramType {
                    case .publicKeyAlias:
                        items[0].cells[i].value = parameters.publicKeyAlias
                    case .threedsContractId:
                        items[0].cells[i].value = parameters.threedsContractID
                    case .encryptionKey:
                        items[0].cells[i].value = parameters.encryptionKey
                    case .paymentProviderContract:
                        items[0].cells[i].value = parameters.paymentProviderContract
                    case .apiUserID:
                        items[0].cells[i].value = parameters.apiUserID
                    case .apiKey:
                        items[0].cells[i].value = parameters.apiKey
                    case .tokenScope:
                        items[0].cells[i].value = parameters.tokenScope
                    case .customer:
                        items[0].cells[i].value = parameters.customer
                    case .entityId:
                        items[0].cells[i].value = parameters.entityId
                    default: break
                    }
                    items[0].cells[i].error = fields![cell.paramType.rawValue]
                }
                self.rightBarItem.isEnabled = true
                self.tableView.reloadData()
            } catch {
                self.alert(title: "Wrong json format", message: "An error has occurred: \(error.localizedDescription)")
            }
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
}
