//
//  VerifonePaymentMethodtype.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 03.04.2023.
//

import Foundation

public enum VerifonePaymentMethodType: String, CaseIterable {
    case creditCard = "Card"
    case giftCard = "Gift card"
    case paypal = "Paypal"
    case applePay = "ApplePay"
    case klarna = "Klarna"
    case swish = "Swish"
    case vipps = "Vipps"
    case mobilePay = "MobilePay"

    static func build(rawValue: String) -> VerifonePaymentMethodType {
        return VerifonePaymentMethodType(rawValue: rawValue) ?? .creditCard
    }
}
