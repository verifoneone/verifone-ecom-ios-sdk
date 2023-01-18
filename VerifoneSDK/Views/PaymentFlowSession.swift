//
//  PaymentFlowSession.swift
//  Verifone
//
//  Created by Oraz Atakishiyev on 21.09.2021.
//

import UIKit
import PassKit

internal protocol PaymentFlowSessionDelegate: AnyObject {
    func paymentFlowSessionDidCancel(_ controller: UIViewController, callBack: CallbackStatus)
    func paymentFlowSessionDidCardEncrypted(_ controller: UIViewController, result: VerifoneFormResult)

    func paymentAuthorizingDidSelected(_ viewController: UIViewController, paymentMethod: VerifoneSDKPaymentTypeValue)
    func authorizingPaymentViewController(_ viewController: UIViewController, didCompleteAuthorizing redirected: PaymentAuthorizingResult)

    func didReceiveResultFromAppleService(_ viewController: UIViewController, result: PKPayment)
    func paymentFlowSessionCancelWithError(_ viewController: UIViewController, error: Error)
}

internal class PaymentFlowSession: NSObject {
    var paymentConfiguration: VerifoneSDK.PaymentConfiguration?
    var applepayConfiguration: VerifoneSDK.ApplePayMerchantConfiguration?
    var verifoneTheme: VerifoneSDK.Theme = VerifoneSDK.defaultTheme
    weak var delegate: PaymentFlowSessionDelegate?

    public func validateRequiredParameters() -> Bool {
        let waringMessageTitle: String
        let waringMessageMessage: String

        if self.paymentConfiguration == nil {
            AppLog.log("Missing payment configuration", log: uiLogObject, type: .error)
            waringMessageTitle = "Missing payment information."
            waringMessageMessage = "Please set the configuration before request payment."
        } else if self.paymentConfiguration?.cardEncryptionPublicKey == nil {
            AppLog.log("Missing payment information",
                   log: uiLogObject,
                   type: .error)
            waringMessageTitle = "Missing payment information."
            waringMessageMessage = "Please set encryption public key before request the payment"
        } else {
            return true
        }

        assertionFailure("\(waringMessageTitle) \(waringMessageMessage)")
        return false
    }
}

extension PaymentFlowSession: CreditCardFormViewControllerDelegate {
    func creditCardFormViewControllerDidCancel(_ controller: CreditCardViewController, callback: CallbackStatus) {
        delegate?.paymentFlowSessionDidCancel(controller, callBack: callback)
    }

    func creditCardFormViewControllerDidCardEncrypted(_ controller: CreditCardViewController, result: VerifoneFormResult) {
        delegate?.paymentFlowSessionDidCardEncrypted(controller, result: result)
    }
}

extension PaymentFlowSession: AuthorizingPaymentWebViewControllerDelegate {

    func authorizingPaymentViewControllerDidCancel(_ viewController: VFAuthorizingPaymentWebViewController, callback: CallbackStatus) {
        delegate?.paymentFlowSessionDidCancel(viewController, callBack: callback)
    }

    func paymentAuhtorizingDidSelected(_ viewController: VFAuthorizingPaymentWebViewController, paymentMethod: VerifoneSDKPaymentTypeValue) {
        delegate?.paymentAuthorizingDidSelected(viewController, paymentMethod: paymentMethod)
    }

    func authorizingPaymentViewController(_ viewController: VFAuthorizingPaymentWebViewController, didCompleteAuthorizing result: PaymentAuthorizingResult) {
        delegate?.authorizingPaymentViewController(viewController, didCompleteAuthorizing: result)
    }
}

extension PaymentFlowSessionDelegate {
    func paymentFlowSessionDidCancel(_ controller: UIViewController) { }
    func paymentFlowSessionDidCardEncrypted(_ controller: UIViewController, result: VerifoneFormResult) { }
    func authorizingPaymentViewController(_ viewController: VFAuthorizingPaymentWebViewController, didCompleteAuthorizingWithRedirectedURL redirected: URL) { }
}
