//
//  CardEncryption.swift
//  Verifone
//
//  Created by Oraz Atakishiyev on 19.09.2021.
//

import UIKit
import Gopenpgp

public typealias CardEncryptionResultCallback = (_ result: Result<String, Error>) -> Void

public class CardEncryption: NSObject {
    private var publicKey: String?
    private var cardData: EncryptedData?

    static let shared = CardEncryption(publicKey: nil, cardData: nil)

    public init(publicKey: String?=nil, cardData: EncryptedData?=nil) {
        self.publicKey = publicKey
        self.cardData = cardData
        super.init()
    }

    public func getEncryptedData(completion: @escaping CardEncryptionResultCallback) {

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let publicKey64 = self.publicKey else {
            debugPrint("Missing card encryption public key")
            completion(.failure(VerifoneError.invalidPublicKey))
            return
        }

        guard let publicKey = publicKey64.fromBase64() else {
            debugPrint("Invalid public key")
            completion(.failure(VerifoneError.invalidPublicKey))
            return
        }

        guard let cardData = self.cardData else {
            debugPrint("Missing or invalid card data information")
            completion(.failure(VerifoneError.invalidCardData))
            return
        }

        guard let json = try? encoder.encode(cardData) else {
            debugPrint("Card encryption json format is wrong")
            completion(.failure(VerifoneError.invalidCardData))
            return
        }

        let jsonCardData = String(data: json, encoding: .utf8)!
        let senderPublic = CryptoKey(fromArmored: publicKey)
        let senderPublicKeyRing = CryptoKeyRing(senderPublic)
        var error: NSError?
        let cipher = try? senderPublicKeyRing?.encrypt(CryptoNewPlainMessageFromString(jsonCardData), privateKey: nil).getArmored(&error)
        guard let cipher = cipher?.toBase64() else {
            debugPrint("Invalid public key")
            completion(.failure(VerifoneError.invalidPublicKey))
            return
        }
        return completion(.success(cipher))
    }
}
