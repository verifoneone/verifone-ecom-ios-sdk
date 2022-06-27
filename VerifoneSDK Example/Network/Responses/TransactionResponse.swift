//
//  TransactionResponse.swift
//  Verifone
//
//  Created by Oraz Atakishiyev on 20.09.2021.
//

import Foundation

// MARK: - TransactionResponse
public class TransactionResponse: Codable {
    public let id, paymentProviderContract: String?
    public let amount: Int?
    public let blocked: Bool?
    public let merchantReference, paymentProduct, status, authorizationCode, createdBy: String?
    public let cvvPresent: Bool?
    public let cvvResult: String?
    public let details: Details?
    public let reasonCode, rrn, shopperInteraction, stan: String?
    public let threedAuthentication: ThreedAuthentication?
    public let reversalStatus: String?
    public let clientToken: String?
    public let instoreReference: String?
    let additionalData: AdditionalData?

    enum CodingKeys: String, CodingKey {
        case id
        case paymentProviderContract = "payment_provider_contract"
        case amount, blocked
        case merchantReference = "merchant_reference"
        case paymentProduct = "payment_product"
        case status
        case createdBy = "created_by"
        case cvvPresent = "cvv_present"
        case cvvResult = "cvv_result"
        case details
        case reasonCode = "reason_code"
        case rrn
        case shopperInteraction = "shopper_interaction"
        case stan
        case threedAuthentication = "threed_authentication"
        case reversalStatus = "reversal_status"
        case additionalData = "additional_data"
        case authorizationCode = "authorization_code"
        case clientToken = "client_token"
        case instoreReference = "instore_reference"
    }

    public init(id: String?, paymentProviderContract: String?, amount: Int?, blocked: Bool?, merchantReference: String?, paymentProduct: String?, status: String?, createdBy: String?, cvvPresent: Bool?, cvvResult: String?, details: Details?, reasonCode: String?, rrn: String?, shopperInteraction: String?, stan: String?, threedAuthentication: ThreedAuthentication?, reversalStatus: String?, authorizationCode: String?, additionalData: AdditionalData?, clientToken: String?, instoreReference: String?) {
        self.id = id
        self.paymentProviderContract = paymentProviderContract
        self.amount = amount
        self.blocked = blocked
        self.merchantReference = merchantReference
        self.paymentProduct = paymentProduct
        self.status = status
        self.createdBy = createdBy
        self.cvvPresent = cvvPresent
        self.cvvResult = cvvResult
        self.details = details
        self.reasonCode = reasonCode
        self.rrn = rrn
        self.shopperInteraction = shopperInteraction
        self.stan = stan
        self.threedAuthentication = threedAuthentication
        self.reversalStatus = reversalStatus
        self.additionalData = additionalData
        self.authorizationCode = authorizationCode
        self.clientToken = clientToken
        self.instoreReference = instoreReference
    }
}

// MARK: - Details
public class Details: Codable {
    let autoCapture: Bool?

    enum CodingKeys: String, CodingKey {
        case autoCapture = "auto_capture"
    }

    public init(autoCapture: Bool?) {
        self.autoCapture = autoCapture
    }
}
