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

    func handleCCPaymentWithout3DS(result: VerifoneFormResult, params: Parameters) {
        if let token = checkForValidReuseToken(forKey: Keys.reuseToken, isThreedsEnabled: defaults.booleanValue(for: Keys.threedsEnabled)) {
            guard let params = Parameters.creditCard else {
                self.alert(title: "\(missingParams) CreditCard")
                self.stopAnimation()
                return
            }
            processWithTokenWithout3ds(reuseToken: token, params: params, ppc: params.paymentProviderContract!)
            return
        }
        orderData = OrderData.creditCard
        orderData.setupCreditCard(productPrice: product.getPrice(), publicKetAlias: params.publicKeyAlias!)
        if result.saveCard {
            guard let tokenScope = Parameters.creditCard?.tokenScope else {
                self.alert(title: "Missing token scope for credit card")
                self.stopAnimation()
                return
            }
            self.viewModel.createReuseToken(params: .creditCard!, tokenScope: tokenScope, encryptedCard: result.cardData!) { [weak self] reuseToken, error in
                guard let self = self else { return }
                guard error == nil else {
                    self.stopAnimation()
                    self.alert(title: "Error on saving reuse token: \(String(describing: error))")
                    return
                }
                guard let token = reuseToken else {
                    return
                }
                self.defaults.save(customObject: token, inKey: Keys.reuseToken)
                self.startFlowWithout3ds(verifoneResult: result)
            }
        } else {
            self.startFlowWithout3ds(verifoneResult: result)
        }
    }

    func checkForValidReuseToken(forKey: String, isThreedsEnabled: Bool = false) -> ResponseReuseToken? {
        guard let token = defaults.retrieve(object: ResponseReuseToken.self, fromKey: forKey), !isThreedsEnabled else {
            return nil
        }
        let isoDate = "\(token.tokenExpiryDate)T00:00:00+0000"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: isoDate)!
        if date > Date() {
            return token
        } else {
            // DELETE EXPIRED REUSE TOKEN
            debugPrint("Reuse token expired and removed")
            defaults.set(nil, forKey: forKey)
            return nil
        }
    }

    func processWithTokenWithout3ds(reuseToken: ResponseReuseToken, params: Parameters, ppc: String, cardBrand: String? = nil) {
        var request = RequestTransaction.creditCard
        request.setupCreditCardWithout3ds(productPrice: product.getPrice(),
                                          cardBrand: cardBrand,
                                          paymentProviderContract: ppc,
                                          publicKeyAlias: params.publicKeyAlias!,
                                          reuseToken: reuseToken.reuseToken)
        self.createTransaction(request: request, params: params)
    }

    func startFlowWithout3ds(verifoneResult: VerifoneFormResult) {
        let request = RequestTransaction(amount: product.getPrice(),
                                         authType: "FINAL_AUTH",
                                         captureNow: true,
                                         cardBrand: nil,
                                         currencyCode: UserDefaults.standard.getCurrency(fromKey: Keys.currency),
                                         dynamicDescriptor: "M.reference",
                                         encryptedCard: verifoneResult.cardData!,
                                         merchantReference: "TEST-ECOM",
                                         paymentProviderContract: Parameters.creditCard?.paymentProviderContract,
                                         publicKeyAlias: Parameters.creditCard?.publicKeyAlias,
                                         shopperInteraction: "ECOMMERCE")
        self.createTransaction(request: request, params: .creditCard!)
    }

    func createTransaction(request: RequestTransaction, params: Parameters) {
        self.viewModel.transaction(params: params, orderData: request) { [weak self] response, error in
            guard let self = self else { return }
            self.stopAnimation()
            guard error == nil else {
                self.showErrorResultPage(title: "Error transacion", message: error)
                return
            }
            self.showResultPage(merchantReference: "\(response!.merchantReference!)")
        }
    }
}
