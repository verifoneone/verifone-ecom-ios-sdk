//
//  PaymentSheet.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 26.10.2021.
//

import UIKit
import PassKit

@objc public final class VerifoneFormResult: NSObject {
    @objc public var cardData: String?
    @objc public var cardBrand: String?
    @objc public var cardHolder: String?
    @objc public var error: Error?
    @objc public var saveCard: Bool = false
    @objc public var paymentAuthorizingResult:   PaymentAuthorizingResult?
    @objc public var paymentMethodType: PaymentMethodType
    @objc public var paymentApplePayResult: PKPayment?
    
    @objc public init(paymentMethodType: PaymentMethodType, paymentApplePayResult: PKPayment) {
        self.paymentMethodType = paymentMethodType
        self.paymentApplePayResult = paymentApplePayResult
    }
    
    @objc public init(paymentMethodType: PaymentMethodType, paymentAuthorizingResult: PaymentAuthorizingResult?) {
        self.paymentMethodType = paymentMethodType
        self.paymentAuthorizingResult = paymentAuthorizingResult
    }
    
    @objc public init(paymentMethodType: PaymentMethodType = .creditCard, cardData: String? = "", cardBrand: String? = "", cardHolder: String? = "") {
        self.cardData = cardData
        self.cardBrand = cardBrand
        self.cardHolder = cardHolder
        self.error = nil
        self.paymentMethodType = paymentMethodType
    }
    
    @objc public init(error: Error?) {
        self.cardData = nil
        self.cardBrand = nil
        self.cardHolder = nil
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
    
    lazy var paymentMethodsViewController: PaymentMethodsViewController = {
        let storyboard = UIStoryboard(name: "VerifoneSDK", bundle: .module)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PaymentMethodsController") as! PaymentMethodsViewController
        
        return viewController
    }()
    
    public typealias PaymentResultCallback = (_ result: Result<VerifoneFormResult, Error>) -> Void
    
    public func displayPaymentForm(
        from presentingViewController: UIViewController,
        completion: @escaping ((Result<VerifoneFormResult, Error>) -> Void)
    ) {
        let completion: (_ result: Result<VerifoneFormResult, Error>) -> Void = { result in
            if self.paymentMethodsViewController.presentingViewController != nil {
                self.paymentMethodsViewController.dismiss(animated: true) {
                    completion(result)
                }
            } else {
                /// the user closes the payment sheet
                /// without choosing a payment method
                completion(result)
            }
            switch result {
            // check if payment method is pay by link don't close the page.
            case .success(let verifoneResult):
                if (verifoneResult.paymentMethodType != .paypal) {
                    self.completion = nil
                }
            case .failure( _):
                self.completion = nil
            }
        }
        self.completion = completion
        paymentFlowSession = PaymentFlowSession()
        paymentFlowSession.verifoneTheme = defultTheme
        paymentFlowSession.paymentConfiguration = paymentConfiguration
        paymentFlowSession.applepayConfiguration = applepayConfiguration
        paymentMethodsViewController.paymentFlowSession = paymentFlowSession
        paymentMethodsViewController.allowedPaymentMethods = paymentConfiguration!.allowedPaymentMethods
        paymentFlowSession.delegate = self
        
        if (paymentConfiguration!.allowedPaymentMethods.count <= 0) {
            presentingViewController.alert(title: "No payment methods are enabled")
            self.completion?(.failure(VerifoneError.cancel))
        } else {
            presentingViewController.presentPanModal(paymentMethodsViewController)
        }
    }
}

extension VerifonePaymentForm: PaymentFlowSessionDelegate {
    
    func paymentAuthorizingDidSelected(_ viewController: UIViewController, paymentMethod: PaymentMethodType) {
        self.completion?(.success(VerifoneFormResult(paymentMethodType: paymentMethod)))
    }
    
    func paymentFlowSessionDidCardEncrypted(_ controller: UIViewController, result: VerifoneFormResult) {
        if let error = result.error {
            AppLog.log("Payment Chooser -  %@",
                       log: uiLogObject, 
                       type: .error, error.localizedDescription)
            controller.dismiss(animated: true) {
                self.completion?(.failure(error))
            }
        } else {
            AppLog.log("Payment Chooser - Request Success",
                       log: uiLogObject,
                       type: .error)
            controller.dismiss(animated: true) {
                self.completion?(.success(result))
            }
        }
    }
    
    func paymentFlowSessionDidCancel(_ controller: UIViewController, callBack: CallbackStatus) {
        AppLog.log("Payment Method - Cancelled by User",
                   log: uiLogObject,
                   type: .default)
        controller.dismiss(animated: true) {
            switch callBack {
            case .cancel:
                self.completion?(.failure(VerifoneError.cancel))
            default: break
            }
        }
    }
    
    func authorizingPaymentViewController(_ viewController: UIViewController, didCompleteAuthorizing result: PaymentAuthorizingResult) {
        AppLog.log("Redirected to expected - %{private}@",
                   log: uiLogObject,
                   type: .default, result.redirectedUrl.absoluteString)
        let vfresult = VerifoneFormResult(paymentMethodType: .paypal, paymentAuthorizingResult: result)
        viewController.dismiss(animated: true) {
            self.completion?(.success(vfresult))
        }
    }
    
    func didReceiveResultFromAppleService(_ viewController: UIViewController, result: PKPayment) {
        AppLog.log("Result from apple pay",
                   log: uiLogObject,
                   type: .default)
        
        viewController.dismiss(animated: true) {
            let vfresult = VerifoneFormResult(paymentMethodType: .applePay, paymentApplePayResult: result)
            self.completion?(.success(vfresult))
        }
    }
    
    func paymentFlowSessionCancelWithError(_ viewController: UIViewController, error: Error) {
        AppLog.log("Cancelled with error - %{private}@",
                   log: uiLogObject,
                   type: .default, error.localizedDescription)
        viewController.dismiss(animated: true) {
            self.completion?(.failure(error))
        }
    }
}
