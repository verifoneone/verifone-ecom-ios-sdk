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
    var apiUserID, apiKey, tokenScope, customer, redirectUrl, entityId: String?

    enum CodingKeys: String, CodingKey {
        case publicKeyAlias = "public_key_alias"
        case threedsContractID = "threeds_contract_id"
        case encryptionKey = "encryption_key"
        case paymentProviderContract = "payment_provider_contract"
        case apiUserID = "api_user_id"
        case apiKey = "api_key"
        case tokenScope = "token_scope"
        case customer = "customer"
        case redirectUrl = "redirect_url"
        case entityId = "entity_id"
    }

    var areCreditCardFieldsValid: [String: String] {
        return isValid(fields: [
            ParamType.apiKey.rawValue,
            ParamType.apiUserID.rawValue,
            ParamType.publicKeyAlias.rawValue,
            ParamType.encryptionKey.rawValue,
            ParamType.paymentProviderContract.rawValue])
    }

    var areGiftCardFieldsValid: [String: String] {
        return isValid(fields: [ParamType.paymentProviderContract.rawValue])
    }

    var areKlarnaFieldsValid: [String: String] {
        return isValid(fields: [
            ParamType.apiKey.rawValue,
            ParamType.apiUserID.rawValue,
            ParamType.customer.rawValue,
            ParamType.entityId.rawValue])
    }

    var arePaypalFieldsValid: [String: String] {
        return isValid(fields: [
            ParamType.apiKey.rawValue,
            ParamType.apiUserID.rawValue,
            ParamType.paymentProviderContract.rawValue,
            ParamType.entityId.rawValue])
    }

    var areSwishFieldsValid: [String: String] {
        return isValid(fields: [
            ParamType.apiKey.rawValue,
            ParamType.apiUserID.rawValue,
            ParamType.entityId.rawValue])
    }

    var areVippsFieldsValid: [String: String] {
        return isValid(fields: [
            ParamType.apiKey.rawValue,
            ParamType.apiUserID.rawValue,
            ParamType.paymentProviderContract.rawValue,
            ParamType.customer.rawValue])
    }

    func isValid(fields: [String]) -> [String: String] {
        let mirror = Mirror(reflecting: self)
        var properties = [String: String]()
        for child in mirror.children {
            guard let label = child.label, let value = child.value as? String else {
                continue
            }
            properties[label] = value
        }

        var invalidProperties = [String: String]()
        for field in fields {
            if let value = properties[field], !value.isEmpty {
                continue
            }
            invalidProperties[field] = properties[field] ?? ""
        }

        return invalidProperties
    }

    func validateByPayment(_ method: AppPaymentMethodType) -> [String: String]? {
        switch method {
        case .creditCard:
            return areCreditCardFieldsValid
        case .giftCard:
            return areGiftCardFieldsValid
        case .klarna:
            return areKlarnaFieldsValid
        case .paypal:
            return arePaypalFieldsValid
        case .swish:
            return areSwishFieldsValid
        case .vipps, .mobilePay:
            return areVippsFieldsValid
        default:
            return [:]
        }
    }
}

extension Parameters {
    static var creditCard: Parameters? {
        guard let params = UserDefaults.standard.retrieve(object: Parameters.self, fromKey: AppPaymentMethodType.creditCard.rawValue) else {
            return nil
        }
        if ([params.apiKey, params.apiUserID, params.publicKeyAlias, params.encryptionKey, params.paymentProviderContract] as [String?]).contains(where: {$0 == nil || $0!.isEmpty}) {
            return nil
        }
        return params
    }

    static var giftCard: Parameters? {
        guard let params = UserDefaults.standard.retrieve(object: Parameters.self, fromKey: AppPaymentMethodType.giftCard.rawValue) else {
            return nil
        }
        if ([params.paymentProviderContract] as [String?]).contains(where: {$0 == nil || $0!.isEmpty}) {
            return nil
        }
        return params
    }

    static var klarna: Parameters? {
        guard let params = UserDefaults.standard.retrieve(object: Parameters.self, fromKey: AppPaymentMethodType.klarna.rawValue) else {
            return nil
        }
        if ([params.apiKey, params.apiUserID, params.customer, params.entityId] as [String?]).contains(where: {$0 == nil || $0!.isEmpty}) {
            return nil
        }
        return params
    }

    static var applePay: Parameters? {
//        guard let params = UserDefaults.standard.retrieve(object: Parameters.self, fromKey: AppPaymentMethodType.applePay.rawValue) else {
//            return nil
//        }
        return nil
    }

    static var paypal: Parameters? {
        guard let params = UserDefaults.standard.retrieve(object: Parameters.self, fromKey: AppPaymentMethodType.paypal.rawValue) else {
            return nil
        }
        if ([params.apiKey, params.apiUserID, params.paymentProviderContract, params.entityId] as [String?]).contains(where: {$0 == nil || $0!.isEmpty}) {
            return nil
        }
        return params
    }

    static var swish: Parameters? {
        guard let params = UserDefaults.standard.retrieve(object: Parameters.self, fromKey: AppPaymentMethodType.swish.rawValue) else {
            return nil
        }
        if ([params.apiKey, params.apiUserID, params.entityId] as [String?]).contains(where: {$0 == nil || $0!.isEmpty}) {
            return nil
        }
        return params
    }

    static var vipps: Parameters? {
        guard let params = UserDefaults.standard.retrieve(object: Parameters.self, fromKey: AppPaymentMethodType.vipps.rawValue) else {
            return nil
        }
        if ([params.apiKey, params.apiUserID, params.paymentProviderContract, params.customer] as [String?]).contains(where: {$0 == nil || $0!.isEmpty}) {
            return nil
        }
        return params
    }

    static var mobilePay: Parameters? {
        guard let params = UserDefaults.standard.retrieve(object: Parameters.self, fromKey: AppPaymentMethodType.mobilePay.rawValue) else {
            return nil
        }
        if ([params.apiKey, params.apiUserID, params.paymentProviderContract, params.customer] as [String?]).contains(where: {$0 == nil || $0!.isEmpty}) {
            return nil
        }
        return params
    }
}
