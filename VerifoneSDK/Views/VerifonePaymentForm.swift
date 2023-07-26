//
//  PaymentSheet.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 26.10.2021.
//

import UIKit
import PassKit

public final class VerifoneFormResult: NSObject {
    public var cardData: String?
    public var cardBrand: String?
    public var error: Error?
    public var saveCard: Bool = false
    public var paymentAuthorizingResult: PaymentAuthorizingResult?
    public var paymentMethodType: VerifonePaymentMethodType
    public var paymentApplePayResult: PKPayment?

    public init(paymentMethodType: VerifonePaymentMethodType, paymentApplePayResult: PKPayment) {
        self.paymentMethodType = paymentMethodType
        self.paymentApplePayResult = paymentApplePayResult
    }

    public init(paymentMethodType: VerifonePaymentMethodType, paymentAuthorizingResult: PaymentAuthorizingResult?) {
        self.paymentMethodType = paymentMethodType
        self.paymentAuthorizingResult = paymentAuthorizingResult
    }

    public init(paymentMethodType: VerifonePaymentMethodType = .creditCard, cardData: String? = "", cardBrand: String? = "", cardHolder: String? = "") {
        self.cardData = cardData
        self.cardBrand = cardBrand
        self.error = nil
        self.paymentMethodType = paymentMethodType
    }

    @objc public init(error: Error?) {
        self.cardData = nil
        self.cardBrand = nil
        self.paymentMethodType = .creditCard
        self.error = error
    }

    @objc public func setSaveCardState(saveCard: Bool) {
        self.saveCard = saveCard
    }
}

public class VerifonePaymentForm {

    private var paymentConfiguration: VerifoneSDK.PaymentConfiguration?
    private var defultTheme: VerifoneSDK.Theme!
    private var paymentFlowSession: PaymentFlowSession!
    private var applepayConfiguration: VerifoneSDK.ApplePayMerchantConfiguration?
    private var completion: ((Result< VerifoneFormResult, Error>) -> Void)?

    public init(paymentConfiguration: VerifoneSDK.PaymentConfiguration?, applepayConfiguration: VerifoneSDK.ApplePayMerchantConfiguration? = nil, verifoneTheme: VerifoneSDK.Theme = .defaultTheme) {
        self.paymentConfiguration = paymentConfiguration
        self.applepayConfiguration = applepayConfiguration
        self.defultTheme = verifoneTheme
    }

    lazy var paymentMethodsViewController = PaymentMethodsViewController()

    public func displayPaymentForm(from presentingViewController: UIViewController, completion: @escaping (Result<VerifoneFormResult, Error>) -> Void) {
        // Define the completion block as an optional property
        self.completion = { [weak self] result in
            guard let self = self else { return }
            // Check if the payment methods view controller is still presented before dismissing it
            if self.paymentMethodsViewController.presentingViewController != nil {
                self.paymentMethodsViewController.dismiss(animated: true) {
                    completion(result)
                }
            } else {
                // The user closed the payment sheet without choosing a payment method
                completion(result)
            }
            // If the payment method is not PayPal, set the completion block to nil to avoid a retain cycle
            if case .success(let verifoneResult) = result, verifoneResult.paymentMethodType != .paypal {
                self.completion = nil
            } else if case .failure = result {
                self.completion = nil
            }
        }
        paymentFlowSession = PaymentFlowSession()
        paymentFlowSession.verifoneTheme = defultTheme
        paymentFlowSession.paymentConfiguration = paymentConfiguration
        paymentFlowSession.applepayConfiguration = applepayConfiguration
        paymentMethodsViewController.paymentFlowSession = paymentFlowSession
        paymentMethodsViewController.allowedPaymentMethods = paymentConfiguration!.allowedPaymentMethods
        paymentFlowSession.delegate = self

        if paymentConfiguration?.allowedPaymentMethods.isEmpty ?? true {
            presentingViewController.alert(title: "No payment methods are enabled")
            self.completion?(.failure(VerifoneError.cancel))
        } else {
            presentingViewController.presentPanModal(paymentMethodsViewController)
        }
    }

}

extension VerifonePaymentForm: PaymentFlowSessionDelegate {

    func paymentAuthorizingDidSelected(_ viewController: UIViewController, paymentMethod: VerifonePaymentMethodType) {
        self.completion?(.success(VerifoneFormResult(paymentMethodType: paymentMethod)))
    }

    func paymentFlowSessionDidCardEncrypted(_ controller: UIViewController, result: VerifoneFormResult) {
        if let error = result.error {
            debugPrint("Payment Chooser")
            controller.dismiss(animated: true) {
                self.completion?(.failure(error))
            }
        } else {
            debugPrint("Payment Chooser - Request Success")
            controller.dismiss(animated: true) {
                self.completion?(.success(result))
            }
        }
    }

    func paymentFlowSessionDidCancel(_ controller: UIViewController, callBack: CallbackStatus) {
        debugPrint("Payment Method - Cancelled by User")
        controller.dismiss(animated: true) {
            switch callBack {
            case .cancel:
                self.completion?(.failure(VerifoneError.cancel))
            default: break
            }
        }
    }

    func authorizingPaymentViewController(_ viewController: UIViewController, didCompleteAuthorizing result: PaymentAuthorizingResult) {
        debugPrint("Redirected to expected - \(result.redirectedUrl.absoluteString)")
        let vfresult = VerifoneFormResult(paymentMethodType: .paypal, paymentAuthorizingResult: result)
        viewController.dismiss(animated: true) {
            self.completion?(.success(vfresult))
        }
    }

    func didReceiveResultFromAppleService(_ viewController: UIViewController, result: PKPayment) {
        debugPrint("Result from apple pay")
        viewController.dismiss(animated: true) {
            let vfresult = VerifoneFormResult(paymentMethodType: .applePay, paymentApplePayResult: result)
            self.completion?(.success(vfresult))
        }
    }

    func paymentFlowSessionCancelWithError(_ viewController: UIViewController, error: Error) {
        debugPrint("Cancelled with error")
        viewController.dismiss(animated: true) {
            self.completion?(.failure(error))
        }
    }
}
