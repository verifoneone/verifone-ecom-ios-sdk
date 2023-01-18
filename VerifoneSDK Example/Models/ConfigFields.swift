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
}

enum ParamType: Equatable {
    case publicKeyAlias
    case threedsContractId
    case encryptionKey
    case paymentProviderContract
    case apiUserId
    case apiKey
    case reuseToken
    case organisationId
    case ppc
    case customer
    case entityId
    case button
}

protocol ConfigFields {
    var items: [ConfigSection] { get set }
    mutating func getFields(paymentMethodType: PaymentMethodType!) -> (Parameters?, [ConfigSection])
}

extension ConfigCell {
    // MARK: Card params
    static func getCardParameters(parameters: Parameters?) -> [ConfigCell] {
        return [
            ConfigCell(
                cell: TextField(title: "Public Key alias",
                                  placeholder: "Add a public key"),
                paramType: .publicKeyAlias, value: parameters?.publicKeyAlias ?? ""),
            ConfigCell(
                cell: TextField(title: "3DS Contract ID",
                                placeholder: "Add a 3ds contarct id"),
                paramType: .threedsContractId, value: parameters?.threedsContractID ?? ""),
            ConfigCell(
                cell: TextArea(title: "Public encryption key",
                               placeholder: "Add an encryption key"),
                paramType: .encryptionKey, value: parameters?.encryptionKey ?? ""),
            ConfigCell(
                cell: TextField(title: "Payment provider contract",
                                placeholder: "Add a payment provider contract"),
                paramType: .paymentProviderContract, value: parameters?.paymentProviderContract ?? ""),
            ConfigCell(
                cell: TextField(title: "Api user ID",
                                placeholder: "Add a payment api user id"),
                paramType: .apiUserId, value: parameters?.apiUserID ?? ""),
            ConfigCell(
                cell: TextField(title: "Api key",
                                placeholder: "Add a payment api key"),
                paramType: .apiKey, value: parameters?.apiKey ?? ""),
            ConfigCell(
                cell: TextField(title: "Reuse token",
                                placeholder: "Add a reuse token"),
                paramType: .reuseToken, value: parameters?.reuseToken ?? "")
        ]
    }
    // MARK: Klarna params
    static func getKlarnaParameters(parameters: Parameters?) -> [ConfigCell] {
        return [
            ConfigCell(
                cell: TextField(title: "Api user ID",
                                placeholder: "Add a payment api user id"),
                paramType: .apiUserId, value: parameters?.apiUserID ?? ""),
            ConfigCell(
                cell: TextField(title: "Api key",
                                placeholder: "Add a payment api key"),
                paramType: .apiKey, value: parameters?.apiKey ?? ""),
            ConfigCell(
                cell: TextField(title: "Customer ID",
                                placeholder: "Add a customer id"),
                paramType: .customer, value: parameters?.customer ?? ""),
            ConfigCell(
                cell: TextField(title: "Organisation ID",
                                placeholder: "Add an organisation id"),
                paramType: .organisationId, value: parameters?.organisationId ?? "")
        ]
    }

    // MARK: Siwsh params
    static func getSwishParameters(parameters: Parameters?) -> [ConfigCell] {
        return [
            ConfigCell(
                cell: TextField(title: "Api user ID",
                                placeholder: "Add a payment api user id"),
                paramType: .apiUserId, value: parameters?.apiUserID ?? ""),
            ConfigCell(
                cell: TextField(title: "Api key",
                                placeholder: "Add a payment api key"),
                paramType: .apiKey, value: parameters?.apiKey ?? ""),
            ConfigCell(
                cell: TextField(title: "Entity ID",
                                placeholder: "Add an entity id"),
                paramType: .entityId, value: parameters?.entityId ?? "")
        ]
    }

    // MARK: Vipps params
    static func getVippsParameters(parameters: Parameters?) -> [ConfigCell] {
        return [
            ConfigCell(
                cell: TextField(title: "Api user ID",
                                placeholder: "Add a payment api user id"),
                paramType: .apiUserId, value: parameters?.apiUserID ?? ""),
            ConfigCell(
                cell: TextField(title: "Api key",
                                placeholder: "Add a payment api key"),
                paramType: .apiKey, value: parameters?.apiKey ?? ""),
            ConfigCell(
                cell: TextField(title: "PPC",
                                placeholder: "Add a payment provider contract"),
                paramType: .paymentProviderContract, value: parameters?.paymentProviderContract ?? ""),
            ConfigCell(
                cell: TextField(title: "Customer",
                                placeholder: "Add customer"),
                paramType: .customer, value: parameters?.customer ?? "")
        ]
    }

    // MARK: MobilePay params
    static func getMobilePayParameters(parameters: Parameters?) -> [ConfigCell] {
        return [
            ConfigCell(
                cell: TextField(title: "Api user ID",
                                placeholder: "Add a payment api user id"),
                paramType: .apiUserId, value: parameters?.apiUserID ?? ""),
            ConfigCell(
                cell: TextField(title: "Api key",
                                placeholder: "Add a payment api key"),
                paramType: .apiKey, value: parameters?.apiKey ?? ""),
            ConfigCell(
                cell: TextField(title: "PPC",
                                placeholder: "Add a payment provider contract"),
                paramType: .paymentProviderContract, value: parameters?.paymentProviderContract ?? ""),
            ConfigCell(
                cell: TextField(title: "Customer",
                                placeholder: "Add customer"),
                paramType: .customer, value: parameters?.customer ?? "")
        ]
    }
}
