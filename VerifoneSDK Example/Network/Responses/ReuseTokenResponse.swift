//
//  ReuseTokenResponse.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 15.12.2021.
//

import Foundation

struct ResponseReuseToken: Codable {
    let reuseToken: String
    let updatedAt, createdAt, tokenExpiryDate, tokenScope: String
    let tokenStatus: String

    enum CodingKeys: String, CodingKey {
        case reuseToken = "reuse_token"
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case tokenExpiryDate = "token_expiry_date"
        case tokenScope = "token_scope"
        case tokenStatus = "token_status"
    }
}
