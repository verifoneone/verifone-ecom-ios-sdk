//
//  ApplePayWrapper.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 06.10.2021.
//

import Foundation

@objc public class ApplePayTokenWrapper: NSObject, Codable {
    public let applePayPaymentToken: ApplePayToken

    @objc public init(applePayPaymentToken: ApplePayToken) {
        self.applePayPaymentToken = applePayPaymentToken
    }

    @objc public class func create(from data: Data) -> ApplePayTokenWrapper? {
        let decoder = JSONDecoder()
        guard let item = try? decoder.decode(ApplePayToken.self, from: data) else {
            return nil
        }
        return ApplePayTokenWrapper(applePayPaymentToken: item)
    }
}

@objc public class ApplePayToken: NSObject, Codable {
    @objc class AppleTokenHeader: NSObject, Codable {
        private let publicKeyHash: String
        private let ephemeralPublicKey: String?
        private let transactionId: String

        @objc init(publicKeyHash: String, ephemeralPublicKey: String?, transactionId: String) {
            self.publicKeyHash = publicKeyHash
            self.ephemeralPublicKey = ephemeralPublicKey
            self.transactionId = transactionId
        }
    }

    private let signature: String
    private let data: String?
    private let header: AppleTokenHeader
    private let version: String

    @objc init(signature: String, data: String?, header: AppleTokenHeader, version: String) {
        self.signature = signature
        self.data = data
        self.header = header
        self.version = version
    }
}
