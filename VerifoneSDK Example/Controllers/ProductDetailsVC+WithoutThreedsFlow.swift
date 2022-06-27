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
            if (!isTokenExpired(tokenExpiryDate: token.tokenExpiryDate)) {
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
        self.cardHolder = ""
        let request = RequestTransaction(
            amount: product.price * 100,
            authType: "FINAL_AUTH",
            captureNow: true,
            cardBrand: reuseToken.brand,
            currencyCode: "USD",
            dynamicDescriptor: "M.reference",
            merchantReference: "TEST-ECOM",
            paymentProviderContract: MerchantAppConfig.shared.paymentProviderContract,
            publicKeyAlias: MerchantAppConfig.shared.publicKeyAlias,
            shopperInteraction: "ECOMMERCE",
            reuseToken: reuseToken.reuseToken)
        ProductsAPI.shared.transaction(request: request) { [weak self] (result, error) in
            self?.stopAnimation()
            
            guard error == nil else {
                self?.alert(title: "Error transaction", message: "An error has occurred: \(error!)")
                return
            }
            self?.showResultPage(merchantReference:"\(result!.merchantReference!)", cardHolder: self!.cardHolder)
        }
    }
    
    func didCardEncryptedForWithout3ds(_ result: Result<VerifoneFormResult, Error>) {
        switch result {
        case .success(let verifoneResult):
            switch verifoneResult.paymentMethodType {
            case .creditCard:
                self.cardHolder = verifoneResult.cardHolder!
                print("State of save card switch \(verifoneResult.saveCard)")
                if (verifoneResult.saveCard) {
                    self.createReuseToken(encryptedCard: verifoneResult.cardData!) {
                        [weak self] success, reuseToken, error in
                        if success {
                            do {
                                guard var token = reuseToken else {
                                    return
                                }
                                token.setCardBrand(brand: verifoneResult.cardBrand!)
                                try self?.defaults.setObject(token, forKey: "reuseToken")
                            } catch (let error) {
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
                if (verifoneResult.paymentAuthorizingResult != nil) {
                    self.authorizePaypal(merchantReference: self.merchantReference, transactionID: transactionID!) {[weak self] success, res, error in
                        self?.stopAnimation()
                        
                        guard error == nil else {
                            self?.showErrorResultPage(title: "Error transaction", message: error)
                            return
                        }
                        self?.showResultPage(merchantReference: res!.instoreReference, cardHolder: "\(res!.payer.name.firstName) \(res!.payer.name.lastName)")
                    }
                } else {
                    let req = ProductsAPI.shared.initiatePp(returnUrl: MerchantAppConfig.expectedSuccessURL, cancelURL: MerchantAppConfig.expectedCancellURL, itemName: "\(product.title) test product from iOS SDK", price: Int(product.price) * 100)
                    self.initiatePaypal(request: req) { success, response, error in
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
            default: break
            }
        case .failure(let error):
            verifonePaymentForm = nil
            let error = error as NSError?
            // Here we can catch all possible errors
            switch error {
            case VerifoneError.cancel:
                self.stopAnimation()
                print("The form closed or cancelled by user")
            case VerifoneError.invalidCardData:
                self.stopAnimation()
                print("Missing card encryption public Key")
            default:
                self.stopAnimation()
                print(error!)
            }
        }
    }
    
    func startFlowWithout3ds(verifoneResult: VerifoneFormResult) {
        let request = RequestTransaction(amount: product.price * 100,
                                         authType: "FINAL_AUTH",
                                         captureNow: true,
                                         cardBrand: verifoneResult.cardBrand!,
                                         currencyCode: "USD",
                                         dynamicDescriptor: "M.reference",
                                         encryptedCard: verifoneResult.cardData!,
                                         merchantReference: "TEST-ECOM",
                                         paymentProviderContract: MerchantAppConfig.shared.paymentProviderContract,
                                         publicKeyAlias: MerchantAppConfig.shared.publicKeyAlias,
                                         shopperInteraction: "ECOMMERCE")
        ProductsAPI.shared.transaction(request: request) { [weak self] (result, error) in
            self?.stopAnimation()
            
            guard error == nil else {
                self?.alert(title: "Error transaction", message: "An error has occurred: \(error!)")
                return
            }
            self?.showResultPage(merchantReference:"\(result!.merchantReference!)", cardHolder: self!.cardHolder)
        }
    }
}



