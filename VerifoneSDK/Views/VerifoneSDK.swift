//
//  VerifoneSDK.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 04.10.2021.
//

import Foundation
import PassKit

public final class VerifoneSDK: NSObject {
    static public weak var paymentConfiguration: PaymentConfiguration?
    static public weak var threedsConfiguration: ThreedsConfiguration?
    static public weak var applePayMerchantConfiguration: ApplePayMerchantConfiguration?
    static public var defaultTheme = Theme.defaultTheme
    static public var defaultFont: UIFont! = UIFont.systemFont(ofSize: 15, weight: .regular)
    public typealias authorizeCompletion = (() -> Void)?

    static public var locale: Locale? {
        didSet {
            _ = createBundle()
        }
    }

    fileprivate static let bundleIdentifier = "com.verifone.sdk"
    fileprivate static var bundle: Bundle = createBundle()
    fileprivate static var walletAppCompletion: (() -> Void)?

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

public extension VerifoneSDK {
    class PaymentConfiguration: NSObject {
        public let cardEncryptionPublicKey: String?
        public let paymentPanelStoreTitle: String
        public var showCardSaveSwitch: Bool = true
        public var totalAmount: String
        public var allowedPaymentMethods: [VerifonePaymentMethodType] = [.creditCard, .paypal]
        public var reuseTokenForCardPayment: Bool
        public var reuseTokenForGiftCardPayment: Bool

        public init(cardEncryptionPublicKey: String? = nil, totalAmount: String, showCardSaveSwitch: Bool = false, allowedPaymentMethods: [VerifonePaymentMethodType], reuseTokenForCardPayment: Bool = false, reuseTokenForGiftCardPayment: Bool = false) {
            self.cardEncryptionPublicKey = cardEncryptionPublicKey
            self.paymentPanelStoreTitle = "Store"
            self.totalAmount = totalAmount
            self.showCardSaveSwitch = showCardSaveSwitch
            self.allowedPaymentMethods = allowedPaymentMethods
            self.reuseTokenForCardPayment = reuseTokenForCardPayment
            self.reuseTokenForGiftCardPayment = reuseTokenForGiftCardPayment
        }

        public init(cardEncryptionPublicKey: String? = nil, paymentPanelStoreTitle: String = "", totalAmount: String, showCardSaveSwitch: Bool = false, allowedPaymentMethods: [VerifonePaymentMethodType], reuseTokenForCardPayment: Bool = false, reuseTokenForGiftCardPayment: Bool = false) {
            self.cardEncryptionPublicKey = cardEncryptionPublicKey
            self.paymentPanelStoreTitle = paymentPanelStoreTitle
            self.showCardSaveSwitch = showCardSaveSwitch
            self.totalAmount = totalAmount
            self.allowedPaymentMethods = allowedPaymentMethods
            self.reuseTokenForCardPayment = reuseTokenForCardPayment
            self.reuseTokenForGiftCardPayment = reuseTokenForGiftCardPayment
        }
    }

    class ThreedsConfiguration: NSObject {
        public let environment: Environment

        public init(environment: Environment = .staging) {
            self.environment = environment
        }
    }

    class ApplePayMerchantConfiguration: NSObject {
        public let applePayMerchantId: String
        public let supportedPaymentNetworks: [PKPaymentNetwork]
        public let countryCode: String
        public let currencyCode: String
        public let paymentSummaryItems: [PKPaymentSummaryItem]
        public let merchantCapability: PKMerchantCapability
        public let requiredShippingContactFields: Set<PKContactField>
        public let requiredBillingContactFields: Set<PKContactField>
        public let supportedNetworks: [PKPaymentNetwork]
        public let shippingMethods: [PKShippingMethod]?
        public let billingContact: PKContact?
        public let shippingContact: PKContact?
        public let shippingType: PKShippingType?

        public init(applePayMerchantId: String,
                    supportedPaymentNetworks: [PKPaymentNetwork],
                    countryCode: String,
                    currencyCode: String,
                    paymentSummaryItems: [PKPaymentSummaryItem],
                    merchantCapability: PKMerchantCapability = .capability3DS,
                    requiredShippingContactFields: Set<PKContactField>,
                    requiredBillingContactFields: Set<PKContactField>,
                    supportedNetworks: [PKPaymentNetwork],
                    shippingMethods: [PKShippingMethod]? = nil,
                    billingContact: PKContact? = nil, shippingContact: PKContact? = nil, shippingType: PKShippingType? = nil) {
            self.applePayMerchantId = applePayMerchantId
            self.supportedPaymentNetworks = supportedPaymentNetworks
            self.countryCode = countryCode
            self.currencyCode = currencyCode
            self.paymentSummaryItems = paymentSummaryItems
            self.merchantCapability = merchantCapability
            self.requiredShippingContactFields = requiredShippingContactFields
            self.requiredBillingContactFields = requiredBillingContactFields
            self.supportedNetworks = supportedNetworks
            self.shippingMethods = shippingMethods
            self.billingContact = billingContact
            self.shippingContact = shippingContact
            self.shippingType = shippingType
        }
    }
}

private extension VerifoneSDK {
    static func isAppInstalled(appName: String) -> Bool {
        guard let url = URL(string: appName) else {
            preconditionFailure("Invalid url")
        }
        return UIApplication.shared.canOpenURL(url)
    }

    static func encodedCallbackUrl(callback: String) -> String? {
        let disallowedCharacters = NSCharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]")
        let allowedCharacters = disallowedCharacters.inverted
        return callback.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }

    static func createPaymentURL(host: String? = "", scheme: String, queryItems: [URLQueryItem]) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.host = host
        urlComponents.scheme = scheme
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }

    static func addObservingState() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    static func removeObservingState() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }

    @objc static func applicationDidBecomeActive() {
        removeObservingState()
        callbackFromWalletApp()
    }

    static func callbackFromWalletApp() {
        guard let completion = walletAppCompletion else {
            walletAppCompletion = nil
            return
        }
        completion()
        walletAppCompletion = nil
    }
}

// MARK: - SWISH PAYMENT
public extension VerifoneSDK {
    private static let swishScheme = "swish"

    static func authorizeSwishPayment(token: String, returnUrl: String, completion: authorizeCompletion, failure: authorizeCompletion) {
        guard let callback = encodedCallbackUrl(callback: returnUrl) else {
            failure?()
            return
        }
        let queryItems = [URLQueryItem(name: "token", value: token), URLQueryItem(name: "callbackurl", value: callback)]
        if let url = createPaymentURL(host: "paymentrequest", scheme: swishScheme, queryItems: queryItems), UIApplication.shared.canOpenURL(url) {
            if let completion = completion {
                walletAppCompletion = completion
                addObservingState()
            }
            DispatchQueue.main.async {
                UIApplication.shared.open(url) { success in
                    if !success { failure?() }
                }
            }
        } else {
            failure?()
        }
    }

    static func isSwishAppAvailable() -> Bool {
        return isAppInstalled(appName: "\(swishScheme)://")
    }
}

// MARK: - VIPPS PAYMENT
public extension VerifoneSDK {
    private static let vippsScheme = "vipps"

    static func authorizeVippsPayment(token: String, returnUrl: String, completion: authorizeCompletion, failure: authorizeCompletion) {
        guard let callback = encodedCallbackUrl(callback: returnUrl) else {
            failure?()
            return
        }
        let queryItems = [URLQueryItem(name: "token", value: token), URLQueryItem(name: "fallBack", value: callback)]
        if let url = createPaymentURL(scheme: vippsScheme, queryItems: queryItems), UIApplication.shared.canOpenURL(url) {
            if let completion = completion {
                walletAppCompletion = completion
                addObservingState()
            }
            DispatchQueue.main.async {
                UIApplication.shared.open(url) { success in
                    if !success { failure?() }
                }
            }
        } else {
            failure?()
        }
    }

    static func isVippsAppAvailable() -> Bool {
        return isAppInstalled(appName: "\(vippsScheme)://")
    }
}

// MARK: - MOBILE PAY PAYMENT
public extension VerifoneSDK {
    private static let mobilePayScheme = "mobilepay"

    static func authorizeMobilePayPayment(token: String, returnUrl: String, completion: authorizeCompletion, failure: authorizeCompletion) {
        guard let callback = encodedCallbackUrl(callback: returnUrl) else {
            failure?()
            return
        }
        let queryItems = [URLQueryItem(name: "paymentid", value: token), URLQueryItem(name: "redirect_url", value: callback)]
        if let url = createPaymentURL(host: "online", scheme: mobilePayScheme, queryItems: queryItems), UIApplication.shared.canOpenURL(url) {
            if let completion = completion {
                walletAppCompletion = completion
                addObservingState()
            }
            DispatchQueue.main.async {
                UIApplication.shared.open(url) { success in
                    if !success { failure?() }
                }
            }
        } else {
            failure?()
        }
    }

    static func isMobilePayAppAvailable() -> Bool {
        return isAppInstalled(appName: "\(mobilePayScheme)://")
    }
}
