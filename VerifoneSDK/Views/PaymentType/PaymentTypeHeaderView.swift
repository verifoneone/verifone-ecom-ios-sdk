//
//  PaymentTypeHeaderView.swift
//  Verifone
//
//  Created by Oraz Atakishiyev on 20.08.2021.
//

import UIKit

class PaymentTypeHeaderView: UIView {

    struct Constants {
        static let contentInsets = UIEdgeInsets(top: -9.0, left: 16.0, bottom: 12.0, right: 16.0)
    }

    // MARK: - Views

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Lato-Bold", size: 18.0)
        label.textColor = UIColor.VF.text
        return label
    }()

    lazy var HstackView: UIStackView = {
        let hStackView = UIStackView(arrangedSubviews: [titleLabel, closeButton])
        hStackView.axis = .horizontal
        hStackView.distribution = .equalSpacing
        hStackView.alignment = .center
        hStackView.translatesAutoresizingMaskIntoConstraints = false
        return hStackView
    }()

    let seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.8235294118, blue: 0.8274509804, alpha: 1).withAlphaComponent(0.11)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 0.8196078431, green: 0.8235294118, blue: 0.8274509804, alpha: 1).withAlphaComponent(0.5)
        button.tintColor = UIColor.VF.text
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 19
        button.layer.masksToBounds = true
        button.setImage(UIImage(named: "Close", in: .module, compatibleWith: nil), for: UIControl.State.normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return button
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.VF.defaultBackground
        addSubview(seperatorView)
        addSubview(HstackView)

        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    func setupConstraints() {
        NSLayoutConstraint.activate([
            HstackView.heightAnchor.constraint(equalToConstant: 50.0),
            HstackView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0.0),
            HstackView.topAnchor.constraint(equalTo: self.topAnchor, constant: -15),
            HstackView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: Constants.contentInsets.left),
            HstackView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.contentInsets.right),
            seperatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            seperatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            seperatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            seperatorView.heightAnchor.constraint(equalToConstant: 1.0),
            closeButton.heightAnchor.constraint(equalToConstant: 38.0),
            closeButton.widthAnchor.constraint(equalToConstant: 38.0)
        ])
    }

    // MARK: - View Configuration
    func configure(with presentable: PaymentTypeHeaderPresentable) {
        titleLabel.text = "\(presentable.title)"
    }
}
