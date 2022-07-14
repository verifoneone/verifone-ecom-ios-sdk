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

public enum Env {
    public static var CST = "CST"
    public static var CST_FOR_REUSE_TOKEN = "CST_FOR_REUSE_TOKEN"
}

public enum Keys {
    public static var AppleLanguages = "AppleLanguages"
    public static var Font = "Font"
}

public protocol MerchantAppConfigProtocol {
    var basicAuthUserId: String! { get set }
    var basicAuthUserKey: String! { get set }
    var paymentProviderContract: String! { get set }
}

struct MerchantAppConfig: MerchantAppConfigProtocol {
    
    static var shared = MerchantAppConfig()
    
    public static var baseURL =  "https://cst.test-gsc.vfims.com/oidc"
    public var basicAuthUserId: String!
    public var basicAuthUserKey: String!
    public var paymentProviderContract: String!
    public var paypalPaymentProviderContract: String!
    public var threedsContractID: String!
    public var cardEncryptionPublicKey: String!
    public var publicKeyAlias: String!
    public static var expectedSuccessURL = "https://verifone.cloud"
    public static var expectedCancellURL = "https://verifone.cloud"
    
    var bundle: Bundle!
    private var _font: UIFont?
    private var _allowedPaymentMethods: [VerifoneSDKPaymentTypeValue]? = []
    private var _allPaymentMethods: [VerifoneSDKPaymentTypeValue] = [.creditCard, .paypal, .applePay]
    
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
                _allowedPaymentMethods = [.creditCard, .paypal, .applePay]
            }
            
            return _allowedPaymentMethods!
        }
    }
    
    
    
    init() {
        self.basicAuthUserId = Credentials.basicAuthUserId
        self.basicAuthUserKey = Credentials.basicAuthUserKey
        self.paymentProviderContract = Credentials.paymentProviderContract
        self.cardEncryptionPublicKey = Credentials.cardEncryptionPublicKey
        self.paypalPaymentProviderContract = Credentials.paypalPaymentProviderContract
        self.threedsContractID = Credentials.threedsContractID
        self.publicKeyAlias = Credentials.publicKeyAlias
        self.cardEncryptionPublicKey = Credentials.cardEncryptionPublicKey
        //disable constraints warnings
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        bundle = Bundle.main
    }

    public enum Credentials {
        public static var basicAuthUserId = "{USER_ID}"
        public static var basicAuthUserKey = "{API_KEY}"
        public static var paymentProviderContract = "{CARD_PAYMENT_PROVIDER_CONTRACT_ID}"
        public static var paypalPaymentProviderContract = "{PAYPAL_PAYMENT_PROVIDER_CONTRACT_ID}"
        public static var threedsContractID = "{3DS_CONTRACT_ID}"
        public static var publicKeyAlias = "{PUBLIC_KEY_ALIAS}"
        public static var cardEncryptionPublicKey =  "{PUBLIC_KEY}"
    }
    
    public mutating func setLang(lang: String) {
        var appleLanguages = UserDefaults.standard.object(forKey: Keys.AppleLanguages) as! [String]
        appleLanguages.remove(at: 0)
        appleLanguages.insert(lang, at: 0)
        UserDefaults.standard.set(appleLanguages, forKey: Keys.AppleLanguages)
        UserDefaults.standard.synchronize() //needs restrat
        if let languageDirectoryPath = Bundle.main.path(forResource: lang, ofType: "lproj")  {
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
}

struct PaymentTypeOrder {
    var index: Int
    var paymentType: VerifoneSDKPaymentTypeValue
}
