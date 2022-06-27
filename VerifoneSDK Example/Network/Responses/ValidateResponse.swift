//
//  EnrollAuthentication.swift
//  VerifoneTestPaymentApp
//
//  Created by Oraz Atakishiyev on 09.08.2021.
//
import UIKit

public class ValidateResponse: NSObject, Codable {
    public let authenticationID, actionCode, errorNo, errorDesc: String?
    public let validationResult: ValidationResult?

    enum CodingKeys: String, CodingKey {
        case authenticationID = "authentication_id"
        case actionCode = "action_code"
        case errorNo = "error_no"
        case errorDesc = "error_desc"
        case validationResult = "validation_result"
    }
}

// MARK: - ValidationResult
public class ValidationResult: NSObject, Codable {
    public let authorizationPayload, cavv, eciFlag, paresStatus: String?
    public let signatureVerification: String?

    enum CodingKeys: String, CodingKey {
        case authorizationPayload = "authorization_payload"
        case cavv
        case eciFlag = "eci_flag"
        case paresStatus = "pares_status"
        case signatureVerification = "signature_verification"
    }
}
