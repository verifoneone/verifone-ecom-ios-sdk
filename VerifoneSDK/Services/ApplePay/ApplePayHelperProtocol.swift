//
//  ApplePayHelperProtocol.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 04.10.2021.
//

import Foundation
import PassKit

public typealias PKPaymentAuthorizationExtensionProtocol = PKPaymentViewControllerProtocol & PKAuthorizationPresenterProtocol

public protocol PKPaymentViewControllerProtocol {
    static func canMakePayments() -> Bool
    static func canMakePayments(usingNetworks supportedNetworks: [PKPaymentNetwork]) -> Bool
}

public protocol PKAuthorizationPresenterProtocol {
    typealias PKAuthorizationPresenterCallback = (_ result: Result<PKPayment, Error>) -> Void

    static func present(request: PKPaymentRequest,
                        delegate: PKPaymentAuthorizationViewControllerDelegate, present: UIViewController) throws
}

extension PKPaymentAuthorizationViewController: PKPaymentAuthorizationExtensionProtocol {
    public static func present(request: PKPaymentRequest,
                               delegate: PKPaymentAuthorizationViewControllerDelegate, present: UIViewController) throws {

        guard let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request) else {
            throw VerifoneError.internalSDKError
        }

        applePayController.delegate = delegate
        present.present(applePayController, animated: true, completion: nil)
    }
}
