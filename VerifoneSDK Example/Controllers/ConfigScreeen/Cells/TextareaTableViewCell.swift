//
//  TextareaTableViewCell.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 10.11.2022.
//

import UIKit

// MARK: Large Text area
class TextAreaTableViewCell: UITableViewCell, UITextViewDelegate {
    var textFieldTextChangeCallback: ((String) -> Void)?

    var hStack: UIStackView! = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.spacing = 2
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

    var placeholderForTextView: String = "" {
        didSet {
            textView.text = placeholderForTextView
        }
    }

    var textView: UITextView! = {
        let t = UITextView()
        t.textContainer.lineFragmentPadding = 0
        t.autocapitalizationType = .words
        t.keyboardType = .default
        t.textColor = .lightGray
        t.font = .systemFont(ofSize: 16)
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.hStack.addArrangedSubview(textfieldTitleLabel)
        self.hStack.addArrangedSubview(textView)
        self.contentView.addSubview(hStack)
        self.textView.delegate = self

        hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0).isActive = true
        hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10.0).isActive = true
        hStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3.0).isActive = true
        hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 6.0).isActive = true

        self.contentView.addConstraint(NSLayoutConstraint(item: self.textfieldTitleLabel!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 30))
        self.contentView.addConstraint(NSLayoutConstraint(item: self.textView!, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: -6))

    }

    func textViewDidBeginEditing (_ textView: UITextView) {
        if textView.isFirstResponder && textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing (_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == "" {
            textView.textColor = .lightGray
            textView.text = placeholderForTextView
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        textFieldTextChangeCallback?(textView.text)
    }
}
