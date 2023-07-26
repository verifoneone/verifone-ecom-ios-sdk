//
//  ProductDetailsVC+ThreedsPaymentFlow.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 23.12.2021.
//

import UIKit
import VerifoneSDK

//
// Handle gift card flow
//
extension ProductDetailsViewController {
    func handleGiftCard(result: VerifoneFormResult, params: Parameters) {
        if let token = checkForValidReuseToken(forKey: Keys.reuseTokenForGiftCard, isThreedsEnabled: false) {
            guard let params = Parameters.creditCard, Parameters.giftCard != nil else {
                self.alert(title: "\(missingParams) GiftCard or CreditCard")
                self.stopAnimation()
                return
            }
            processWithTokenWithout3ds(reuseToken: token, params: params, ppc: Parameters.giftCard!.paymentProviderContract!, cardBrand: "GIFT_CARD")
            return
        }

        let request = RequestTransaction(amount: product.getPrice(),
                                         authType: "FINAL_AUTH",
                                         captureNow: true,
                                         cardBrand: result.cardBrand,
                                         currencyCode: UserDefaults.standard.getCurrency(fromKey: Keys.currency),
                                         dynamicDescriptor: "M.reference",
                                         encryptedCard: result.cardData!,
                                         merchantReference: "TEST-ECOM",
                                         paymentProviderContract: Parameters.giftCard!.paymentProviderContract,
                                         publicKeyAlias: params.publicKeyAlias,
                                         shopperInteraction: "ECOMMERCE")
        if result.saveCard {
            guard let tokenScope = Parameters.giftCard?.tokenScope else {
                self.alert(title: "Missing token scope for gift card")
                self.stopAnimation()
                return
            }
            self.viewModel.createReuseToken(params: .giftCard!, tokenScope: tokenScope, encryptedCard: result.cardData!) { [weak self] reuseToken, error in
                guard let self = self else { return }
                guard error == nil else {
                    self.stopAnimation()
                    self.alert(title: "Error on saving reuse token: \(String(describing: error))")
                    return
                }
                guard let token = reuseToken else {
                    return
                }
                self.defaults.save(customObject: token, inKey: Keys.reuseTokenForGiftCard)
                self.createTransaction(request: request, params: .giftCard!)
            }
        } else {
            self.createTransaction(request: request, params: .giftCard!)
        }
    }
}

//
// Handle with 3ds payment flow
//
extension ProductDetailsViewController {

    func handleCCPaymentWith3DS(result: VerifoneFormResult, params: Parameters) {
        orderData = OrderData.creditCard
        orderData.setupCreditCard3DS(productPrice: product.getPrice(),
                                     threedsContractId: params.threedsContractID!,
                                     publicKetAlias: params.publicKeyAlias!,
                                     currencyCode: UserDefaults.standard.getCurrency(fromKey: Keys.currency))
        self.startFlow(verifoneResult: result)
    }

    func startFlow(verifoneResult: VerifoneFormResult) {
        self.viewModel.getJWT(orderData: orderData) { [weak self] response, error in
            guard let self = self else { return }
            guard error == nil else {
                self.stopAnimation()
                self.showErrorResultPage(title: "Create Jwt", message: error)
                return
            }
            self.setupThreedsManager(jwt: response!.jwt, cardBrand: nil, cardData: verifoneResult.cardData!)
        }
    }

    func setupThreedsManager(jwt: String, cardBrand: String?, cardData: String? = nil, reuseToken: String? = nil) {
        if let cardData = cardData {
            self.orderData.setEncryptedCard(encryptedCard: cardData)
        }
        self.verifoneThreedsManager.setup(with: jwt, completion: { consumerId in
            self.orderData.setDeviceId(sessionId: consumerId)
            self.viewModel.lookup(orderData: self.orderData) { [weak self] responseLookup, error in
                guard let self = self else { return }
                guard error == nil else {
                    self.stopAnimation()
                    self.showErrorResultPage(title: "Lookup error", message: error)
                    return
                }
                guard responseLookup!.threedsVersion!.split(separator: ".")[0] == "2" else {
                    self.stopAnimation()
                    self.alert(title: "3ds error", message: "The sdk doesn't support threeds v1.")
                    return
                }

                guard let payload = responseLookup?.payload else {
                    self.stopAnimation()
                    self.alert(title: "Lookup reponse error", message: "The payload parameter is empty. try with different test card")
                    return
                }

                self.verifoneThreedsManager.complete3DSecureValidation(with: responseLookup!.transactionID!, payload: payload) { serverJwt in
                    self.viewModel.validate(orderData: self.orderData, responseLookup: responseLookup!, serverJwt: serverJwt) { [weak self] validateResponse, error in
                        guard let self = self else { return }
                        guard error == nil || validateResponse == nil else {
                            self.stopAnimation()
                            self.showErrorResultPage(title: "Lookup error", message: error)
                            return
                        }
                        self.viewModel.validateResponse(price: self.product.getPrice(),
                                                        cardBrand: cardBrand,
                                                        validateResponse: validateResponse!,
                                                        lookupResponse: responseLookup!, cardData: cardData) { res, error in
                            guard error == nil else {
                                self.showErrorResultPage(title: "Error transaction", message: error)
                                return
                            }
                            self.showResultPage(merchantReference: "\(res!.merchantReference!)")
                        }
                    }
                } didFailed: {
                    self.stopAnimation()
                    self.alert(title: "ThreeDs error", message: "check params for 3ds continue session")
                }
            }
        }, failure: { cardinalResponse in
            self.stopAnimation()
            self.alert(title: "Cardinal setup", message: cardinalResponse.errorDescription)
        })
    }
}
