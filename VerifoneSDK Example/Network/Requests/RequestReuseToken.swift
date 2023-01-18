//
//  RequestReuseToken.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 15.12.2021.
//

import Foundation

class RequestReuseToken: Codable {
    var tokenScope: String
    var encryptedCard: String
    var publicKeyAlias: String
    var tokenType: String
    var tokenExpiryDate: String

    init(tokenScope: String,
         encryptedCard: String,
         publicKeyAlias: String,
         tokenType: String,
         tokenExpiryDate: String) {

        self.tokenScope = tokenScope
        self.encryptedCard = encryptedCard
        self.publicKeyAlias = publicKeyAlias
        self.tokenType = tokenType
        self.tokenExpiryDate = tokenExpiryDate
    }

}
