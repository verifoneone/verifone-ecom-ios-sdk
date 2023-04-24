//
//  ItemView.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 21.03.2023.
//

import Foundation

struct ItemViewModel {
    let title: String
    let price: String
    let image: String
    let description: String
}

extension ItemViewModel {
    init(product: Product) {
        title = product.title
        price = product.price
        image = product.image
        description = product.description
    }

    func getPrice() -> Int {
        let price = NSDecimalNumber(string: self.price)
        return Int(truncating: price.multiplying(by: NSDecimalNumber(string: "100")))
    }
}
