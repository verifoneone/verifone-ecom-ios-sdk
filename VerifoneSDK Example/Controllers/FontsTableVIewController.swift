//
//  FontsTableVIewController.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 18.01.2022.
//

import UIKit

protocol FontsTableViewControllerDelegate: AnyObject {
    func didSelectFont(familyName: String)
}

class FontsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    var arrayOfFonts: [String] = UIFont.familyNames.filter { $0 != "System Font" }

    weak var delegate: FontsTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Font"

        setupTableView()
        self.tableView.reloadData()
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.white

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FontCell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfFonts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FontCell", for: indexPath)

        cell.textLabel?.text = arrayOfFonts[indexPath.row]
        if arrayOfFonts[indexPath.row] == MerchantAppConfig.shared.getFontName() {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let familyName = arrayOfFonts[indexPath.row]
        self.delegate?.didSelectFont(familyName: familyName)
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.popViewController(animated: true)
    }
}
