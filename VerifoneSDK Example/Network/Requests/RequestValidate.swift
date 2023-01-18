//
//  RequestValidate.swift
//  VerifoneTestPaymentApp
//
//  Created by Oraz Atakishiyev on 09.08.2021.
//

import Foundation

class RequestValidate: Codable {
    var authenticationId: String
    var jwt: String
    var threedsContractId: String?

    init(authenticationId: String,
         jwt: String,
         threedsContractId: String?) {

        self.authenticationId = authenticationId
        self.jwt = jwt
        self.threedsContractId = threedsContractId
    }
}
