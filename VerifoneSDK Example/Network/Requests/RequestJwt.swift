//
//  RequestJwt.swift
//  VerifoneTestPaymentApp
//
//  Created by Oraz Atakishiyev on 09.08.2021.
//

import Foundation

public struct RequestJwt: Codable {
    var threedsContractId: String
    
    init(threedsContractId: String) {
        self.threedsContractId = threedsContractId
    }
    
    enum CodingKeys: String, CodingKey {
        case threedsContractId
    }
}
