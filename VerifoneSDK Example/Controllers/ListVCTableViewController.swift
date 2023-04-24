//
//  ListOfLanguagesVCTableViewController.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 07.01.2022.
//

import UIKit

protocol ListVCTableViewControllerDelegate: AnyObject {
    func didSelectLanguage(selectedLanguageCode: String)
    func didSelectFont(familyName: String)
}

class ListVCTableViewController: UITableViewController {

    var isFontLoad: Bool = false
    var langIds: [Locale] = []
    var languages = [Int: [String: String]]()
    var arrayOfFonts: [String] = UIFont.familyNames.filter { $0 != "System Font" }
    weak var delegate: ListVCTableViewControllerDelegate?

    init(isFontLoad: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.isFontLoad = isFontLoad
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableview()
    }

    private func configureTableview() {
        self.title = "Select Language"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.navigationController?.navigationBar.topItem?.title = " "
        if !isFontLoad {
            langIds = Bundle.main.localizations.map(Locale.init).filter { $0.identifier != "base" }
            for (i, locale) in langIds.enumerated() {
                guard let name = MerchantAppConfig.shared.getLang().localizedString(forIdentifier: locale.identifier)?.localizedCapitalized else { return }
                languages[i] = [locale.identifier: name]
            }
        }
        self.tableView.reloadData()
    }
}

// MARK: - Table view data source
extension ListVCTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFontLoad ? arrayOfFonts.count : languages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if isFontLoad {
            cell.textLabel?.text = arrayOfFonts[indexPath.row]
            if arrayOfFonts[indexPath.row] == MerchantAppConfig.shared.getFontName() {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else {
            guard let lang: [String: String] = languages[indexPath.row] else {
                return UITableViewCell()
            }
            cell.textLabel?.text = "\(lang.first!.value)"
            if lang.first!.key == MerchantAppConfig.shared.getLang().identifier {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.popViewController(animated: true)
        if isFontLoad {
            let familyName = arrayOfFonts[indexPath.row]
            self.delegate?.didSelectFont(familyName: familyName)
        } else {
            if let lang: [String: String] = languages[indexPath.row] {
                self.delegate?.didSelectLanguage(selectedLanguageCode: lang.first!.key)
            }
        }
    }
}
