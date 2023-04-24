//
//  ProductDetailCell.swift
//  sdkTest
//
//  Created by Oraz Atakishiyev on 22.09.2021.
//

import UIKit
import VerifoneSDK

class ProductDetailCell: UITableViewCell {
    @IBOutlet weak var shoeNameLabel: UILabel!
    @IBOutlet weak var shoeDescriptionLabel: UILabel!

    var product: ItemViewModel! {
        didSet {
            self.updateUI()
        }
    }

    func updateUI() {
        shoeNameLabel.text = product.title
        shoeDescriptionLabel.text = product.description
    }
}

class BuyButtonCell: UITableViewCell {
    @IBOutlet weak var buyButton: FormButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        buyButton.defaultBackgroundColor = .black
        buyButton.disabledBackgroundColor = .gray
    }
}

class BuyButtonCellWithSingleButton: UITableViewCell {
    @IBOutlet weak var buyButton: FormButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        buyButton.defaultBackgroundColor = .black
        buyButton.disabledBackgroundColor = .gray
    }
}
