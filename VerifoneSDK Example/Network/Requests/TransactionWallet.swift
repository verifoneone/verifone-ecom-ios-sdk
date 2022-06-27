//
//  TransactionWallet.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 06.10.2021.
//

import Foundation
import VerifoneSDK

// MARK: - TransactionWallet
class TransactionWallet: Codable {
    let paymentProviderContract: String?
    let amount: Int?
    let authType: String?
    let captureNow: Bool?
    let customer, customerIP, dynamicDescriptor, merchantReference: String?
    let threedAuthentication: ThreedAuthentication?
    let storedCredential: StoredCredential?
    let shippingInformation: ShippingInformation?
    let shopperInteraction, userAgent, scaExemption, currencyCode: String?
    let cardBrand, brandChoice, refusalReason: String?
    let tokenPreference: TokenPreference?
    let walletType: String?
    let scaComplianceLevel: String?

    enum CodingKeys: String, CodingKey {
        case paymentProviderContract = "payment_provider_contract"
        case amount
        case authType = "auth_type"
        case captureNow = "capture_now"
        case customer
        case customerIP = "customer_ip"
        case dynamicDescriptor = "dynamic_descriptor"
        case merchantReference = "merchant_reference"
        case threedAuthentication = "threed_authentication"
        case storedCredential = "stored_credential"
        case shippingInformation = "shipping_information"
        case shopperInteraction = "shopper_interaction"
        case userAgent = "user_agent"
        case scaExemption = "sca_exemption"
        case currencyCode = "currency_code"
        case cardBrand = "card_brand"
        case brandChoice = "brand_choice"
        case refusalReason = "refusal_reason"
        case tokenPreference = "token_preference"
        case walletType = "wallet_type"
//        case walletPayload = "wallet_payload"
        case scaComplianceLevel = "sca_compliance_level"
    }

    init(paymentProviderContract: String?, amount: Int?, authType: String?, captureNow: Bool?, customer: String?, customerIP: String?, dynamicDescriptor: String?, merchantReference: String?, threedAuthentication: ThreedAuthentication?, storedCredential: StoredCredential?, shippingInformation: ShippingInformation?, shopperInteraction: String?, userAgent: String?, scaExemption: String?, currencyCode: String?, cardBrand: String?, brandChoice: String?, refusalReason: String?, tokenPreference: TokenPreference?, walletType: String?, scaComplianceLevel: String?) {
        self.paymentProviderContract = paymentProviderContract
        self.amount = amount
        self.authType = authType
        self.captureNow = captureNow
        self.customer = customer
        self.customerIP = customerIP
        self.dynamicDescriptor = dynamicDescriptor
        self.merchantReference = merchantReference
        self.threedAuthentication = threedAuthentication
        self.storedCredential = storedCredential
        self.shippingInformation = shippingInformation
        self.shopperInteraction = shopperInteraction
        self.userAgent = userAgent
        self.scaExemption = scaExemption
        self.currencyCode = currencyCode
        self.cardBrand = cardBrand
        self.brandChoice = brandChoice
        self.refusalReason = refusalReason
        self.tokenPreference = tokenPreference
        self.walletType = walletType
        self.scaComplianceLevel = scaComplianceLevel
    }
}

// MARK: - ShippingInformation
class ShippingInformation: Codable {
    let address, city, country, postalCode: String?
    let email, firstName, lastName: String?
    let phone: Int?
    let state: String?

    enum CodingKeys: String, CodingKey {
        case address, city, country
        case postalCode = "postal_code"
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case phone, state
    }

    init(address: String?, city: String?, country: String?, postalCode: String?, email: String?, firstName: String?, lastName: String?, phone: Int?, state: String?) {
        self.address = address
        self.city = city
        self.country = country
        self.postalCode = postalCode
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.state = state
    }
}

// MARK: - StoredCredential
class StoredCredential: Codable {
    let storedCredentialType: String?

    enum CodingKeys: String, CodingKey {
        case storedCredentialType = "stored_credential_type"
    }

    init(storedCredentialType: String?) {
        self.storedCredentialType = storedCredentialType
    }
}

// MARK: - TokenPreference
class TokenPreference: Codable {
    let tokenScope, tokenType, tokenExpiryDate: String?

    enum CodingKeys: String, CodingKey {
        case tokenScope = "token_scope"
        case tokenType = "token_type"
        case tokenExpiryDate = "token_expiry_date"
    }

    init(tokenScope: String?, tokenType: String?, tokenExpiryDate: String?) {
        self.tokenScope = tokenScope
        self.tokenType = tokenType
        self.tokenExpiryDate = tokenExpiryDate
    }
}


