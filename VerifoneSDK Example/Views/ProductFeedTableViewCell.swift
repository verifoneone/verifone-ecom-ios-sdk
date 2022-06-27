//
//  ProductFeedTableViewCell.swift
//  sdkTest
//
//  Created by Oraz Atakishiyev on 22.09.2021.
//

import UIKit
import VerifoneSDK

class ProductFeedTableViewCell: UITableViewCell {
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!

    func configure(_ viewm: ItemViewModel) {
        productImageView.image = UIImage(named: viewm.image)
        productNameLabel?.text = viewm.title
        productPriceLabel?.text = "\(viewm.price)$"
    }
}

class ItemCell: UITableViewCell {

    class var reuseIdentifier: String {
        {
            return "ItemCell"
        }()
    }

    lazy var button: FormButton = {
        let button = FormButton()
        button.setTitle("Buy", for: .normal)
        
                button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            button.heightAnchor.constraint(equalToConstant: 40),
            button.widthAnchor.constraint(equalToConstant: 100)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
