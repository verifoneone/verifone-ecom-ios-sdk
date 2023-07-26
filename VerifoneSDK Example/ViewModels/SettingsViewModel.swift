//
//  SettingsViewModel.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 03.04.2023.
//

import UIKit

struct SettingsViewModel {
    var sections = [SettingSection]()
    var paymentStateSwitchButtons: [String: Bool] = [:]
    var cardFormSwitchButtonStates: [String: Bool] = [:]
    var selectedEnvironment: String!
    var selectedFont: String? {
        didSet {
            sections[SettingSections.LangFont.rawValue].cells[1].placeholder = selectedFont!
        }
    }
    var selectedLangCode: String? {
        didSet {
            let name = Locale.current.localizedString(forIdentifier: selectedLangCode!)
            sections[SettingSections.LangFont.rawValue].cells[0].placeholder = name!
        }
    }

    fileprivate var userDefaults = UserDefaults.standard
    fileprivate var merchantAppConfig = MerchantAppConfig.shared
    var defaultColorValues = ["FFFFFF", "FFFFFF", "000000", "364049", "007AFF", "E4E7ED", "FFFFFF", "000000"]

    init() {
        self.configureSections()
    }

    func saveValues() {
        let startIndex = sections[SettingSections.cardCustomization.rawValue].cells.count - 9
        for i in 0..<defaultColorValues.count {
            userDefaults.set(sections[SettingSections.cardCustomization.rawValue].cells[i+startIndex].value.replacingOccurrences(of: "#", with: ""), forKey: "textfield_\(1000+i)")
        }
        
        // save payment options
        userDefaults.set(paymentStateSwitchButtons.filter {$0.value}.map {$0.key}, forKey: Keys.paymentOptions)

        // store language
        if let selectedLang = selectedLangCode {
            MerchantAppConfig.shared.setLang(lang: selectedLang)
        }
        // store font
        if let fontName = selectedFont {
            MerchantAppConfig.shared.setFont(familyName: fontName)
        }
        if let env = selectedEnvironment {
            userDefaults.set(env, forKey: Keys.environment)
        }
        // store card form switch button states
        for (key, val) in cardFormSwitchButtonStates {
            userDefaults.set(val, forKey: key)
        }
    }

    mutating func loadPaymentStates() {
        merchantAppConfig.supportedPaymentOptions.forEach({
            let paymentType = AppPaymentMethodType(rawValue: $0.rawValue)!
            let contain = merchantAppConfig.allowedPaymentOptions.contains(paymentType)
            if contain && isParamValid(paymentType) {
                paymentStateSwitchButtons[$0.rawValue] = contain
            } else {
                paymentStateSwitchButtons[$0.rawValue] = false
            }
        })
        cardFormSwitchButtonStates[Keys.isCardSaveEnabled] = userDefaults.booleanValue(for: Keys.isCardSaveEnabled) && !isTokenScopeParamFieldEmpty
        cardFormSwitchButtonStates[Keys.threedsEnabled] = userDefaults.booleanValue(for: Keys.threedsEnabled) && !isThreedsParamFieldEmpty
    }

    mutating func configureSections() {
        self.sections = []
        self.loadPaymentStates()
        self.sections.append(SettingSection(header: "", cells: [
            SettingCellData(type: .linkButton, placeholder: "Region (Env):", value: userDefaults.getEnv(fromKey: Keys.environment), eventType: .region)
        ]))
        self.sections.append(SettingSection(header: "Card Form", cells: [
            SettingCellData(type: .switchButton,
                            placeholder: "Enable card save",
                            value: "",
                            isOn: cardFormSwitchButtonStates[Keys.isCardSaveEnabled]!,
                            eventType: .cardParams),
            SettingCellData(type: .switchButton,
                            placeholder: "Enable 3DS",
                            value: "",
                            isOn: cardFormSwitchButtonStates[Keys.threedsEnabled]!,
                            eventType: .cardParams),
            SettingCellData(type: .seperator,
                            placeholder: "",
                            value: ""),
            SettingCellData(type: .textfield, placeholder: "Backgorund color:", value: userDefaults.string(forKey: "textfield_1000") ?? "FFFFFF", eventType: .textfield),
            SettingCellData(type: .textfield, placeholder: "Textfield background color:", value: userDefaults.string(forKey: "textfield_1001") ?? "FFFFFF", eventType: .textfield),
            SettingCellData(type: .textfield, placeholder: "Textfield text color:", value: userDefaults.string(forKey: "textfield_1002") ?? "000000", eventType: .textfield),
            SettingCellData(type: .textfield, placeholder: "Label color:", value: userDefaults.string(forKey: "textfield_1003") ?? "364049", eventType: .textfield),
            SettingCellData(type: .textfield, placeholder: "Pay button enabled color:", value: userDefaults.string(forKey: "textfield_1004") ?? "007AFF", eventType: .textfield),
            SettingCellData(type: .textfield, placeholder: "Pay button disabled color:", value: userDefaults.string(forKey: "textfield_1005") ?? "E4E7ED", eventType: .textfield),
            SettingCellData(type: .textfield, placeholder: "Pay button text color:", value: userDefaults.string(forKey: "textfield_1006") ?? "FFFFFF", eventType: .textfield),
            SettingCellData(type: .textfield, placeholder: "Card title color:", value: userDefaults.string(forKey: "textfield_1007") ?? "000000", eventType: .textfield),
            SettingCellData(type: .linkButton, placeholder: "Reset to default values", value: "Reset", eventType: .defaultValues)
        ]))

        self.sections.append(SettingSection(header: "", cells: [
            SettingCellData(type: .linkButton, placeholder: MerchantAppConfig.shared.getCurrentLangName(), value: "Change Language", eventType: .langChange),
            SettingCellData(type: .linkButton, placeholder: MerchantAppConfig.shared.getFontName(), value: "Change Font", eventType: .font)
        ]))

        self.sections.append(SettingSection(header: "Stored card tokens", cells: [
            SettingCellData(type: .linkButton, placeholder: "Credit card",
                            value: "Delete token", isOn: userDefaults.hasReuseToken(forKey: Keys.reuseToken),
                            eventType: .reuseToken),
            SettingCellData(type: .linkButton, placeholder: "Gift card",
                            value: "Delete token", isOn: userDefaults.hasReuseToken(forKey: Keys.reuseTokenForGiftCard),
                            eventType: .giftCardReuseToken)
        ]))

        self.sections.append(SettingSection(header: "Payment options and parameters", cells: [
            SettingCellData(type: .switchButton,
                            placeholder: "Credit card",
                            value: "",
                            isOn: paymentStateSwitchButtons[AppPaymentMethodType.creditCard.rawValue]!,
                            paymentType: .creditCard),
            SettingCellData(type: .switchButton,
                            placeholder: "Gift card",
                            value: "",
                            isOn: paymentStateSwitchButtons[AppPaymentMethodType.giftCard.rawValue]!,
                            paymentType: .giftCard),
            SettingCellData(type: .switchButton,
                            placeholder: AppPaymentMethodType.paypal.rawValue,
                            value: "",
                            isOn: paymentStateSwitchButtons[AppPaymentMethodType.paypal.rawValue]!,
                            paymentType: .paypal),
            SettingCellData(type: .switchButton,
                            placeholder: AppPaymentMethodType.applePay.rawValue,
                            value: "",
                            isOn: paymentStateSwitchButtons[AppPaymentMethodType.applePay.rawValue]!,
                            paymentType: .applePay),
            SettingCellData(type: .switchButton,
                            placeholder: AppPaymentMethodType.klarna.rawValue,
                            value: "",
                            isOn: paymentStateSwitchButtons[AppPaymentMethodType.klarna.rawValue]!,
                            paymentType: .klarna),
            SettingCellData(type: .switchButton,
                            placeholder: AppPaymentMethodType.swish.rawValue,
                            value: "",
                            isOn: paymentStateSwitchButtons[AppPaymentMethodType.swish.rawValue]!,
                            paymentType: .swish),
            SettingCellData(type: .switchButton,
                            placeholder: AppPaymentMethodType.vipps.rawValue,
                            value: "",
                            isOn: paymentStateSwitchButtons[AppPaymentMethodType.vipps.rawValue]!,
                            paymentType: .vipps),
            SettingCellData(type: .switchButton,
                            placeholder: AppPaymentMethodType.mobilePay.rawValue,
                            value: "",
                            isOn: paymentStateSwitchButtons[AppPaymentMethodType.mobilePay.rawValue]!,
                            paymentType: .mobilePay)
        ]))
    }

    func isParamValid(_ type: AppPaymentMethodType) -> Bool {
        var params: Parameters?
        switch type {
        case .creditCard:
            params = Parameters.creditCard
        case .giftCard:
            params = Parameters.giftCard
        case .paypal:
            params = Parameters.paypal
        case .applePay:
            params = Parameters.applePay
        case .klarna:
            params = Parameters.klarna
        case .swish:
            params = Parameters.swish
        case .vipps:
            params = Parameters.vipps
        case .mobilePay:
            params = Parameters.mobilePay
        }
        return params != nil
    }

    // check if we have threeds contract id
    var isThreedsParamFieldEmpty: Bool {
        let params = Parameters.creditCard
        return !(params != nil && params?.threedsContractID != nil && !params!.threedsContractID!.isEmpty)
    }

    // check if we have token scope
    var isTokenScopeParamFieldEmpty: Bool {
        let params = Parameters.creditCard
        return !(params != nil && params!.tokenScope != nil && !params!.tokenScope!.isEmpty)
    }
}

struct SettingSection {
    var header: String
    var cells: [SettingCellData]
}

struct SettingCellData {
    var type: SettingCellType
    var placeholder: String
    var value: String
    var isOn: Bool = false
    var eventType: SettingCellEvent?
    var paymentType: AppPaymentMethodType?
}

enum SettingCellType {
    case linkButton
    case switchButton
    case textfield
    case textLabel
    case seperator
}

public enum SettingCellEvent: String {
    case region
    case langChange
    case font
    case textfield
    case defaultValues
    case cardParams
    case paypal
    case reuseToken
    case giftCardReuseToken
    case none
}

enum SettingSections: Int {
    case Region = 0,
         cardCustomization,
         LangFont,
         ReuseToken,
         Options
}
