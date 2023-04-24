//
//  VerifoneErrors.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 02.03.2023.
//

import Foundation

public enum VerifoneError {
    private static let verifoneSDKErrorDomain = "com.verifone.ios.sdk"

    enum ErrorType {
        static let merchantNotSupport3DS = "The Merchant account doesn't support 3ds"
        static let invalidMerchantConfiguration = "Invalid merchant configuration setup."
        static let missingCardEncryptionPublicKey = "Missing encryption public key"
        static let invalidPublicKey = "Public key parameter is not a string or is not a valid base64 encoded value."
        static let invalidCardData = "Invalid card data"
        static let cancel = "Cancel"
        static let internalSDKError = "Unhandled error occurred."
    }

    public static var invalidPublicKey: NSError {
        return NSError(domain: verifoneSDKErrorDomain,
                       code: 9002,
                       userInfo: [NSLocalizedDescriptionKey: ErrorType.invalidPublicKey])
    }

    public static var invalidCardData: NSError {
        return NSError(domain: verifoneSDKErrorDomain,
                       code: 9003,
                       userInfo: [NSLocalizedDescriptionKey: ErrorType.invalidCardData])
    }

    static var missingCardEncryptionPublicKey: NSError {
        return NSError(domain: verifoneSDKErrorDomain,
                       code: 9004,
                       userInfo: [NSLocalizedDescriptionKey: ErrorType.missingCardEncryptionPublicKey])
    }

    public static var cancel: NSError {
        return NSError(domain: verifoneSDKErrorDomain,
                       code: 9005,
                       userInfo: [NSLocalizedDescriptionKey: ErrorType.cancel])
    }

    public static var merchantNotSupport3DS: NSError {
        return NSError(domain: verifoneSDKErrorDomain,
                       code: 9006,
                       userInfo: [NSLocalizedDescriptionKey: ErrorType.merchantNotSupport3DS])
    }

    static var invalidMerchantConfigurationError: NSError {
        return NSError(domain: verifoneSDKErrorDomain,
                       code: 9007,
                       userInfo: [NSLocalizedDescriptionKey: ErrorType.invalidMerchantConfiguration])
    }

    static var internalSDKError: NSError {
        return NSError(domain: verifoneSDKErrorDomain,
                       code: 9008,
                       userInfo: [NSLocalizedDescriptionKey: ErrorType.internalSDKError])
    }
}
