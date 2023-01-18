//
//  LookupData.swift
//  VerifoneTestPaymentApp
//
//  Created by Oraz Atakishiyev on 09.08.2021.
//

import Foundation

public class OrderData: NSObject, Codable {
    var amount: Int64?
    var billingFirstName: String
    var billingLastName: String
    var billingAddress1: String
    var billingCity: String
    var billingState: String
    var billingCountryCode: String
    var currencyCode: String
    var email: String
    var merchantReference: String?
    var threedsContractId: String?
    var card: String?
    var deviceInfoId: String?
    var deviceChannel: String?
    var encryptedCard: String?
    var publicKeyAlias: String?
    var reuseToken: String?

    public init(amount: Int64? = nil,
                billingFirstName: String,
                billingLastName: String,
                billingAddress1: String,
                billingCity: String,
                billingState: String,
                billingCountryCode: String,
                currencyCode: String,
                email: String,
                merchantReference: String?,
                threedsContractId: String? = nil,
                card: String? = nil,
                publicKeyAlias: String? = nil,
                reuseToken: String? = nil) {
        self.amount = amount
        self.billingFirstName = billingFirstName
        self.billingLastName = billingLastName
        self.billingAddress1 = billingAddress1
        self.billingCity = billingCity
        self.billingState = billingState
        self.billingCountryCode = billingCountryCode
        self.currencyCode = currencyCode
        self.email = email
        self.merchantReference = merchantReference
        self.threedsContractId = threedsContractId
        self.card = card
        self.deviceInfoId = ""
        self.deviceChannel = "SDK"
        self.encryptedCard = ""
        self.publicKeyAlias = publicKeyAlias
        self.reuseToken = nil
    }

    enum CodingKeys: String, CodingKey {
        case amount
        case billingFirstName, billingLastName, billingCity,
             billingState, billingCountryCode, currencyCode, email,
             merchantReference, threedsContractId, card, deviceInfoId,
             deviceChannel, encryptedCard, publicKeyAlias
        case billingAddress1 = "billing_address_1"
    }

    public func setDeviceId(sessionId: String) {
        self.deviceInfoId = sessionId
    }

    public func setEncryptedCard(encryptedCard: String) {
        self.encryptedCard = encryptedCard
    }

    public func setReuseToken(reuseToken: String) {
        self.reuseToken = reuseToken
    }
}

extension OrderData {
    static var creditCard: OrderData = .init(
          billingFirstName: "Testing",
          billingLastName: "Tester",
          billingAddress1: "123 test st",
          billingCity: "Columbus",
          billingState: "Oh",
          billingCountryCode: "US",
          currencyCode: UserDefaults.standard.getCurrency(fromKey: Keys.currency),
          email: "testingtester@gmail.com",
          merchantReference: "test123"
    )

    func setupCreditCard(productPrice: Double, threedsContractId: String, publicKetAlias: String) {
        self.amount = Int64(productPrice * 100)
        self.threedsContractId = threedsContractId
        self.publicKeyAlias = publicKetAlias
    }
}
