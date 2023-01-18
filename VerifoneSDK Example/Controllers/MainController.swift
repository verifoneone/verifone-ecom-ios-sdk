//
//  ViewController.swift
//  sdkTest
//
//  Created by Oraz Atakishiyev on 20.08.2021.
//

import UIKit
import VerifoneSDK

protocol ItemsService {
    func loadItems(completion: @escaping (Result<[ItemViewModel], Error>) -> Void)
}

class MainController: UITableViewController {

    private var items: [ItemViewModel] = []
    private var currency: String = "USD"
    var service: ItemsService?
    var merchantConfig: MerchantAppConfig!

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

    private func loadProducts() {
        if let currency = UserDefaults.standard.value(forKey: Keys.currency) as? String {
            self.currency = currency
        }
        let api = ProductsAPIItemServiceAdapter(api: ProductsAPI.shared, select: { [weak self] item in
            self?.select(product: item)
        }).retry(2)
        self.service = api
        service?.loadItems(completion: handleAPIResult)
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

struct ItemViewModel {
    let title: String
    let price: Double
    let image: String
    let description: String
    let select: () -> Void
}

extension ItemViewModel {
    init(product: Product, selection: @escaping () -> Void) {
        title = product.title
        price = product.price
        image = product.image
        description = product.description
        select = selection
    }
}

struct ProductsAPIItemServiceAdapter: ItemsService {
    let api: ProductsAPI
    let select: (Product) -> Void

    func loadItems(completion: @escaping (Result<[ItemViewModel], Error>) -> Void) {
        api.loadProducts { result in
            DispatchQueue.mainAsyncIfNeeded {
                completion(result.map { items in
                    return items.map { item in
                        ItemViewModel(product: item, selection: {
                            select(item)
                        })
                    }
                })
            }
        }
    }
}

extension ItemsService {
    func fallback(_ fallback: ItemsService) -> ItemsService {
        ItemsServiceWithFallback(primary: self, fallback: fallback)
    }

    func retry(_ retryCount: UInt) -> ItemsService {
        var service: ItemsService = self
        for _ in 0..<retryCount {
            service = service.fallback(self)
        }
        return service
    }
}

struct ItemsServiceWithFallback: ItemsService {
    let primary: ItemsService
    let fallback: ItemsService

    func loadItems(completion: @escaping (Result<[ItemViewModel], Error>) -> Void) {
        primary.loadItems { result in
            switch result {
            case .success:
                completion(result)
            case .failure: fallback.loadItems(completion: completion)
            }
        }
    }
}

extension UIViewController {
  func alert(title: String, message: String = "") {
      DispatchQueue.main.async {
          let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
          let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
          alertController.addAction(OKAction)
          self.present(alertController, animated: true, completion: nil)
      }
  }
}
