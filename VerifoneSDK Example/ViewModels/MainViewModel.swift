//
//  MainViewModel.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 21.03.2023.
//

import Foundation

struct MainViewModel {
    let api: ProductsAPI
    let userdefaults = UserDefaults.standard
    var currency: String {
        return userdefaults.getCurrency(fromKey: Keys.currency)
    }

    init(api: ProductsAPI) {
        self.api = api
    }

    func loadItems(completion: @escaping (Result<[ItemViewModel], Error>) -> Void) {
        api.loadProducts { result in
            DispatchQueue.mainAsyncIfNeeded {
                completion(result.map { items in
                    return items.map { item in
                        ItemViewModel(product: item)
                    }
                })
            }
        }
    }
}
