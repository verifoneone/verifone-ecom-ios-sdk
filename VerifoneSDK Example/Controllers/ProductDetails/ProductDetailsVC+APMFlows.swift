import Foundation
import VerifoneSDK

// MARK: Init Swish
extension ProductDetailsViewController {
    fileprivate var errorMessage: String {
        return "Something went wrong, check parameters, ensure that your wallet app is installed, and refer to the integration section in the documentation."
    }

    func initiateSwish() {
        guard VerifoneSDK.isSwishAppAvailable() else {
            self.alert(title: "Swish app not found")
            self.stopAnimation()
            return
        }
        guard let params = Parameters.swish else {
            self.alert(title: "\(missingParams) Swish")
            self.stopAnimation()
            return
        }
        var request = RequestTransaction.swish
        request.setupSwish(productPrice: product.getPrice(), entityId: params.entityId!)
        self.viewModel.initiateTransaction(params: params, request: request, wallet: "swish") { [weak self] response, error in
            guard let self = self else { return }
            guard error == nil else {
                self.showErrorResultPage(title: "Error, initiate swish", message: error)
                self.stopAnimation()
                return
            }

            if let paymentRequestToken = response?.paymentRequestToken, let id = response?.id {
                self.merchantReference = response?.merchantReference ?? ""
                VerifoneSDK.authorizeSwishPayment(token: paymentRequestToken, returnUrl: Keys.testAppScheme) { [weak self] in
                    guard let self = self else { return }
                    self.checkTransaction(transactionId: id, params: .swish!, paymentType: .swish)
                } failure: {
                    self.stopAnimation()
                    self.alert(title: self.errorMessage)
                }
            }
        }
    }

    func checkTransaction(transactionId: String, params: Parameters, paymentType: AppPaymentMethodType) {
        // Delayed for 5 seconds while transaction status changed.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.viewModel.checkTransaction(params: params, transactionId: transactionId) { [weak self] response, error in
                guard let self = self else { return }
                self.stopAnimation()
                guard error == nil else {
                    self.showErrorResultPage(title: "Error, complete \(paymentType.rawValue)", message: error)
                    return
                }
                if response?.status != nil && response?.status == "AUTHORIZED" ||
                    response?.status == "SALE SETTLED" || response?.status == "SALE AUTHORISED" {
                    self.showResultPage(merchantReference: self.merchantReference)
                } else {
                    self.showErrorResultPage(title: "Error, complete \(paymentType.rawValue). Status: \(response?.status ?? "")", message: error)
                }
            }
        }
    }
}

// MARK: Init Vipps
extension ProductDetailsViewController {
    func initiateVipps() {
        guard VerifoneSDK.isVippsAppAvailable() else {
            self.alert(title: "Vipps app not found")
            self.stopAnimation()
            return
        }
        guard let params = Parameters.vipps else {
            self.alert(title: "\(missingParams) Vipps")
            self.stopAnimation()
            return
        }
        var request = RequestTransaction.vipps
        request.setupVipps(productPrice: product.getPrice(),
                           paymentProviderContract: params.paymentProviderContract!, customer: params.customer!)
        self.viewModel.initiateTransaction(params: params, request: request, wallet: "vipps") { [weak self] response, error in
            guard let self = self else { return }
            guard error == nil else {
                self.showErrorResultPage(title: "Error, initiate vipps", message: error)
                self.stopAnimation()
                return
            }
            if var redirectToken = response!.redirectUrl, let id = response?.id {
                self.merchantReference = response?.merchantReference ?? ""
                if let range = redirectToken.range(of: "token=") {
                    redirectToken = String(redirectToken[range.upperBound...])
                }
                VerifoneSDK.authorizeVippsPayment(token: redirectToken, returnUrl: Keys.testAppScheme) { [weak self] in
                    guard let self = self else { return }
                    self.checkTransaction(transactionId: id, params: .vipps!, paymentType: .vipps)
                } failure: {
                    self.stopAnimation()
                    self.alert(title: self.errorMessage)
                }

            }
        }
    }
}

// MARK: Init Mobile
extension ProductDetailsViewController {
    func initiateMobilePay() {
        guard VerifoneSDK.isMobilePayAppAvailable() else {
            self.alert(title: "MobilePay app not found")
            self.stopAnimation()
            return
        }
        guard let params = Parameters.mobilePay else {
            self.alert(title: "\(missingParams) MobielPay")
            self.stopAnimation()
            return
        }
        var request = RequestTransaction.mobilePay
        request.setupMobilePay(productPrice: product.getPrice(),
                               paymentProviderContract: params.paymentProviderContract!, customer: params.customer!)
        self.viewModel.initiateTransaction(params: params, request: request, wallet: "mobilepay") { [weak self] response, error in
            guard let self = self else { return }
            guard error == nil else {
                self.showErrorResultPage(title: "Error, initiate mobilePay", message: error)
                self.stopAnimation()
                return
            }
            if let redirectToken = response!.redirectUrl, let id = response?.id {
                self.merchantReference = response?.merchantReference ?? ""
                let paymentId = redirectToken.components(separatedBy: "id=")
                VerifoneSDK.authorizeMobilePayPayment(token: paymentId[1], returnUrl: Keys.testAppScheme) { [weak self] in
                    guard let self = self else { return }
                    self.checkTransaction(transactionId: id, params: .mobilePay!, paymentType: .mobilePay)
                } failure: {
                    self.stopAnimation()
                    self.alert(title: self.errorMessage)
                }
            }
        }
    }
}
