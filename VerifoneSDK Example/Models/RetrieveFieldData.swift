//
//  CreditCardFields.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 10.11.2022.
//

import Foundation

struct RetrieveFieldData: ConfigFields {
    var items: [ConfigSection] = []
    var parameters: Parameters?

    mutating func getFields(paymentMethodType: PaymentMethodType!) -> (Parameters?, [ConfigSection]) {
        if let params = UserDefaults.standard.retrieve(object: Parameters.self, fromKey: paymentMethodType.rawValue) {
            parameters = params
        }
        switch paymentMethodType {
        case .creditCard:
            let cardParams = ConfigSection(
                header: "Card payment parameters",
                cells: ConfigCell.getCardParameters(parameters: parameters))
            self.items.append(cardParams)
        case .klarna:
            let cardParams = ConfigSection(
                header: "Klarna parameters",
                cells: ConfigCell.getKlarnaParameters(parameters: parameters))
            self.items.append(cardParams)
        case .swish:
            let cardParams = ConfigSection(
                header: "Swish parameters",
                cells: ConfigCell.getSwishParameters(parameters: parameters))
            self.items.append(cardParams)
        case .vipps:
            let cardParams = ConfigSection(
                header: "Vipps parameters",
                cells: ConfigCell.getVippsParameters(parameters: parameters))
            self.items.append(cardParams)
        case .mobilePay:
            let cardParams = ConfigSection(
                header: "MobilePay parameters",
                cells: ConfigCell.getMobilePayParameters(parameters: parameters))
            self.items.append(cardParams)
        default:
            self.items = []
        }
        let buttonSection = ConfigSection(header: "Import parameters from json file",
                                          cells: [ ConfigCell(cell: ButtonItem(title: "Browse files"),
                                                              paramType: .button)])
        self.items.append(buttonSection)
        return (parameters, self.items)
    }
}
