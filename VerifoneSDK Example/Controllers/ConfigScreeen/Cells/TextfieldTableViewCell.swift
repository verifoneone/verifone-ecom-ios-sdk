//
//  TextfieldTableViewCell.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 10.11.2022.
//

import UIKit
import VerifoneSDK

class TextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {
    var textFieldTextChangeCallback: ((String) -> Void)?

    var hStack: UIStackView! = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 0
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 15, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    var textfieldTitleLabel: UILabel! = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.font = label.font.withSize(14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var textfield: BaseTextField! = {
        let t = BaseTextField()
        t.font = .systemFont(ofSize: 16)
        t.keyboardType = .default
        t.borderStyle = .none
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textfield.delegate = self
        self.hStack.addArrangedSubview(textfieldTitleLabel)
        self.hStack.addArrangedSubview(textfield)
        self.contentView.addSubview(hStack)

        hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0).isActive = true
        hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10.0).isActive = true
        hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.0).isActive = true
        hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 15.0).isActive = true

        self.contentView.addConstraint(NSLayoutConstraint(item: self.textfieldTitleLabel!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 20))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.textfield!, attribute: .bottom, relatedBy: .equal, toItem: self.textfield, attribute: .bottom, multiplier: 1.0, constant: -6))
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        let proposed = text.replacingCharacters(in: Range(range, in: text)!, with: string)
        textFieldTextChangeCallback?(proposed)
        return true
    }
}
