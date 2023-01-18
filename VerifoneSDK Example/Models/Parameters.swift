//
//  Parameters.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 10.11.2022.
//

import Foundation

// MARK: - Parameters
struct Parameters: Codable {
    static var shared = Parameters()

    var publicKeyAlias, threedsContractID, encryptionKey, paymentProviderContract: String?
    var apiUserID, apiKey, reuseToken, customer, redirectUrl, entityId: String?
    var organisationId, ppc: String?

    enum CodingKeys: String, CodingKey {
        case publicKeyAlias = "public_key_alias"
        case threedsContractID = "threeds_contract_id"
        case encryptionKey = "encryption_key"
        case paymentProviderContract = "payment_provider_contract"
        case apiUserID = "api_user_id"
        case apiKey = "api_key"
        case reuseToken = "reuse_token"
        case customer = "customer"
        case redirectUrl = "redirect_url"
        case entityId = "entity_id"
        case organisationId = "organisation_id"
        case ppc = "ppc"
    }
}

extension Parameters {
    static var creditCard: Parameters? {
        guard let params = UserDefaults.standard.retrieve(object: Parameters.self, fromKey: PaymentMethodType.creditCard.rawValue) else {
            return nil
        }
        if ([params.apiKey, params.apiUserID, params.publicKeyAlias, params.encryptionKey, params.paymentProviderContract] as [String?]).contains(where: {$0 == nil || $0!.isEmpty}) {
            return nil
        }
        return params
    }

    static var klarna: Parameters? {
        guard let params = UserDefaults.standard.retrieve(object: Parameters.self, fromKey: PaymentMethodType.klarna.rawValue) else {
            return nil
        }
        if ([params.apiKey, params.apiUserID, params.customer, params.organisationId] as [String?]).contains(where: {$0 == nil || $0!.isEmpty}) {
            return nil
        }
        return params
    }

    static var applePay: Parameters? {
        guard let params = UserDefaults.standard.retrieve(object: Parameters.self, fromKey: PaymentMethodType.applePay.rawValue) else {
            return nil
        }
        return params
    }

    static var paypal: Parameters? {
        guard let params = UserDefaults.standard.retrieve(object: Parameters.self, fromKey: PaymentMethodType.paypal.rawValue) else {
            return nil
        }
        return params
    }

    static var swish: Parameters? {
        guard let params = UserDefaults.standard.retrieve(object: Parameters.self, fromKey: PaymentMethodType.swish.rawValue) else {
            return nil
        }
        if ([params.apiKey, params.apiUserID, params.entityId] as [String?]).contains(where: {$0 == nil || $0!.isEmpty}) {
            return nil
        }
        return params
    }

    static var vipps: Parameters? {
        guard let params = UserDefaults.standard.retrieve(object: Parameters.self, fromKey: PaymentMethodType.vipps.rawValue) else {
            return nil
        }
        if ([params.apiKey, params.apiUserID, params.paymentProviderContract, params.customer] as [String?]).contains(where: {$0 == nil || $0!.isEmpty}) {
            return nil
        }
        return params
    }

    static var mobilePay: Parameters? {
        guard let params = UserDefaults.standard.retrieve(object: Parameters.self, fromKey: PaymentMethodType.mobilePay.rawValue) else {
            return nil
        }
        if ([params.apiKey, params.apiUserID, params.paymentProviderContract, params.customer] as [String?]).contains(where: {$0 == nil || $0!.isEmpty}) {
            return nil
        }
        return params
    }
}
