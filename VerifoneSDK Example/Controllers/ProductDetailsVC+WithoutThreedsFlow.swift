//
//  ProductDetailsVC+WithoutThreedsFlow.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 23.12.2021.
//

import UIKit
import VerifoneSDK

//
// Handle without 3ds payment flow, AuthorizingPaymentWebViewControllerDelegate
//
extension ProductDetailsViewController {

    @objc func purchaseWithout3ds(sender: UIButton) {
        self.setupRequiredTestParams()
        if let cell: BuyButtonCell = sender.superview!.superview as? BuyButtonCell {
            cell.buyButton.isEnabled = false
            cell.buyButton2.isEnabled = false
            cell.activityIndicator2.startAnimating()
        }
        if let cell: BuyButtonCellWithSingleButton = sender.superview!.superview as? BuyButtonCellWithSingleButton {
            cell.buyButton.isEnabled = false
            cell.activityIndicator.startAnimating()
        }

        do {
            let token = try defaults.getObject(forKey: "reuseToken", castTo: ResponseReuseToken.self)
            if GlobalENV != Env.CST_FOR_REUSE_TOKEN {
                throw VerifoneError.merchantNotSupport3DS
            }
            if !isTokenExpired(tokenExpiryDate: token.tokenExpiryDate) {
                processWithTokenWithout3ds(reuseToken: token)
            } else {
                self.alert(title: "Token", message: "The token expired, recreate token.")
            }
        } catch {
            verifonePaymentForm.displayPaymentForm(from: self) { [weak self] result in
                self?.didCardEncryptedForWithout3ds(result)
            }
        }
    }

    func processWithTokenWithout3ds(reuseToken: ResponseReuseToken) {
        guard let params = Parameters.creditCard else {
            self.alert(title: "\(missingParams) CreditCard")
            self.stopAnimation()
            return
        }

        var request = RequestTransaction.creditCard
        request.setupCreditCardWithout3ds(productPrice: product.price,
                                          cardBrand: reuseToken.brand,
                                          paymentProviderContract: params.paymentProviderContract!,
                                          publicKeyAlias: params.publicKeyAlias!,
                                          reuseToken: params.reuseToken)

        ProductsAPI.shared.transaction(request: request) { [weak self] (result, error) in
            self?.stopAnimation()

            guard error == nil else {
                self?.alert(title: "Error transaction", message: "An error has occurred: \(error!)")
                return
            }
            self?.showResultPage(merchantReference: "\(result!.merchantReference!)")
        }
    }

    func didCardEncryptedForWithout3ds(_ result: Result<VerifoneFormResult, Error>) {
        switch result {
        case .success(let verifoneResult):
            switch verifoneResult.paymentMethodType {
            case .creditCard:
                print("State of save card switch \(verifoneResult.saveCard)")
                guard let params = Parameters.creditCard else {
                    self.alert(title: "\(missingParams) CreditCard")
                    self.stopAnimation()
                    return
                }
                orderData = OrderData.creditCard
                orderData.setupCreditCard(productPrice: product.price, threedsContractId: params.threedsContractID!, publicKetAlias: params.publicKeyAlias!)
                if verifoneResult.saveCard {
                    self.createReuseToken(encryptedCard: verifoneResult.cardData!) {
                        [weak self] success, reuseToken, error in
                        if success {
                            do {
                                guard var token = reuseToken else {
                                    return
                                }
                                token.setCardBrand(brand: verifoneResult.cardBrand!)
                                try self?.defaults.setObject(token, forKey: "reuseToken")
                            } catch let error {
                                print("Error on saving reuse token: \(error)")
                            }
                        } else {
                            print("Error on saving reuse token: \(String(describing: error))")
                        }
                        self?.startFlowWithout3ds(verifoneResult: verifoneResult)
                    }
                } else {
                    self.startFlowWithout3ds(verifoneResult: verifoneResult)
                }
            case .paypal:
                //
                // Pay by link payment method selected.
                // Verify that the payment was redirected to the expected URL and make an authorization API call.
                // If the paymentAuthorizingResult is nil, make an API call to get the approval URL.
                //
                if verifoneResult.paymentAuthorizingResult != nil {
                    self.authorizePaypal(merchantReference: self.merchantReference, transactionID: transactionID!) {[weak self] _, res, error in
                        self?.stopAnimation()
                        
                        guard error == nil else {
                            self?.showErrorResultPage(title: "Error transaction", message: error)
                            return
                        }
                        self?.showResultPage(merchantReference: self!.merchantReference)
                    }
                } else {
                    guard let params = Parameters.paypal else {
                        PaymentAuthorizingWithURL.shared.cancelPayByLink { [weak self] in
                            self?.presentedViewController?.alert(title: "\(self!.missingParams) Paypal")
                        }
                        return
                    }
                    let req = ProductsAPI.shared.initiatePaypal(returnUrl: MerchantAppConfig.expectedSuccessURL, cancelURL: MerchantAppConfig.expectedCancellURL, itemName: "\(product.title) test product from iOS SDK", price: Int(product.price) * 100, paymentProviderContract: params.paymentProviderContract!)
                    self.initiatePaypal(request: req) { _, response, error in
                        DispatchQueue.main.async {
                            guard error == nil else {
                                PaymentAuthorizingWithURL.shared.cancelPayByLink(completion: {
                                    self.showErrorResultPage(title: "Error, Check the Global Environment in MerchantConfig.", message: error)
                                })
                                
                                return
                            }
                            
                            let url = URL(string: response!.approvalURL)!
                            self.transactionID = response!.id
                            let expectedReturnURL = URLComponents(string: MerchantAppConfig.expectedSuccessURL)!
                            let expectedCancellURL = URLComponents(string: MerchantAppConfig.expectedCancellURL)!
                            PaymentAuthorizingWithURL.shared.load(webConfig: VFWebConfig(url: url, expectedRedirectUrl: [expectedReturnURL], expectedCancelUrl: [expectedCancellURL]))
                        }
                    }
                }
            case .applePay:
                self.stopAnimation()
                let res = ApplePayTokenWrapper.create(from: verifoneResult.paymentApplePayResult!.token.paymentData)
                self.initiateWalletPaymet(success: true, cardBrand: "MASTERCARD", error: "", applePayToken: res!.applePayPaymentToken)
            case .klarna:
                self.initiateKlarna()
            case .swish:
                self.initiateSwish()
            case .vipps:
                self.initiateVipps()
            case .mobilePay:
                self.initiateMobilePay()
            default:
                self.stopAnimation()
            }
        case .failure(let error):
            verifonePaymentForm = nil
            let error = error as NSError?
            // Here we can catch all possible errors
            switch error {
            case VerifoneError.cancel:
                self.stopAnimation()
                print("The form closed or cancelled by user")
            case VerifoneError.invalidPublicKey, VerifoneError.invalidCardData:
                self.stopAnimation()
                self.alert(title: "Transaction failed", message: "Required parameters are missing or invalid")
            default:
                self.stopAnimation()
                print(error!)
            }
        }
    }

    func startFlowWithout3ds(verifoneResult: VerifoneFormResult) {
        let request = RequestTransaction(amount: Int64(product.price * 100),
                                         authType: "FINAL_AUTH",
                                         captureNow: true,
                                         cardBrand: verifoneResult.cardBrand!,
                                         currencyCode: UserDefaults.standard.getCurrency(fromKey: Keys.currency),
                                         dynamicDescriptor: "M.reference",
                                         encryptedCard: verifoneResult.cardData!,
                                         merchantReference: "TEST-ECOM",
                                         paymentProviderContract: Parameters.creditCard?.paymentProviderContract,
                                         publicKeyAlias: Parameters.creditCard?.publicKeyAlias,
                                         shopperInteraction: "ECOMMERCE")

        ProductsAPI.shared.transaction(request: request) { [weak self] (result, error) in
            self?.stopAnimation()

            guard error == nil else {
                self?.alert(title: "Error transaction", message: "An error has occurred: \(error!)")
                return
            }
            self?.showResultPage(merchantReference: "\(result!.merchantReference!)")
        }
    }
}
