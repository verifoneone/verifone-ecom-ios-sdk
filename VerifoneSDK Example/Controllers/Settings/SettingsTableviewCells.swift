//
//  SettingsTableviewCells.swift
//  Verifone2CO Example
//
//  Created by Oraz Atakishiyev on 09.01.2023.
//

import UIKit

// MARK: LinkButtonCell
class LinkButtonCell: UITableViewCell {
    var actionBlock: (() -> Void)?

    var hStack: UIStackView! = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    var leftTextLabel: UILabel! = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()

    var button: UIButton! = {
        let button = UIButton()
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        return button
    }()

    var infoButton: UIButton! = {
        let button = UIButton(type: .infoLight)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        return button
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.hStack.addArrangedSubview(leftTextLabel)
        self.hStack.addArrangedSubview(button)
        self.hStack.addArrangedSubview(infoButton)
        self.contentView.addSubview(hStack)
        self.button.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            hStack.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            hStack.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            hStack.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),
            button.widthAnchor.constraint(equalToConstant: 200.0),
            infoButton.widthAnchor.constraint(equalToConstant: 35.0),
            infoButton.heightAnchor.constraint(equalToConstant: 40.0)
        ])
    }

    @objc func didTapButton(sender: UIButton) {
        actionBlock?()
    }
}

// MARK: TextWithSwitchCell
class TextWithSwitchCell: UITableViewCell {
    var hStack: UIStackView! = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    var hButtonStack: UIStackView! = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    var leftTextLabel: UILabel! = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var iconView: UIImageView! = {
        let iconView = UIImageView(image: UIImage(named: "ic_right_arrow"))
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor.AppColors.lightGray
        iconView.translatesAutoresizingMaskIntoConstraints = false
        return iconView
    }()

    var switchButton: AppSwitchButton! = {
        let switchButton = AppSwitchButton()
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        return switchButton
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.hStack.addArrangedSubview(leftTextLabel)
        self.hButtonStack.addArrangedSubview(iconView)
        self.hButtonStack.addArrangedSubview(switchButton)
        self.hStack.addArrangedSubview(hButtonStack)
        self.contentView.addSubview(hStack)

        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            hStack.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            hStack.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            hButtonStack.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            hButtonStack.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            hButtonStack.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 20.0),
            iconView.widthAnchor.constraint(equalToConstant: 20.0)
        ])
    }
}

// MARK: TextFieldCell
class TextFeildCell: UITableViewCell {
    let defaults = UserDefaults.standard

    var hStack: UIStackView! = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    var leftTextLabel: UILabel! = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    var textfield: UITextField! = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.tintColor = UIColor.lightGray
        textfield.setIcon(UIImage(named: "edit")!)
        textfield.leftView?.tintColor = UIColor.lightGray
        textfield.layer.cornerRadius = 8
        textfield.layer.borderColor = UIColor(0xE4E4E6).cgColor
        textfield.layer.borderWidth = 0.5
        return textfield
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.hStack.addArrangedSubview(leftTextLabel)
        self.hStack.addArrangedSubview(textfield)
        self.contentView.addSubview(hStack)

        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            hStack.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            hStack.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            hStack.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5),
            textfield.widthAnchor.constraint(equalToConstant: 150.0)
        ])
    }

    func setColor(value: String) {
        textfield.text = format(with: "#XXXXXX", hex: value)
        if let hex = Int(value.replacingOccurrences(of: "#", with: ""), radix: 16) {
            textfield.setRightIcon(UIColor(hex))
        }
    }
}

// MARK: TextLabelCell
class TextLabelCell: UITableViewCell {
    var leftTextLabel: UILabel! = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(leftTextLabel)
        NSLayoutConstraint.activate([
            leftTextLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
            leftTextLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
            leftTextLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            leftTextLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10)
        ])
    }
}

// MARK: SeperatorLabelCell
class SeperatorLabelCell: UITableViewCell {
    var seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.AppColors.lineGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(seperatorView)
        NSLayoutConstraint.activate([
            seperatorView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0.0),
            seperatorView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0.0),
            seperatorView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0.0),
            seperatorView.heightAnchor.constraint(equalToConstant: 1.0)
        ])
    }
}
