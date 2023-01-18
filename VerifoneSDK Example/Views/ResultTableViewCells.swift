//
//  ResultTableViewCells.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 10.11.2021.
//

import UIKit

class ResultTextWithImageCell: UITableViewCell {
    static var identity = "ResultTextWithImageCell"

    @IBOutlet weak var picureView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class ResultTextCell: UITableViewCell {
    static var identity = "ResultTextCell"

    @IBOutlet weak var leftText: UILabel!
    @IBOutlet weak var rightText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class ResultImageCell: UITableViewCell {
    static var identity = "ResultImageCell"

    @IBOutlet weak var picureView: UIImageView!
    @IBOutlet weak var subtext: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class ResultButtonCell: UITableViewCell {
    static var identity = "ResultButtonCell"

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var subtext: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class ResultErrorCell: UITableViewCell {
    static var identity = "ResultErrorCell"

    @IBOutlet weak var errorLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
