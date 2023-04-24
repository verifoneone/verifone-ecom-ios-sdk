//
//  CreditCard.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 10.11.2022.
//

import Foundation

protocol ConfigItem {}

struct TextField: ConfigItem {
    var title: String
    var placeholder: String
}

struct TextArea: ConfigItem {
    var title: String
    var placeholder: String
}

struct ButtonItem: ConfigItem {
    var title: String
}

struct ConfigSection {
    var header: String
    var cells: [ConfigCell]
}

struct ConfigCell {
    var cell: ConfigItem
    var paramType: ParamType
    var value: String?
    var error: String?
}

enum ParamType: String {
    case publicKeyAlias
    case threedsContractId
    case encryptionKey
    case paymentProviderContract
    case apiUserID
    case apiKey
    case tokenScope
    case ppc
    case customer
    case entityId
    case button
}

protocol ConfigFields {
    var items: [ConfigSection] { get set }
    mutating func getFields(paymentMethodType: AppPaymentMethodType!) -> (Parameters?, [ConfigSection])
}

extension ConfigCell {
    // MARK: Card params
    static func getCardParameters(parameters: Parameters?) -> [ConfigCell] {
        return [
            ConfigCell(
                cell: TextField(title: "Public Key alias",
                                  placeholder: "----"),
                paramType: .publicKeyAlias, value: parameters?.publicKeyAlias ?? ""),
            ConfigCell(
                cell: TextField(title: "3DS Contract ID",
                                placeholder: "----"),
                paramType: .threedsContractId, value: parameters?.threedsContractID ?? ""),
            ConfigCell(
                cell: TextArea(title: "Public encryption key",
                               placeholder: "----"),
                paramType: .encryptionKey, value: parameters?.encryptionKey ?? ""),
            ConfigCell(
                cell: TextField(title: "Payment provider contract",
                                placeholder: "----"),
                paramType: .paymentProviderContract, value: parameters?.paymentProviderContract ?? ""),
            ConfigCell(
                cell: TextField(title: "API user ID",
                                placeholder: "----"),
                paramType: .apiUserID, value: parameters?.apiUserID ?? ""),
            ConfigCell(
                cell: TextField(title: "API key",
                                placeholder: "----"),
                paramType: .apiKey, value: parameters?.apiKey ?? ""),
            ConfigCell(
                cell: TextField(title: "Token scope",
                                placeholder: "----"),
                paramType: .tokenScope, value: parameters?.tokenScope ?? "")
        ]
    }
    // MARK: Klarna params
    static func getKlarnaParameters(parameters: Parameters?) -> [ConfigCell] {
        return [
            ConfigCell(
                cell: TextField(title: "Api user ID",
                                placeholder: "----"),
                paramType: .apiUserID, value: parameters?.apiUserID ?? ""),
            ConfigCell(
                cell: TextField(title: "Api key",
                                placeholder: "----"),
                paramType: .apiKey, value: parameters?.apiKey ?? ""),
            ConfigCell(
                cell: TextField(title: "Customer",
                                placeholder: "----"),
                paramType: .customer, value: parameters?.customer ?? ""),
            ConfigCell(
                cell: TextField(title: "Entity ID",
                                placeholder: "----"),
                paramType: .entityId, value: parameters?.entityId ?? "")
        ]
    }

    // MARK: Siwsh params
    static func getSwishParameters(parameters: Parameters?) -> [ConfigCell] {
        return [
            ConfigCell(
                cell: TextField(title: "API user ID",
                                placeholder: "----"),
                paramType: .apiUserID, value: parameters?.apiUserID ?? ""),
            ConfigCell(
                cell: TextField(title: "API key",
                                placeholder: "----"),
                paramType: .apiKey, value: parameters?.apiKey ?? ""),
            ConfigCell(
                cell: TextField(title: "Entity ID",
                                placeholder: "----"),
                paramType: .entityId, value: parameters?.entityId ?? "")
        ]
    }

    // MARK: Vipps params
    static func getVippsParameters(parameters: Parameters?) -> [ConfigCell] {
        return [
            ConfigCell(
                cell: TextField(title: "API user ID",
                                placeholder: "----"),
                paramType: .apiUserID, value: parameters?.apiUserID ?? ""),
            ConfigCell(
                cell: TextField(title: "API key",
                                placeholder: "----"),
                paramType: .apiKey, value: parameters?.apiKey ?? ""),
            ConfigCell(
                cell: TextField(title: "Payment provider contract",
                                placeholder: "----"),
                paramType: .paymentProviderContract, value: parameters?.paymentProviderContract ?? ""),
            ConfigCell(
                cell: TextField(title: "Customer",
                                placeholder: "----"),
                paramType: .customer, value: parameters?.customer ?? "")
        ]
    }

    // MARK: MobilePay params
    static func getMobilePayParameters(parameters: Parameters?) -> [ConfigCell] {
        return [
            ConfigCell(
                cell: TextField(title: "API user ID",
                                placeholder: "----"),
                paramType: .apiUserID, value: parameters?.apiUserID ?? ""),
            ConfigCell(
                cell: TextField(title: "API key",
                                placeholder: "----"),
                paramType: .apiKey, value: parameters?.apiKey ?? ""),
            ConfigCell(
                cell: TextField(title: "Payment provider contract",
                                placeholder: "----"),
                paramType: .paymentProviderContract, value: parameters?.paymentProviderContract ?? ""),
            ConfigCell(
                cell: TextField(title: "Customer",
                                placeholder: "----"),
                paramType: .customer, value: parameters?.customer ?? "")
        ]
    }

    // MARK: Paypal params
    static func getPaypalParameters(parameters: Parameters?) -> [ConfigCell] {
        return [
            ConfigCell(
                cell: TextField(title: "API user ID",
                                placeholder: "----"),
                paramType: .apiUserID, value: parameters?.apiUserID ?? ""),
            ConfigCell(
                cell: TextField(title: "API key",
                                placeholder: "----"),
                paramType: .apiKey, value: parameters?.apiKey ?? ""),
            ConfigCell(
                cell: TextField(title: "Payment provider contract",
                                placeholder: "----"),
                paramType: .paymentProviderContract, value: parameters?.paymentProviderContract ?? ""),
            ConfigCell(
                cell: TextField(title: "Entity ID",
                                placeholder: "----"),
                paramType: .entityId, value: parameters?.entityId ?? "")
        ]
    }
}
