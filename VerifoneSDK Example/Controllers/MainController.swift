//
//  ViewController.swift
//  sdkTest
//
//  Created by Oraz Atakishiyev on 20.08.2021.
//

import UIKit
import VerifoneSDK

class MainController: UITableViewController {

    private var items: [ItemViewModel] = []
    private var currency: String = "USD"
    var merchantConfig: MerchantAppConfig!
    var viewModel = MainViewModel(api: ProductsAPI.shared)

    struct Storyboard {
        static let feedCell = "ProductFeedTableViewCell"
        static let showShoeDetail = "ShowShoeDetail"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            let barAppearance = UINavigationBarAppearance()
            navigationItem.standardAppearance = barAppearance
            navigationItem.scrollEdgeAppearance = barAppearance
        }

        self.title = "feed".localized()
        loadProducts()
        let currencyChangeButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_currency"), style: .plain, target: self, action: #selector(changeCurrency))
        self.navigationItem.leftBarButtonItems = [currencyChangeButton]
        let settingsButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "setting"), style: .plain, target: self, action: #selector(gotoSettings))
        self.navigationItem.rightBarButtonItems = [settingsButton]

        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = tableView.rowHeight
        self.tableView.rowHeight = UITableView.automaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.merchantConfig = MerchantAppConfig.shared
    }

    @objc func changeCurrency() {
        let currencyListVC = DropDownVC(items: MerchantAppConfig.shared.currencies, dropDownType: .currency)
        currencyListVC.selectedItem = {[weak self] currency in
            self?.currency = currency
            self?.tableView.reloadData()
        }
        present(currencyListVC, animated: true, completion: nil)
    }

    @objc func gotoSettings() {
        let settingVC = SettingsVC()
        self.navigationController?.pushViewController(settingVC, animated: true)
    }

    private func loadProducts() {
        self.currency = viewModel.currency
        self.viewModel.loadItems(completion: handleAPIResult(_:))
    }

    private func handleAPIResult(_ result: Result<[ItemViewModel], Error>) {
        switch result {
        case let .success(items):
            self.items = items
            self.tableView.reloadData()

        case let .failure(error):
            self.show(error: error)
        }
    }
}

extension MainController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.feedCell,
                                                 for: indexPath) as! ProductFeedTableViewCell
        cell.configure(items[indexPath.row], currency: currency)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailsViewController") as! ProductDetailsViewController
        detailVC.product = items[indexPath.row]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
