//
//  ButtonTableViewCell.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 10.11.2022.
//

import UIKit

// MARK: ButtonCell
class ButtonTableViewCell: UITableViewCell, UITextViewDelegate {

    var hStack: UIStackView! = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    var button: UIButton! = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = button.titleLabel?.font.withSize(14)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var titleStr: String = "" {
        didSet {
            button.setTitle(titleStr, for: .normal)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.hStack.addArrangedSubview(button)
        self.contentView.addSubview(hStack)

        hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0).isActive = true
        hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10.0).isActive = true
        hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5.0).isActive = true
        hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}
