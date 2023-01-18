//
//  ListOfLanguagesVCTableViewController.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 07.01.2022.
//

import UIKit

protocol ListOfLanguagesVCTableViewControllerDelegate: AnyObject {
    func didSelectLanguage(selectedLanguageCode: String)
}

class ListOfLanguagesVCTableViewController: UITableViewController {

    var langIds: [Locale] = []
    var languages = [Int: [String: String]]()
    weak var delegate: ListOfLanguagesVCTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Language"
        self.navigationController?.navigationBar.topItem?.title = " "
        langIds = Bundle.main.localizations.map(Locale.init).filter { $0.identifier != "base" }
        for (i, locale) in langIds.enumerated() {
            guard let name = MerchantAppConfig.shared.getLang().localizedString(forIdentifier: locale.identifier)?.localizedCapitalized else { return }
            languages[i] = [locale.identifier: name]
        }
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LangCell", for: indexPath) as! LangCell
        guard let lang: [String: String] = languages[indexPath.row] else {
            return UITableViewCell()
        }
        cell.titleLab.text = "\(lang.first!.value)"
        if lang.first!.key == MerchantAppConfig.shared.getLang().identifier {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let lang: [String: String] = languages[indexPath.row] {
            self.delegate?.didSelectLanguage(selectedLanguageCode: lang.first!.key)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

class LangCell: UITableViewCell {
    @IBOutlet weak var titleLab: UILabel!
}
