//
//  ApplePayController.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 04.10.2021.
//

import Foundation
import PassKit

public protocol ApplePayServiceDelegate: AnyObject {
    func didReceiveResultFromAppleService(_ result: Result<PKPayment, Error>)
}

public class ApplePayService: NSObject {
    private var applePaymentDidSucceed = false

    private let applePayMerchantConfiguration: VerifoneSDK.ApplePayMerchantConfiguration?
    private var paymentCompleted: ((Result< PKPayment, Error>) -> Void)?
    private let paymentViewControllerType: PKPaymentAuthorizationExtensionProtocol.Type

    private var payment: PKPayment?

    weak var delegate: ApplePayServiceDelegate?

    public convenience override init() {
        self.init(applePayMerchantConfiguration: nil)
    }

    public convenience init(applePayMerchantConfiguration: VerifoneSDK.ApplePayMerchantConfiguration? = nil) {

        self.init(applePayMerchantConfiguration: applePayMerchantConfiguration,
                  paymentViewControllerType: PKPaymentAuthorizationViewController.self)
    }

    init(applePayMerchantConfiguration: VerifoneSDK.ApplePayMerchantConfiguration? = nil,
         paymentViewControllerType: PKPaymentAuthorizationExtensionProtocol.Type) {

        self.applePayMerchantConfiguration = applePayMerchantConfiguration ?? VerifoneSDK.applePayMerchantConfiguration
        self.paymentViewControllerType = paymentViewControllerType
    }

    private func haveValidNetworks() -> Bool {
        return paymentViewControllerType.canMakePayments(usingNetworks: applePayMerchantConfiguration!.supportedPaymentNetworks)
    }
}

extension ApplePayService: ApplePayServiceProtocol {
  
    public func isApplePaySupported() -> Bool {
       return paymentViewControllerType.canMakePayments() && haveValidNetworks()
    }

    public func beginPayment(presentingController: UIViewController, completion: @escaping PaymentCallback) {
        beginPayment(presentingController: presentingController) { result in
            self.delegate?.didReceiveResultFromAppleService(result)
            switch result {
            case let .failure(error):
                completion(nil, error)
            case let .success(paymentInfo):
                completion(paymentInfo, nil)
            }
        }
    }

    public typealias PaymentResultCallback = (_ result: Result<PKPayment, Error>) -> Void

    public func beginPayment(presentingController: UIViewController, completion: @escaping PaymentResultCallback) {
        guard let applePayMerchantConfiguration = self.applePayMerchantConfiguration else {
            completion(.failure(VerifoneError.invalidMerchantConfigurationError))
            return
        }

        let merchantIdentifier = applePayMerchantConfiguration.applePayMerchantId

        paymentCompleted = completion

        applePaymentDidSucceed = false

        let request = PKPaymentRequest()
        request.merchantIdentifier = merchantIdentifier
        request.supportedNetworks = applePayMerchantConfiguration.supportedPaymentNetworks
        request.merchantCapabilities = .capability3DS
        request.countryCode = applePayMerchantConfiguration.countryCode
        request.currencyCode = applePayMerchantConfiguration.currencyCode
        request.paymentSummaryItems = applePayMerchantConfiguration.paymentSummaryItems

        do {
            try paymentViewControllerType.present(request: request,
                                                  delegate: self, present: presentingController)
        } catch let error {
            completion(.failure(error))
        }
    }
}

extension ApplePayService: PKPaymentAuthorizationViewControllerDelegate {
    @available(iOS 11.0, *)
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                                   didAuthorizePayment payment: PKPayment,
                                                   handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        self.payment = payment
        applePaymentDidSucceed = true
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }

    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                                   didAuthorizePayment payment: PKPayment,
                                                   completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        applePaymentDidSucceed = true
        self.payment = payment
        completion(.success)
        self.delegate?.didReceiveResultFromAppleService(.success(payment))
    }

    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)

        guard let payment = self.payment,
            applePaymentDidSucceed else {
                paymentCompleted?(.failure(VerifoneError.cancel))
                self.delegate?.didReceiveResultFromAppleService(.failure(VerifoneError.cancel))
                return
        }
        self.delegate?.didReceiveResultFromAppleService(.success(payment))
        paymentCompleted?(.success(payment))
    }
}
