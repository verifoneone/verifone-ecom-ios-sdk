//
//  PaypalTransactionResponse.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 07.02.2022.
//

import Foundation

struct PaypalTransactionInitiate: Codable {
    let id, status, orderID: String
    let createdAt: String
    let instoreReference: String
    let approvalURL: String

    enum CodingKeys: String, CodingKey {
        case id, status
        case orderID = "orderId"
        case createdAt, instoreReference
        case approvalURL = "approvalUrl"
    }
}

// MARK: - PaypalTransactionResponse
struct PaypalTransactionResponse: Codable {
    let id, authorizationID: String
    let createdAt, expiresAt: String
    let status, instoreReference: String

    enum CodingKeys: String, CodingKey {
        case id
        case authorizationID = "authorizationId"
        case createdAt, expiresAt, status, instoreReference
    }
}
