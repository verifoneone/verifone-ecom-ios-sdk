import Foundation
import VerifoneSDK

// MARK: PayPal Initialization and Authorization
extension ProductDetailsViewController {
    func handlePaypalPaymentFlow(result: VerifoneFormResult) {
        guard let params = Parameters.paypal else {
            PaymentAuthorizingWithURL.shared.cancelPayByLink { [weak self] in
                self?.presentedViewController?.alert(title: "\(self!.missingParams) Paypal")
            }
            return
        }
        if result.paymentAuthorizingResult != nil {
            self.viewModel.authorizePaypal(params: params, merchantReference: self.merchantReference, transactionID: transactionID!) {[weak self] _, error in
                guard let self = self else { return }
                self.stopAnimation()
                guard error == nil else {
                    self.showErrorResultPage(title: "Error transaction", message: error)
                    return
                }
                self.showResultPage(merchantReference: self.merchantReference)
            }
        } else {
            var request = PaypalTransaction.paypal
            request.setupPaypal(returnUrl: MerchantAppConfig.expectedSuccessURL, cancelURL: MerchantAppConfig.expectedCancellURL, itemName: "\(product.title) test product from iOS SDK", price: product.getPrice(), paymentProviderContract: params.paymentProviderContract!)
            self.viewModel.initiatePaypal(params: params, request: request) {[weak self] response, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    guard error == nil else {
                        PaymentAuthorizingWithURL.shared.cancelPayByLink(completion: {
                            self.showErrorResultPage(title: "Error", message: error)
                        })
                        return
                    }
                    let url = URL(string: response!.approvalURL)!
                    self.transactionID = response!.id
                    let expectedReturnURL = URLComponents(string: MerchantAppConfig.expectedSuccessURL)!
                    let expectedCancelURL = URLComponents(string: MerchantAppConfig.expectedCancellURL)!
                    PaymentAuthorizingWithURL.shared.load(webConfig: VFWebConfig(url: url, expectedRedirectUrl: [expectedReturnURL], expectedCancelUrl: [expectedCancelURL]))
                }
            }
        }
    }
}
