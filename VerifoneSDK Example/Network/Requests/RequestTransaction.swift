//
//  RequestTransaction.swift
//  Verifone
//
//  Created by Oraz Atakishiyev on 20.09.2021.
//

import Foundation

public struct RequestTransaction: Codable {
    public var amount: Int?
    public var authType: String?
    public var captureNow: Bool?
    public var customer: String?
    public var redirectUrl: String?
    public var entityId: String?
    public var purchaseCountry: String?
    public var cardBrand: String?
    public var currencyCode: String?
    public var dynamicDescriptor: String?
    public var encryptedCard: String?
    public var merchantReference: String?
    public var paymentProviderContract: String?
    public var publicKeyAlias: String?
    public var shopperInteraction: String?
    public var reuseToken: String?
    public var threedAuthentication: ThreedAuthentication?
    public var walletType: String?
    public var walletPayload: ApplePayToken?
    public var scaComplianceLevel: String?
    public var locale: AppLocale?
    public var lineItems: [LineItem]?
    public var isApp: Bool?
}

extension RequestTransaction {
    static let creditCard: Self = .init(
        authType: "FINAL_AUTH",
        captureNow: true,
        dynamicDescriptor: "M.reference",
        merchantReference: "TEST-ECOM-iOS",
        shopperInteraction: "ECOMMERCE"
    )

    static let klarna: RequestTransaction = .init(
        authType: "FINAL_AUTH",
        captureNow: false,
        purchaseCountry: "SE",
        dynamicDescriptor: "TEST AUTOMATION ECOM",
        merchantReference: "5678-iOS",
        shopperInteraction: "",
        locale: AppLocale(countryCode: "SE", language: "en"),
        lineItems: []
    )

    static let applePay: RequestTransaction = .init(
        authType: "FINAL_AUTH",
        captureNow: true,
        dynamicDescriptor: "abc123",
        merchantReference: "TEST-ECOM123",
        shopperInteraction: "ECOMMERCE",
        walletType: "APPLE_PAY",
        scaComplianceLevel: "FORCE_3DS"
    )

    static let swish: RequestTransaction = .init(
        captureNow: true,
        merchantReference: "5690-iOS"
    )

    static let vipps: RequestTransaction = .init(
        captureNow: true,
        redirectUrl: Keys.testAppScheme,
        merchantReference: "5690-iOS",
        isApp: true
    )

    static let mobilePay: RequestTransaction = .init(
        authType: "FINAL_AUTH",
        captureNow: true,
        redirectUrl: Keys.testAppScheme,
        merchantReference: "5690-iOS",
        scaComplianceLevel: "WALLET",
        isApp: true
    )

    mutating func setupCreditCardWithout3ds(productPrice: Int, cardBrand: String?, paymentProviderContract: String, publicKeyAlias: String, reuseToken: String?) {
        self.amount = productPrice
        self.cardBrand = cardBrand
        self.paymentProviderContract = paymentProviderContract
        self.publicKeyAlias = publicKeyAlias
        self.reuseToken = reuseToken
        self.currencyCode = UserDefaults.standard.getCurrency(fromKey: Keys.currency)
    }

    mutating func setupCreditCardWith3ds(productPrice: Int, cardBrand: String?, encryptedCard: String, paymentProviderContract: String, publicKeyAlias: String, threedAuthentication: ThreedAuthentication) {
        self.amount = productPrice
        self.cardBrand = cardBrand
        self.encryptedCard = encryptedCard
        self.paymentProviderContract = paymentProviderContract
        self.publicKeyAlias = publicKeyAlias
        self.threedAuthentication = threedAuthentication
        self.currencyCode = UserDefaults.standard.getCurrency(fromKey: Keys.currency)
    }

    mutating func setupKlarna(productPrice: Int, customer: String, entityId: String, redirectUrl: String?) {
        self.amount = productPrice
        self.customer = customer
        self.redirectUrl = redirectUrl
        self.entityId = entityId
        self.currencyCode = UserDefaults.standard.getCurrency(fromKey: Keys.currency)
        self.lineItems = [LineItem(
            imageURL: "https://demo.klarna.se/fashion/kp/media/wysiwyg/Accessoriesbagimg.jpg",
            type: "physical", reference: "AccessoryBag-Ref-ID-0001",
            name: "string", quantity: 1, unitPrice: productPrice,
            taxRate: 0, discountAmount: 0, totalTaxAmount: 0,
            totalAmount: productPrice, sku: "string", lineItemDescription: "string",
            category: "DIGITAL_GOODS")]
        self.redirectUrl = "http://2checkout.com/test"
    }

    mutating func setupApplePay(productPrice: Int, cardBrand: String, paymentProviderContract: String, walletPayload: ApplePayToken) {
        self.amount = productPrice
        self.cardBrand = cardBrand
        self.paymentProviderContract = paymentProviderContract
        self.walletPayload = walletPayload
        self.currencyCode = UserDefaults.standard.getCurrency(fromKey: Keys.currency)
    }

    mutating func setupSwish(productPrice: Int, entityId: String) {
        self.amount = productPrice
        self.entityId = entityId
        self.currencyCode = UserDefaults.standard.getCurrency(fromKey: Keys.currency)
    }

    mutating func setupVipps(productPrice: Int, paymentProviderContract: String, customer: String) {
        self.amount = productPrice
        self.paymentProviderContract = paymentProviderContract
        self.currencyCode = UserDefaults.standard.getCurrency(fromKey: Keys.currency)
        self.customer = customer
    }

    mutating func setupMobilePay(productPrice: Int, paymentProviderContract: String, customer: String) {
        self.amount = productPrice
        self.paymentProviderContract = paymentProviderContract
        self.currencyCode = UserDefaults.standard.getCurrency(fromKey: Keys.currency)
        self.customer = customer
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

    public init(validationResponse: ValidateResponse, dsTransactionID: String?, additionalData: AdditionalData) {
        self.cavv = validationResponse.validationResult?.cavv ?? ""
        self.dsTransactionId = dsTransactionID
        self.enrolled = "Y"
        self.errorDesc = validationResponse.errorDesc ?? ""
        self.errorNo = validationResponse.errorNo ?? ""
        self.eciFlag = validationResponse.validationResult?.eciFlag ?? ""
        self.paresStatus = validationResponse.validationResult?.paresStatus ?? ""
        self.signatureVerification = validationResponse.validationResult?.signatureVerification ?? ""
        self.threedsVersion = "2.1.0"
        self.additionalData = additionalData
    }

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
    let customer: String

    init(authorizationToken: String, customer: String) {
        self.authorizationToken = authorizationToken
        self.customer = customer
    }
}
