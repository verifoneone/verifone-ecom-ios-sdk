//
//  ProductDetailsVC+ThreedsPaymentFlow.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 23.12.2021.
//

import UIKit
import VerifoneSDK

//
// Handle with 3ds payment flow
//
extension ProductDetailsViewController {
    @objc func purchase(sender: UIButton) {
        
        self.setupRequiredTestParams()
        if let cell: BuyButtonCell = sender.superview!.superview as? BuyButtonCell {
            cell.buyButton.isEnabled = false
            cell.buyButton2.isEnabled = false
            cell.buyButton.accessibilityTraits.insert(UIAccessibilityTraits.notEnabled)
            cell.activityIndicator.startAnimating()
        }

        do {
            let token = try defaults.getObject(forKey: "reuseToken", castTo: ResponseReuseToken.self)
            if GlobalENV != Env.CST_FOR_REUSE_TOKEN {
                throw VerifoneError.merchantNotSupport3DS
            }
            if (!isTokenExpired(tokenExpiryDate: token.tokenExpiryDate)) {
                proccessWithToken(reuseToken: token)
            } else {
                self.alert(title: "Token", message: "The token expired, recreate token.")
            }
        } catch {
            verifonePaymentForm.displayPaymentForm(from: self) { [weak self] result in
                self?.didCardEncrypted(result)
            }
        }

    }
    
    func proccessWithToken(reuseToken: ResponseReuseToken) {
        self.getJwt { [weak self] success, responseJwt, error in
            if success {
                self?.setupThreedsManager(jwt: responseJwt!.jwt, cardHolder: "", cardBrand: "VISA", reuseToken: reuseToken.reuseToken)
            } else {
                self?.stopAnimation()
                self?.showErrorResultPage(title: "Create Jwt", message: error)
            }
        }
    }
    
    func startFlow(verifoneResult: VerifoneFormResult) {
        self.getJwt { [weak self] success, responseJwt, error in
            if success {
                self?.setupThreedsManager(jwt: responseJwt!.jwt, cardHolder: verifoneResult.cardHolder!, cardBrand: verifoneResult.cardBrand!, cardData: verifoneResult.cardData!)
            } else {
                self?.stopAnimation()
                self?.showErrorResultPage(title: "Create Jwt", message: error)
            }
        }
    }
    
    func didCardEncrypted(_ result: Result<VerifoneFormResult, Error>) {
        switch result {
        case .success(let verifoneResult):
            switch verifoneResult.paymentMethodType {
            case .creditCard:
                print("State of save card switch \(verifoneResult.saveCard)")
                if (verifoneResult.saveCard) {
                    self.createReuseToken(encryptedCard: verifoneResult.cardData!) {
                        [weak self] success, reuseToken, error in
                        if success {
                            do {
                                try self?.defaults.setObject(reuseToken!, forKey: "reuseToken")
                            } catch (let error) {
                                print("Error on saving reuse token: \(error)")
                            }
                        }
                        self?.startFlow(verifoneResult: verifoneResult)
                    }
                } else {
                    self.startFlow(verifoneResult: verifoneResult)
                }
            case .paypal:
                //
                // Pay by link payment method selected.
                // Verify that the payment was redirected to the expected URL and make an authorization API call.
                // If the redirect URL is nil, make an API call to get the approval URL.
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
                            let url = URL(string: response!.approvalURL)!
                            self.transactionID = response!.id
                            let expectedReturnURL = URLComponents(string: MerchantAppConfig.expectedSuccessURL)!
                            let expectedCancelURL = URLComponents(string: MerchantAppConfig.expectedCancellURL)!
                            PaymentAuthorizingWithURL.shared.load(webConfig: VFWebConfig(url: url, expectedRedirectUrl: [expectedReturnURL], expectedCancelUrl: [expectedCancelURL]))
                        }
                    }
                }
            case .applePay:
                self.stopAnimation()
                let res = ApplePayTokenWrapper.create(from: verifoneResult.paymentApplePayResult!.token.paymentData)
                if let result = res {
                    self.initiateWalletPaymet(success: true, cardBrand: "MASTERCARD", error: "", applePayToken: result.applePayPaymentToken)
                } else {
                    self.alert(title: "Apple pay", message: "Payment token is nil, try to test the app on a real device")
                }
            case .klarna:
                self.initiateKlarna()
                
            default: break;
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
    
    func setupThreedsManager(jwt: String, cardHolder: String, cardBrand: String, cardData: String? = nil, reuseToken: String? = nil) {
        
        if let cardData = cardData {
            self.orderData.setEncryptedCard(encryptedCard: cardData)
        }
        
        if let reuseToken = reuseToken {
            self.orderData.setReuseToken(reuseToken: reuseToken)
        }
        
        self.verifoneThreedsManager.setup(with: jwt, completion: { consumerId in
            self.orderData.setDeviceId(sessionId: consumerId)
            self.cardHolder = cardHolder
            self.lookup(request: self.orderData) { success, responseLookup, error in
                if success {
                    if (responseLookup!.threedsVersion!.split(separator: ".")[0] == "2") {
                        self.verifoneThreedsManager.complete3DSecureValidation(with: responseLookup!.transactionID!, payload: responseLookup!.payload!) { serverJwt in
                            let request = RequestValidate(
                                authenticationId: responseLookup!.authenticationID!,
                                jwt: serverJwt,
                                threedsContractId: self.orderData.threedsContractId)
                            self.validate(request: request) { [weak self] success, validateResponse, error in
                                if success {
                                    self?.validateResponse(success: success, cardBrand: cardBrand, validateResponse: validateResponse, error: error, lookupResponse: responseLookup!, cardData: cardData, reuseToken: reuseToken)
                                } else {
                                    self?.stopAnimation()
                                    self?.alert(title: "Validate error", message: error!)
                                }
                            }
                        } didFailed: {
                            self.stopAnimation()
                            self.alert(title: "ThreeDs error", message: "check params for 3ds continue session")
                        }
                    } else {
                        self.stopAnimation()
                        self.alert(title: "3ds error", message: "The sdk doesn't support threeds v1.")
                    }
                } else {
                    self.stopAnimation()
                    self.alert(title: "Lookup error", message: error!)
                }
            }
        }, failure: { cardinalResponse in
            self.stopAnimation()
            self.alert(title: "Cardinal setup", message: cardinalResponse.errorDescription)
        })
    }
    
    func validateResponse(success: Bool, cardBrand: String, validateResponse: ValidateResponse?, error: String?, lookupResponse: ResponseLookup, cardData: String? = nil, reuseToken: String? = nil) {
        
        guard let validationResponse = validateResponse else {
            return
        }
        
        let additionalData = AdditionalData(deviceChannel: "SDK",
                                            acsUrl: lookupResponse.acsURL ?? "")
        let threedAuthentication = ThreedAuthentication(cavv: validationResponse.validationResult?.cavv ?? "",
                                                        dsTransactionId: lookupResponse.dsTransactionID ?? "",
                                                        enrolled: "Y",
                                                        errorDesc: validationResponse.errorDesc ?? "",
                                                        errorNo: validationResponse.errorNo ?? "",
                                                        eciFlag: validationResponse.validationResult?.eciFlag ?? "",
                                                        paresStatus: validationResponse.validationResult?.paresStatus ?? "",
                                                        signatureVerification: validationResponse.validationResult?.signatureVerification ?? "",
                                                        threedsVersion: "2.1.0",
                                                        additionalData: additionalData)
        let request = RequestTransaction(amount: product.price * 100,
                                                    authType: "FINAL_AUTH",
                                                    captureNow: true,
                                                    cardBrand: cardBrand,
                                                    currencyCode: "USD",
                                                    dynamicDescriptor: "M.reference",
                                                    encryptedCard: cardData,
                                                    merchantReference: "TEST-ECOM",
                                         paymentProviderContract: MerchantAppConfig.shared.paymentProviderContract,
                                         publicKeyAlias: MerchantAppConfig.shared.publicKeyAlias,
                                                    shopperInteraction: "ECOMMERCE",
                                                    threedAuthentication: threedAuthentication,
                                                    reuseToken: reuseToken)
        ProductsAPI.shared.transaction(request: request) { [weak self] (result, error) in
            self?.stopAnimation()
            
            guard error == nil else {
                self?.showErrorResultPage(title: "Error transaction", message: error)
                return
            }
            self?.showResultPage(merchantReference:"\(result!.merchantReference!)", cardHolder: self!.cardHolder)
            
        }
    }
}
