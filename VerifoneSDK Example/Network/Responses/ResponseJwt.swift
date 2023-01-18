//
//  ResponseJwt.swift
//  VerifoneTestPaymentApp
//
//  Created by Oraz Atakishiyev on 09.08.2021.
//

import Foundation

class ResponseJwt: Codable {
    var jwt, threedsContractId: String

    init(jwt: String, threedsContractId: String) {
        self.jwt = jwt
        self.threedsContractId = threedsContractId
    }

    private enum CodingKeys: String, CodingKey {
            case jwt, threedsContractId = "threeds_contract_id"
    }
}
