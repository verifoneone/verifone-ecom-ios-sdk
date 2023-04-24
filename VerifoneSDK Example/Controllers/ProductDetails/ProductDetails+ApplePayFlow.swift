import Foundation
import VerifoneSDK

// MARK: - ApplePay Payment Flow
extension ProductDetailsViewController {
    func handleApplePayPaymentFlow(result: VerifoneFormResult) {
        self.stopAnimation()
        let res = ApplePayTokenWrapper.create(from: result.paymentApplePayResult!.token.paymentData)
        if let result = res {
            self.initiateApplePay(success: true, cardBrand: "MASTERCARD", error: "", applePayToken: result.applePayPaymentToken)
        } else {
            self.alert(title: "Apple pay", message: "Payment token is nil, try to test the app on a real device")
        }
    }

    func initiateApplePay(success: Bool, cardBrand: String, error: String?, applePayToken: ApplePayToken? = nil) {
        var request = RequestTransaction.applePay
        guard let params = Parameters.applePay else {
            self.alert(title: "\(missingParams) ApplePay")
            self.stopAnimation()
            return
        }

        request.setupApplePay(productPrice: product.getPrice(), cardBrand: cardBrand, paymentProviderContract: params.paymentProviderContract!, walletPayload: applePayToken!)
        self.viewModel.initiateTransaction(params: params, request: request) { [weak self] _, error in
            guard let self = self else { return }
            self.stopAnimation()
            guard error == nil else {
                self.showErrorResultPage(title: "Error, initiate a wallet payment", message: error)
                return
            }
            // we will update it when we will get correct response...
            self.showResultPage(merchantReference: "merchant reference")
        }
    }
}
