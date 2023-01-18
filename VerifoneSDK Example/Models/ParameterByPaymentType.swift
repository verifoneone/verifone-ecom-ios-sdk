//
//  ParameterFields.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 10.11.2022.
//

import Foundation

struct ParameterByPaymentType {
    let paymentMethodType: PaymentMethodType!
    var params = RetrieveFieldData()

    init(paymentMethodType: PaymentMethodType!) {
        self.paymentMethodType = paymentMethodType
    }

    mutating func getFields() -> (Parameters?, [ConfigSection]) {
        return params.getFields(paymentMethodType: paymentMethodType)
    }
}
