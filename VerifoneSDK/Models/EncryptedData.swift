//
//  EncryptedData.swift
//  encryptCardData
//
//  Created by Oraz Atakishiyev on 26.07.2021.
//

import Foundation

public struct EncryptedData: Codable {
    let cardNumber: String
    let expiryMonth: Int
    let expiryYear: Int
    let cvv: String
    let captureTime: String

    public init(cardNumber: String, expiryMonth: Int, expiryYear: Int, cvv: String, captureTime: String) {
        self.cardNumber = cardNumber
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.cvv = cvv
        self.captureTime = captureTime
    }
}
