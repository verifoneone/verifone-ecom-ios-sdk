//
//  AppConfig.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 15.11.2021.
//

import Foundation
import UIKit
import VerifoneSDK
//
// set "Env.CST_FOR_REUSE_TOKEN" for testing recurrent payments token.
// (doesn't support 3ds)
//
public var GlobalENV = Env.CST

public enum Env: String {
    case CST = "CST"
    case US_CST = "US CST"
    case EMEA_PROD = "EMEA PROD"
    case US_PROD = "US PROD"
    case NZ_PROD = "NZ PROD"
    case CST_FOR_REUSE_TOKEN = "CST_FOR_REUSE_TOKEN"
}

public enum Keys {
    public static var AppleLanguages = "AppleLanguages"
    public static var Font = "Font"
    public static var creditCardParams = "creditCardParams"
    public static var currency = "storedCurrency"
    public static var environment = "environment"
    public static var appSwitchNotificationName = Notification.Name("CallbackFromThirdPartyApp")
    public static var switchedApp = "switchedApp"
}

public protocol MerchantAppConfigProtocol {
    var basicAuthUserId: String? { get set }
    var basicAuthUserKey: String? { get set }
}

struct MerchantAppConfig: MerchantAppConfigProtocol {

    static var shared = MerchantAppConfig()

    public var baseURL: String {
        get {
            return self.urls[UserDefaults.standard.getEnv(fromKey: Keys.environment)]!
        }
    }
    public var isParamsLoaded: Bool = false
    public var basicAuthUserId: String?
    public var basicAuthUserKey: String?
    public var cardEncryptionPublicKey: String?
    public static var expectedSuccessURL = "https://verifone.cloud"
    public static var expectedCancellURL = "https://verifone.cloud"

    var bundle: Bundle!
    private var _font: UIFont?
    private var _allowedPaymentMethods: [VerifoneSDKPaymentTypeValue]? = []
    private var _allPaymentMethods: [VerifoneSDKPaymentTypeValue] = [.creditCard, .paypal, .applePay, .klarna, .swish, .vipps, .mobilePay]

    public var font: UIFont {
        set {
            _font = newValue
            setFont(familyName: _font!.familyName)
        }
        get {
            if let familyName = UserDefaults.standard.string(forKey: Keys.Font), UIFont(name: familyName, size: 15) != nil {
                return UIFont(name: familyName, size: 15)!
            } else if let _font = _font {
                return _font
            } else {
                let fontMetrics = UIFontMetrics(forTextStyle: .body)
                return fontMetrics.scaledFont(for: UIFont.systemFont(ofSize: 15))
            }
        }
    }

    public var allowedPaymentMethods: [VerifoneSDKPaymentTypeValue] {
        set {
            _allowedPaymentMethods = Array(newValue)
        }
        mutating get {
            _allowedPaymentMethods = []
            if let arr = UserDefaults.standard.stringArray(forKey: "paymentMethods") {
                for value in _allPaymentMethods {
                    if arr.contains(value.rawValue) {
                        _allowedPaymentMethods?.append(value)
                        }
                    }
            } else {
                _allowedPaymentMethods = [.creditCard, .paypal, .applePay, .klarna, .swish, .vipps, .mobilePay]
            }

            return _allowedPaymentMethods!
        }
    }

    init() {
        // disable constraints warnings
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        bundle = Bundle.main
        self.setParams(paymentMethodType: .creditCard)
    }

    mutating func setParams(paymentMethodType: PaymentMethodType) {
        guard let params = UserDefaults.standard.retrieve(object: Parameters.self, fromKey: PaymentMethodType.creditCard.rawValue) else {
            isParamsLoaded = false
            return
        }
        self.basicAuthUserId = params.apiUserID ?? ""
        self.basicAuthUserKey = params.apiKey ?? ""
        self.cardEncryptionPublicKey = params.encryptionKey ?? ""
        self.isParamsLoaded = true
    }

    public mutating func setLang(lang: String) {
        var appleLanguages = UserDefaults.standard.object(forKey: Keys.AppleLanguages) as! [String]
        appleLanguages.remove(at: 0)
        appleLanguages.insert(lang, at: 0)
        UserDefaults.standard.set(appleLanguages, forKey: Keys.AppleLanguages)
        UserDefaults.standard.synchronize() // needs restrat
        if let languageDirectoryPath = Bundle.main.path(forResource: lang, ofType: "lproj") {
            bundle = Bundle.init(path: languageDirectoryPath)
        } else {
            resetLocalization()
        }
    }

    public mutating func getLang() -> Locale {
        let appleLanguages = UserDefaults.standard.object(forKey: Keys.AppleLanguages) as! [String]
        let prefferedLanguage = appleLanguages[0]
        if prefferedLanguage.contains("-") {
            let array = prefferedLanguage.components(separatedBy: "-")
            return Locale(identifier: array[0])
        }
        return Locale(identifier: prefferedLanguage)
    }

    public mutating func getCurrentLangName() -> String {
        return getLang().localizedString(forIdentifier: getLang().identifier)!.localizedCapitalized
    }

    mutating func resetLocalization() {
        bundle = Bundle.main
    }

    public mutating func getFontName() -> String {
        return font.familyName
    }

    public mutating func getFont() -> UIFont {
        return font
    }

    mutating func setFont(familyName: String) {
        UserDefaults.standard.set(familyName, forKey: Keys.Font)
    }

    public var currencies: [String] {
        get {
            ["AED", "AFN", "ALL", "AMD", "ANG", "AOA", "ARS", "AUD",
             "AWG", "AZN", "BAM", "BBD", "BDT", "BGN", "BHD", "BIF",
             "BMD", "BND", "BOB", "BOV", "BRL", "BSD", "BTN", "BWP",
             "BYR", "BZD", "CAD", "CDF", "CHE", "CHF", "CHW", "CLF",
             "CLP", "CNY", "COP", "COU", "CRC", "CUC", "CVE", "CZK",
             "DJF", "DKK", "DOP", "DZD", "EGP", "ERN", "ETB", "EUR",
             "FJD", "FKP", "GBP", "GEL", "GHS", "GIP", "GMD", "GNF",
             "GTQ", "GYD", "HKD", "HNL", "HRK", "HTG", "HUF", "IDR",
             "ILS", "INR", "IQD", "IRR", "ISK", "JMD", "JOD", "JPY",
             "KES", "KGS", "KHR", "KMF", "KPW", "KRW", "KWD", "KYD",
             "KZT", "LAK", "LBP", "LKR", "LRD", "LSL", "LTL", "LVL",
             "LYD", "MAD", "MDL", "MGA", "MKD", "MMK", "MNT", "MOP",
             "MRO", "MUR", "MVR", "MWK", "MXN", "MXV", "MYR", "MZN",
             "NAD", "NGN", "NIO", "NOK", "NPR", "NZD", "OMR", "PAB",
             "PEN", "PGK", "PHP", "PKR", "PLN", "PYG", "QAR", "RON",
             "RSD", "RUB", "RWF", "SAR", "SBD", "SCR", "SDG", "SEK",
             "SGD", "SHP", "SLL", "SOS", "SRD", "SSP", "STD", "SVC",
             "SYP", "SZL", "THB", "TJS", "TMT", "TND", "TOP", "TRY",
             "TTD", "TWD", "TZS", "UAH", "UGX", "USD", "USN", "USS",
             "UYI", "UYU", "UZS", "VEF", "VND", "VUV", "WST", "XAF",
             "XAG", "XAU", "XBA", "XBB", "XBC", "XBD", "XCD", "XDR",
             "XOF", "XPD", "XPF", "XPT", "XTS", "XXX", "YER", "ZAR", "ZMK", "ZMW", "BTC"]
        }
        // swiftlint: disable unused_setter_value
        set { }
    }

    public var environments: [String] {
        get {[
                Env.CST.rawValue,
                Env.US_CST.rawValue,
                Env.EMEA_PROD.rawValue,
                Env.US_PROD.rawValue,
                Env.NZ_PROD.rawValue
            ]
        }
    }

    private var urls: [String: String] = [
        Env.CST.rawValue: "https://cst.test-gsc.vfims.com",
        Env.US_CST.rawValue: "https://uscst-gb.gsc.vficloud.net",
        Env.EMEA_PROD.rawValue: "https://gsc.verifone.cloud",
        Env.US_PROD.rawValue: "https://us.gsc.verifone.cloud",
        Env.NZ_PROD.rawValue: "https://nz.gsc.verifone.cloud"
    ]
}

struct PaymentTypeOrder {
    var index: Int
    var paymentType: VerifoneSDKPaymentTypeValue
}
