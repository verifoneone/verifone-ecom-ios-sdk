//
//  ResultPageVCViewController.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 10.11.2021.
//

import UIKit
import VerifoneSDK

class ResultPageVCViewController: UIViewController, PanModalPresentable {

    public var panScrollable: UIScrollView? {
        return tableView
    }

    public var longFormHeight: PanModalHeight {
        return .maxHeight
    }

    public var anchorModalToLongForm: Bool {
        return true
    }

    public var shouldRoundTopCorners: Bool {
        return true
    }

    @IBOutlet weak var tableView: UITableView!

    var handleError = false
    var items: [ResultData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableView.automaticDimension
    }

}

extension ResultPageVCViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        if !handleError {
            switch indexPath.row {
            case 0:
                let cell: ResultTextWithImageCell = tableView.dequeueReusableCell(withIdentifier: ResultTextWithImageCell.identity, for: indexPath) as! ResultTextWithImageCell
                cell.picureView.image = UIImage(named: item.image!)
                cell.priceLabel.text = item.rightText

                return cell
            case 1:
                let cell: ResultImageCell = tableView.dequeueReusableCell(withIdentifier: ResultImageCell.identity, for: indexPath) as! ResultImageCell
                cell.picureView.image = UIImage(named: item.image!)
                cell.subtext.text = item.rightText

                return cell
            case 2:
                let cell: ResultTextCell = tableView.dequeueReusableCell(withIdentifier: ResultTextCell.identity, for: indexPath) as! ResultTextCell
                cell.leftText.text = item.leftText
                cell.rightText.text = item.rightText

                return cell
            case 3:
                let cell: ResultTextCell = tableView.dequeueReusableCell(withIdentifier: ResultTextCell.identity, for: indexPath) as! ResultTextCell
                cell.leftText.text = item.leftText
                cell.rightText.adjustsFontSizeToFitWidth = true
                cell.rightText.font = UIFont(name: "Helvetica", size: 14.0)
                cell.rightText.text = item.rightText

                return cell
            case 4:
                let cell: ResultButtonCell = tableView.dequeueReusableCell(withIdentifier: ResultButtonCell.identity, for: indexPath) as! ResultButtonCell
                cell.button.setTitle(item.leftText, for: .normal)
                cell.subtext.text = item.rightText
                cell.button.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
                return cell
            default:
                return UITableViewCell()
            }
        } else {
            switch indexPath.row {
            case 0:
                let cell: ResultTextCell = tableView.dequeueReusableCell(withIdentifier: ResultTextCell.identity, for: indexPath) as! ResultTextCell
                cell.leftText.text = ""
                cell.rightText.text = ""
                return cell
            case 1:
                let cell: ResultImageCell = tableView.dequeueReusableCell(withIdentifier: ResultImageCell.identity, for: indexPath) as! ResultImageCell
                cell.picureView.image = UIImage(named: item.image!)
                cell.subtext.adjustsFontSizeToFitWidth = true
                cell.subtext.text = item.rightText
                return cell
            case 2:
                let cell: ResultErrorCell = tableView.dequeueReusableCell(withIdentifier: ResultErrorCell.identity, for: indexPath) as! ResultErrorCell
                cell.errorLabel.adjustsFontSizeToFitWidth = true
                cell.errorLabel.text = item.rightText
                return cell
            default:
                return UITableViewCell()
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !handleError {
            switch indexPath.row {
            case 0:
                return 70
            case 1:
                return 220
            case 2, 3:
                return 40
            case 4:
                return 120
            default:
                return UITableView.automaticDimension
            }
        } else {
            switch indexPath.row {
            case 0:
                return 70
            case 1:
                return 220
            case 2:
                return UITableView.automaticDimension
            default:
                return UITableView.automaticDimension
            }
        }
    }

    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}

struct ResultData {
    var image: String?
    var leftText: String?
    var rightText: String?
}
