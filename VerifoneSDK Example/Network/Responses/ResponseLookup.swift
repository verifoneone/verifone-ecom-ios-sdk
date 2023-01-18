//
//  ResponseLookup.swift
//  VerifoneTestPaymentApp
//
//  Created by Oraz Atakishiyev on 09.08.2021.
//

import Foundation

enum EnrollStatus: String, Codable {
    case enrolled = "ENROLLED"
    case notEnrolled = "NOT_ENROLLED"
    case failed = "FAILED"
    case error = "ERROR"
    case unknown = "UNKNOWN"
    case Yes = "Y"
}

public class ResponseLookup: NSObject, Codable {
    public let acsTransactionID: String?
    public let acsURL: String?
    public let authenticationID, challengeRequired, cardBrand, dsTransactionID: String?
    public let eciFlag, enrolled, errorNo, orderID: String?
    public let paresStatus, payload, signatureVerification, threedsVersion: String?
    public let transactionID: String?
    var status: EnrollStatus?

    enum CodingKeys: String, CodingKey {
        case acsTransactionID = "acs_transaction_id"
        case acsURL = "acs_url"
        case authenticationID = "authentication_id"
        case challengeRequired = "challenge_required"
        case cardBrand = "card_brand"
        case dsTransactionID = "ds_transaction_id"
        case eciFlag = "eci_flag"
        case enrolled
        case errorNo = "error_no"
        case orderID = "order_id"
        case paresStatus = "pares_status"
        case payload
        case signatureVerification = "signature_verification"
        case threedsVersion = "threeds_version"
        case transactionID = "transaction_id"
    }

    init(acsTransactionID: String?, acsURL: String?, authenticationID: String?, challengeRequired: String?, cardBrand: String?, dsTransactionID: String?, eciFlag: String?, enrolled: String?, errorNo: String?, orderID: String?, paresStatus: String?, payload: String?, signatureVerification: String?, threedsVersion: String?, transactionID: String?, status: EnrollStatus?) {
        self.acsTransactionID = acsTransactionID
        self.acsURL = acsURL
        self.authenticationID = authenticationID
        self.challengeRequired = challengeRequired
        self.cardBrand = cardBrand
        self.dsTransactionID = dsTransactionID
        self.eciFlag = eciFlag
        self.enrolled = enrolled
        self.errorNo = errorNo
        self.orderID = orderID
        self.paresStatus = paresStatus
        self.payload = payload
        self.signatureVerification = signatureVerification
        self.threedsVersion = threedsVersion
        self.transactionID = transactionID
        self.status = status
    }
}
