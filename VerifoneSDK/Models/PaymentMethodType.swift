//
//  PaymentMethodType.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 08.02.2022.
//

import Foundation

@objc public enum PaymentMethodType: Int {
    case creditCard
    case applePay
    case paypal
    case klarna
}

extension PaymentMethodType {
    init(_ paymentMethodType: PaymentMethodType) {
        switch paymentMethodType {
        case .creditCard:
            self = .creditCard
        case .applePay:
            self = .applePay
        case .paypal:
            self = .paypal
        case .klarna:
            self = .klarna
        }
    }

    var plain: PaymentMethodType {
        return PaymentMethodType(self)
    }
}
