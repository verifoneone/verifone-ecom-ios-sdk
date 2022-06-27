//
//  RequestTransaction.swift
//  Verifone
//
//  Created by Oraz Atakishiyev on 20.09.2021.
//

import Foundation

public class RequestTransaction: NSObject, Codable {
    public var amount: Int64
    public var authType: String
    public var captureNow: Bool
    public var customer: String?
    public var redirectUrl: String?
    public var entityId: String?
    public var purchaseCountry: String?
    public var cardBrand: String?
    public var currencyCode: String
    public var dynamicDescriptor: String
    public var encryptedCard: String?
    public var merchantReference: String
    public var paymentProviderContract: String
    public var publicKeyAlias: String?
    public var shopperInteraction: String
    public var reuseToken: String?
    public var threedAuthentication: ThreedAuthentication?
    public var walletType: String?
    public var walletPayload: ApplePayToken?
    public var scaComplianceLevel: String?
    public var locale: AppLocale?
    public var lineItems: [LineItem]?
    
    public init(amount: Int64, authType: String, captureNow: Bool, customer: String? = nil, redirectUrl: String? = nil, entityId: String? = nil, purchaseCountry: String? = nil, cardBrand: String? = nil, currencyCode: String, dynamicDescriptor: String, encryptedCard: String? = nil, merchantReference: String, paymentProviderContract: String, publicKeyAlias: String?=nil, shopperInteraction: String, threedAuthentication: ThreedAuthentication? = nil, reuseToken: String? = nil, walletType: String? = nil, walletPayload: ApplePayToken? = nil, scaComplianceLevel: String? = nil, locale: AppLocale? = nil, lineItems: [LineItem]? = []) {
        self.amount = amount
        self.authType = authType
        self.captureNow = captureNow
        self.customer = customer
        self.redirectUrl = redirectUrl
        self.entityId = entityId
        self.purchaseCountry = purchaseCountry
        self.cardBrand = cardBrand
        self.currencyCode = currencyCode
        self.dynamicDescriptor = dynamicDescriptor
        self.encryptedCard = encryptedCard
        self.merchantReference = merchantReference
        self.paymentProviderContract = paymentProviderContract
        self.publicKeyAlias = publicKeyAlias
        self.shopperInteraction = shopperInteraction
        self.threedAuthentication = threedAuthentication
        self.reuseToken = reuseToken
        self.walletType = walletType
        self.walletPayload = walletPayload
        self.scaComplianceLevel = scaComplianceLevel
        self.locale = locale
        self.lineItems = lineItems
    }
}

public class ThreedAuthentication: NSObject, Codable {
    public var cavv: String
    public var dsTransactionId: String?
    public var enrolled: String
    public var errorDesc: String?
    public var errorNo: String?
    public var eciFlag: String
    public var paresStatus: String
    public var signatureVerification: String?
    public var threedsVersion: String
    public var additionalData: AdditionalData?
    
    public init(cavv: String, dsTransactionId: String?, enrolled: String, errorDesc: String?, errorNo: String?, eciFlag: String, paresStatus: String, signatureVerification: String?, threedsVersion: String, additionalData: AdditionalData?) {
        self.cavv = cavv
        self.dsTransactionId = dsTransactionId
        self.enrolled = enrolled
        self.errorDesc = errorDesc
        self.errorNo = errorNo
        self.eciFlag = eciFlag
        self.paresStatus = paresStatus
        self.signatureVerification = signatureVerification
        self.threedsVersion = threedsVersion
        self.additionalData = additionalData
    }
    
    enum CodingKeys: String, CodingKey {
        case cavv = "cavv"
        case dsTransactionId = "ds_transaction_id"
        case enrolled = "enrolled"
        case errorDesc = "error_desc"
        case errorNo = "error_no"
        case eciFlag = "eci_flag"
        case paresStatus = "pares_status"
        case signatureVerification = "signature_verification"
        case threedsVersion = "threeds_version"
        case additionalData = "additional_data"
    }
}

public class AdditionalData: NSObject, Codable {
    public var deviceChannel: String?
    public var acsUrl: String?
    public let acquirerResponseCode, initiatorTraceID: String?
    
    public init(deviceChannel: String?, acsUrl: String?, acquirerResponseCode: String? = nil, initiatorTraceID: String? = nil) {
        self.deviceChannel = deviceChannel
        self.acsUrl = acsUrl
        self.acquirerResponseCode = acquirerResponseCode
        self.initiatorTraceID = initiatorTraceID
    }
    
    enum CodingKeys: String, CodingKey {
        case acquirerResponseCode = "acquirer_response_code"
        case initiatorTraceID = "initiator_trace_id"
    }
}

public class AppLocale: NSObject, Codable {
    let countryCode, language: String

    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case language
    }

    init(countryCode: String, language: String) {
        self.countryCode = countryCode
        self.language = language
    }
}

public class LineItem: NSObject, Codable {
    let imageURL: String
    let type, reference, name: String
    let quantity, unitPrice, taxRate, discountAmount: Int
    let totalTaxAmount, totalAmount: Int
    let sku, lineItemDescription, category: String

    enum CodingKeys: String, CodingKey {
        case imageURL = "image_url"
        case type, reference, name, quantity
        case unitPrice = "unit_price"
        case taxRate = "tax_rate"
        case discountAmount = "discount_amount"
        case totalTaxAmount = "total_tax_amount"
        case totalAmount = "total_amount"
        case sku
        case lineItemDescription = "description"
        case category
    }

    init(imageURL: String, type: String, reference: String, name: String, quantity: Int, unitPrice: Int, taxRate: Int, discountAmount: Int, totalTaxAmount: Int, totalAmount: Int, sku: String, lineItemDescription: String, category: String) {
        self.imageURL = imageURL
        self.type = type
        self.reference = reference
        self.name = name
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.taxRate = taxRate
        self.discountAmount = discountAmount
        self.totalTaxAmount = totalTaxAmount
        self.totalAmount = totalAmount
        self.sku = sku
        self.lineItemDescription = lineItemDescription
        self.category = category
    }
}

public class AuthToken: NSObject, Codable {
    let authorizationToken: String
    
    init(authorizationToken: String) {
        self.authorizationToken = authorizationToken
    }
}
