//
//  CurrencyListVC.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 15.11.2022.
//

import UIKit
import VerifoneSDK

enum DropDownType {
    case currency
    case environment
}

class DropDownVC: UIViewController {
    lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    lazy var stackHView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var textfield: AppTextField = {
        let textfield: AppTextField = AppTextField()
        textfield.autocorrectionType = .no
        textfield.placeholder = dropDownType == .currency ? "Currency" : "Environment"
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.backgroundColor = UIColor(hex: "#FAFAFA")
        textfield.layer.cornerRadius = 6
        textfield.autocapitalizationType = .allCharacters
        return textfield
    }()
    lazy var selectButton: UIButton = {
        let button: UIButton = UIButton(type: .custom)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()
    var initialBounds: CGRect?
    var items: [String] = []
    var filteredItems: [String] = []
    var selectedItem: ((String) -> Void)?
    var dropDownType: DropDownType!
    var hideTextfield: Bool!
    var selectedValue: String?

    init(items: [String], dropDownType: DropDownType, hideTextfield: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.items = items
        self.dropDownType = dropDownType
        self.hideTextfield = hideTextfield
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }

    @objc private func cancel() {
        self.dismiss(animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 15.0, *) {

        } else if initialBounds == nil {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

            initialBounds = view.bounds
            view.layer.cornerRadius = 20
            view.layer.masksToBounds = true
            view.frame = CGRect(x: 0, y: view.bounds.height / 5 * 2, width: view.bounds.width, height: view.bounds.height / 5 * 3)
        }
    }

    @objc func keyboardWillShow() {
        guard let initialBounds = initialBounds else {
            return
        }
        view.frame = initialBounds
    }

    @objc func keyboardWillHide() {
        guard let initialBounds = initialBounds else {
            return
        }
        view.frame = CGRect(x: 0, y: initialBounds.height / 5 * 2, width: initialBounds.width, height: initialBounds.height / 5 * 3)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension DropDownVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (!filteredItems.isEmpty) ? filteredItems.count : self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        cell.textLabel?.text = (!filteredItems.isEmpty) ? filteredItems[indexPath.row] : self.items[indexPath.row]
        if dropDownType == .environment {
            if selectedValue != nil && selectedValue == self.items[indexPath.row] {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = (!filteredItems.isEmpty) ? filteredItems[indexPath.row] : self.items[indexPath.row]
        if dropDownType == .currency {
            UserDefaults.standard.set(item, forKey: Keys.currency)
        }
        self.selectedItem?(item)
        self.dismiss(animated: true)
    }
}

extension DropDownVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        let count = updatedText.count
        if count <= 3 {
            do {
                let regex = try NSRegularExpression(pattern: ".*[^A-Z].*", options: [])
                if regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) != nil {
                    return false
                }
                searchItems(substring: updatedText)
            } catch {}
        }
        return count <= 3
    }

    func searchItems(substring: String) {
        filteredItems.removeAll()
        for curString in items {
            let str: NSString! = curString as NSString
            let substringRange: NSRange! = str.range(of: substring)
            if substringRange.location == 0 {
                filteredItems.append(curString)
            }
        }
        tableView.reloadData()
    }
}

extension DropDownVC {
    private func setupViews() {
        self.view.addSubview(stackHView)
        self.view.addSubview(tableView)
        self.textfield.delegate = self
        self.textfield.becomeFirstResponder()
        self.selectButton.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        self.view.backgroundColor = UIColor.AppColors.background
        self.tableView.delegate = self
        self.tableView.dataSource = self

        if hideTextfield {
            self.stackHView.addArrangedSubview(titleLabel)
        } else {
            self.stackHView.addArrangedSubview(textfield)
        }
        self.stackHView.addArrangedSubview(selectButton)
        NSLayoutConstraint.activate([
            self.stackHView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            self.stackHView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            self.stackHView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: hideTextfield ? 5 : 15),
            self.stackHView.heightAnchor.constraint(equalToConstant: 50),

            self.tableView.topAnchor.constraint(equalTo: self.stackHView.bottomAnchor, constant: 5),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}
