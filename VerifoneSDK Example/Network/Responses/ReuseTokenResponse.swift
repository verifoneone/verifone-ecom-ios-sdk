//
//  ReuseTokenResponse.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 15.12.2021.
//

import Foundation

struct ResponseReuseToken: Codable {
    let reuseToken, bin: String
    let expiryMonth, expiryYear: Int
    let lastFour: String
    let updatedAt, createdAt, tokenExpiryDate, tokenScope: String
    let tokenStatus: String
    var brand: String!

    enum CodingKeys: String, CodingKey {
        case reuseToken = "reuse_token"
        case bin
        case expiryMonth = "expiry_month"
        case expiryYear = "expiry_year"
        case lastFour = "last_four"
        case brand
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case tokenExpiryDate = "token_expiry_date"
        case tokenScope = "token_scope"
        case tokenStatus = "token_status"
    }
    
    mutating func setCardBrand(brand: String) {
        self.brand = brand
    }
}
