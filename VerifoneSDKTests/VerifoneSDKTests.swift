//
//  VerifoneSDKTests.swift
//  VerifoneSDKTests
//
//  Created by Oraz Atakishiyev on 26.07.2023.
//

import XCTest
import VerifoneSDK

final class VerifoneSDKTests: XCTestCase {

    let publicKey: String = ""

    func testCreditCardEncryption() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let iso8601String = dateFormatter.string(from: Date()) + "Z"

        let encryptedData = EncryptedData(cardNumber: "4111111111111111",
                                          expiryMonth: 12,
                                          expiryYear: 25,
                                          cvv: "123",
                                          captureTime: "2023-07-26T17:46:16Z")
        XCTAssertNotNil(publicKey)
        let cardData = CardEncryption(publicKey: publicKey, cardData: encryptedData)
        cardData.getEncryptedData { cardEncryptionResult in
            switch cardEncryptionResult {
            case let .success(cardEncryptionResult):
                XCTAssertNotNil(cardEncryptionResult)
            case let .failure(error):
                XCTAssertNil(error)
            }
        }
    }

    func testGiftCardEncryption() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let iso8601String = dateFormatter.string(from: Date()) + "Z"

        let encryptedData = EncryptedData(cardNumber: "4111111111111111111",
                                          captureTime: "2023-07-26T17:46:16Z",
                                          svcAccessCode: "1234")
        XCTAssertNotNil(publicKey)
        let cardData = CardEncryption(publicKey: publicKey, cardData: encryptedData)
        cardData.getEncryptedData { cardEncryptionResult in
            switch cardEncryptionResult {
            case let .success(cardEncryptionResult):
                XCTAssertNotNil(cardEncryptionResult)
            case let .failure(error):
                XCTAssertNil(error)
            }
        }
    }

}
