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
        label.textColor = .black
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
        button.tintColor = UIColor.darkGray
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

        backgroundColor = .white
        addSubview(seperatorView)
        addSubview(HstackView)

        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    func setupConstraints() {
        HstackView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        HstackView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0.0).isActive = true
        HstackView.topAnchor.constraint(equalTo: self.topAnchor, constant: -15).isActive = true
        HstackView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: Constants.contentInsets.left).isActive = true
        HstackView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.contentInsets.right).isActive = true

        seperatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        seperatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        seperatorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        seperatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 38.0).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 38.0).isActive = true
    }

    // MARK: - View Configuration

    func configure(with presentable: PaymentTypeHeaderPresentable) {
        titleLabel.text = "\(presentable.title)"
    }

}
