//
//  TransactionResponse.swift
//  Verifone
//
//  Created by Oraz Atakishiyev on 20.09.2021.
//

import Foundation

// MARK: - TransactionResponse
public struct TransactionResponse: Codable {
    public let id, paymentProviderContract: String?
    public let merchantReference, paymentProduct, status, authorizationCode, createdBy: String?
    public let cvvPresent: Bool?
    public let cvvResult: String?
    public let reasonCode, rrn, shopperInteraction, stan: String?
    public let threedAuthentication: ThreedAuthentication?
    public let reversalStatus: String?
    public let clientToken: String?
    public let instoreReference, customer: String?
    public let paymentRequestToken: String?
    public let redirectUrl: String?
    let additionalData: AdditionalData?

    enum CodingKeys: String, CodingKey {
        case id
        case paymentProviderContract = "payment_provider_contract"
        case merchantReference = "merchant_reference"
        case paymentProduct = "payment_product"
        case status
        case createdBy = "created_by"
        case cvvPresent = "cvv_present"
        case cvvResult = "cvv_result"
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
        case customer = "customer"
        case paymentRequestToken = "payment_request_token"
        case redirectUrl = "redirect_url"
    }
}
