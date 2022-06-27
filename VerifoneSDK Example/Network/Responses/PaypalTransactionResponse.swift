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
    let payer: Payer

    enum CodingKeys: String, CodingKey {
        case id
        case authorizationID = "authorizationId"
        case createdAt, expiresAt, status, instoreReference, payer
    }
}

// MARK: - Payer
struct Payer: Codable {
    let payerID: String
    let name: Name
    let phoneNumber: PhoneNumber
    let authorizationStatus, email: String
    let shippingAddress: ShippingAddress

    enum CodingKeys: String, CodingKey {
        case payerID = "payerId"
        case name, phoneNumber, authorizationStatus, email, shippingAddress
    }
}

// MARK: - Name
struct Name: Codable {
    let firstName, lastName: String
}

// MARK: - ShippingAddress
struct ShippingAddress: Codable {
    let fullName, country, postalCode, countrySubdivision: String
    let city, addressLine1, addressLine2: String
}
