//
//  VerifoneSDK.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 04.10.2021.
//

import Foundation
import PassKit
import os

@objc public final class VerifoneSDK: NSObject {
    static public weak var paymentConfiguration: PaymentConfiguration?
    static public weak var threedsConfiguration: ThreedsConfiguration?
    static public weak var applePayMerchantConfiguration: ApplePayMerchantConfiguration?
    static public var defaultTheme = Theme.defaultTheme
    static public var defaultFont: UIFont! = UIFont.systemFont(ofSize: 15, weight: .regular)
    
    static public var locale: Locale?
    {
        didSet {
            let _ = createBundle()
        }
    }
    
    static let bundleIdentifier = "com.verifone.sdk"
    fileprivate static var bundle: Bundle = createBundle()
    
    private static func createBundle() -> Bundle {
        class Class {}
        guard let localizationBundle = Bundle(identifier: bundleIdentifier)
        else { return Bundle(for: Class.self) }
        
        guard let bundlePath = localizationBundle.path(forResource: currentLanguage(of: localizationBundle),
                ofType: "lproj"),
        let bundle = Bundle(path: bundlePath) else { return Bundle(for: Class.self) }
  
        return bundle
    }
    
    private static func currentLanguage(of bundle: Bundle) -> String {
        guard let locale = locale else {
            return String(Locale.current.identifier.prefix(2))
        }
        return locale.identifier
    }
    
    public static func getBundle() -> Bundle {
        return createBundle()
    }
}

extension VerifoneSDK {
    @objc(VerifoneSDKPaymentConfiguration) public class PaymentConfiguration: NSObject {
        @objc public let cardEncryptionPublicKey: String
        @objc public let paymentPanelStoreTitle: String
        @objc public var showCardSaveSwitch: Bool = true
        @objc public var totalAmount: Int64
        @objc public var allowedPaymentMethods: [VerifoneSDKPaymentTypeValue] = [.creditCard, .paypal]
    
        @objc public init(cardEncryptionPublicKey: String, totalAmount: Int64, showCardSaveSwitch: Bool = false, allowedPaymentMethods: [VerifoneSDKPaymentTypeValue]) {
            self.cardEncryptionPublicKey = cardEncryptionPublicKey
            self.paymentPanelStoreTitle = "Store"
            self.totalAmount = totalAmount
            self.showCardSaveSwitch = showCardSaveSwitch
            self.allowedPaymentMethods = allowedPaymentMethods
        }
        
        @objc public init(cardEncryptionPublicKey: String, paymentPanelStoreTitle: String = "", totalAmount: Int64, showCardSaveSwitch: Bool = false, allowedPaymentMethods: [VerifoneSDKPaymentTypeValue]) {
            self.cardEncryptionPublicKey = cardEncryptionPublicKey
            self.paymentPanelStoreTitle = paymentPanelStoreTitle
            self.showCardSaveSwitch = showCardSaveSwitch
            self.totalAmount = totalAmount
            self.allowedPaymentMethods = allowedPaymentMethods
        }
    }
    
    @objc(VerifoneSDKThreedsConfiguration) public class ThreedsConfiguration: NSObject {
        @objc public let environment: Environment
        
        @objc public init(environment: Environment = .staging) {
            self.environment = environment
        }
    }
    
    @objc(VerifoneSDKApplePayMerchantConfiguration) public class ApplePayMerchantConfiguration: NSObject {
        @objc public let applePayMerchantId: String
        @objc public let supportedPaymentNetworks: [PKPaymentNetwork]
        @objc public let countryCode: String
        @objc public let currencyCode: String
        @objc public let paymentSummaryItems: [PKPaymentSummaryItem]

        @objc public init(applePayMerchantId: String,
                          supportedPaymentNetworks: [PKPaymentNetwork],
                          countryCode: String,
                          currencyCode: String,
                          paymentSummaryItems: [PKPaymentSummaryItem]) {
            self.applePayMerchantId = applePayMerchantId
            self.supportedPaymentNetworks = supportedPaymentNetworks
            self.countryCode = countryCode
            self.currencyCode = currencyCode
            self.paymentSummaryItems = paymentSummaryItems
        }
    }
}

public enum VerifoneError {
    private static let verifoneSDKErrorDomain = "com.verifone.ios.sdk"
    
    enum ErrorType {
        static let merchantNotSupport3DS = "The Merchant account doesn't support 3ds"
        static let invalidMerchantConfiguration = "Invalid merchant configuration setup."
        static let missingCardEncryptionPublicKey = "Missing encryption public key"
        static let invalidPublicKey = "Public key parameter is not a string or is not a valid base64 encoded value."
        static let invalidCardData = "Invalid card data"
        static let cancel = "Cancel"
        static let internalSDKError = "Unhandled error occurred."
    }
    
    public static var invalidPublicKey: NSError {
        return NSError(domain: verifoneSDKErrorDomain,
                       code: 9002,
                       userInfo: [NSLocalizedDescriptionKey: ErrorType.invalidPublicKey])
    }
    
    public static var invalidCardData: NSError {
        return NSError(domain: verifoneSDKErrorDomain,
                       code: 9003,
                       userInfo: [NSLocalizedDescriptionKey: ErrorType.invalidCardData])
    }
    
    static var missingCardEncryptionPublicKey: NSError {
        return NSError(domain: verifoneSDKErrorDomain,
                       code: 9004,
                       userInfo: [NSLocalizedDescriptionKey: ErrorType.missingCardEncryptionPublicKey])
    }
    
    public static var cancel: NSError {
        return NSError(domain: verifoneSDKErrorDomain,
                       code: 9005,
                       userInfo: [NSLocalizedDescriptionKey: ErrorType.cancel])
    }
    
    public static var merchantNotSupport3DS: NSError {
        return NSError(domain: verifoneSDKErrorDomain,
                       code: 9006,
                       userInfo: [NSLocalizedDescriptionKey: ErrorType.merchantNotSupport3DS])
    }
    
    static var invalidMerchantConfigurationError: NSError {
        return NSError(domain: verifoneSDKErrorDomain,
                       code: 9007,
                       userInfo: [NSLocalizedDescriptionKey: ErrorType.invalidMerchantConfiguration])
    }
    
    static var internalSDKError: NSError {
        return NSError(domain: verifoneSDKErrorDomain,
                       code: 9008,
                       userInfo: [NSLocalizedDescriptionKey: ErrorType.internalSDKError])
    }
}

public enum VFError: Int {
    // ApplePay
    case cantMakePaymentError
    case applePayOperationError
    case applePayCanceled
}
