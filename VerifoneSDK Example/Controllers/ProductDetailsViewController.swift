//
//  ProductDetailsViewController.swift
//  sdkTest
//
//  Created by Oraz Atakishiyev on 17.09.2021.
//

import UIKit
import VerifoneSDK
import PassKit

class ProductDetailsViewController: UITableViewController {

    var verifonePaymentForm: VerifonePaymentForm!
    var verifoneThreedsManager: Verifone3DSecureManager!
    var paymentConfiguration: VerifoneSDK.PaymentConfiguration!
    var threedsConfiguration: VerifoneSDK.ThreedsConfiguration!
    var applePayConfiguration: VerifoneSDK.ApplePayMerchantConfiguration!
    var klarnaVC: KlarnaVC!

    fileprivate var verifoneTheme = VerifoneSDK.defaultTheme
    private(set) var transactionId: String?
    private(set) var customer: String?
    private let nc = NotificationCenter.default

    let defaults = UserDefaults.standard
    var orderData: OrderData!
    var product: ItemViewModel!
    var items: [ResultData] = []
    var showCardSave = true
    var requestInProgress = false

    var transactionID: String?
    var merchantReference: String = "123test"
    public var missingParams: String = "Missing required parameters for"

    private(set) var merchantConfig: MerchantAppConfig!

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRequiredTestParams()
        title = product.title
        imageView.image = UIImage(named: product.image)!

        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableView.automaticDimension
    }

    struct Storyboard {
        static let shoeDetailCell = "ProductDetailCell"
        static let buyButtonCell = "BuyButtonCell"
        static let buyButtonCellWithSingleButton = "BuyButtonCellWithSingleButton"
    }

    func setupRequiredTestParams() {
        merchantConfig = MerchantAppConfig.shared
        loadSettings()
        VerifoneSDK.defaultTheme.font = merchantConfig.getFont()
        VerifoneSDK.locale = merchantConfig.getLang()

        paymentConfiguration = VerifoneSDK.PaymentConfiguration(
            cardEncryptionPublicKey: Parameters.creditCard == nil ? nil : Parameters.creditCard!.encryptionKey!,
            paymentPanelStoreTitle: "Store Name",
            totalAmount: "\(product.price) \(UserDefaults.standard.getCurrency(fromKey: Keys.currency))",
            showCardSaveSwitch: showCardSave,
            allowedPaymentMethods: Array(merchantConfig.allowedPaymentMethods))
        threedsConfiguration = VerifoneSDK.ThreedsConfiguration(environment: .staging)
        applePayConfiguration = VerifoneSDK.ApplePayMerchantConfiguration(
            applePayMerchantId: "", supportedPaymentNetworks: [.amex, .discover, .visa, .masterCard],
            countryCode: "US",
            currencyCode: UserDefaults.standard.getCurrency(fromKey: Keys.currency),
            paymentSummaryItems: [PKPaymentSummaryItem(label: "Test Product", amount: 1.5)])

        verifonePaymentForm = VerifonePaymentForm(paymentConfiguration: paymentConfiguration)
        verifoneThreedsManager = Verifone3DSecureManager(threedsConfiguration: threedsConfiguration)

        items = [
            ResultData(image: "verifone.png", leftText: "", rightText: product.price.localized),
            ResultData(image: "success.png", rightText: "Thank you for your payment"),
            ResultData(leftText: "Amount", rightText: product.price.localized),
            ResultData(leftText: "Reference", rightText: product.price.localized),
            ResultData(leftText: "Continue back to store", rightText: "Secure payments provided by Verifone")
        ]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.nc.addObserver(self, selector: #selector(self.completeSwitchAppPayment(_:)), name: Keys.appSwitchNotificationName, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nc.removeObserver(self, name: Keys.appSwitchNotificationName, object: nil)
    }
}

extension ProductDetailsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell: ProductDetailCell = tableView.dequeueReusableCell(withIdentifier: Storyboard.shoeDetailCell, for: indexPath) as! ProductDetailCell
            cell.product = product
            return cell
        } else {
            if GlobalENV == Env.CST_FOR_REUSE_TOKEN {
                let cell: BuyButtonCellWithSingleButton = tableView.dequeueReusableCell(withIdentifier: Storyboard.buyButtonCellWithSingleButton, for: indexPath) as! BuyButtonCellWithSingleButton
                cell.buyButton.setTitle("\("submitPay".localized()) \(product.price) \(UserDefaults.standard.getCurrency(fromKey: Keys.currency))", for: .normal)
                cell.buyButton.addTarget(self,
                                         action: #selector(purchaseWithout3ds),
                                         for: .touchUpInside)
                return cell
            } else {
                let cell: BuyButtonCell = tableView.dequeueReusableCell(withIdentifier: Storyboard.buyButtonCell, for: indexPath) as! BuyButtonCell
                cell.buyButton.setTitle("\("submitPay".localized()) (3ds) \(product.price) \(UserDefaults.standard.getCurrency(fromKey: Keys.currency))", for: .normal)
                cell.buyButton2.setTitle("\("submitPay".localized()) \(product.price) \(UserDefaults.standard.getCurrency(fromKey: Keys.currency))", for: .normal)
                cell.buyButton.addTarget(self,
                                         action: #selector(purchase),
                                         for: .touchUpInside)
                cell.buyButton2.addTarget(self,
                                          action: #selector(purchaseWithout3ds),
                                          for: .touchUpInside)
                return cell
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return 65
        }
        return UITableView.automaticDimension
    }

    func showResultPage(merchantReference: String) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let resultVC: ResultPageVCViewController = storyboard.instantiateViewController(withIdentifier: "ResultPageVCViewController") as! ResultPageVCViewController
        self.items[3].rightText = merchantReference
        resultVC.items = self.items
        self.present(resultVC, animated: true, completion: nil)
    }

    func showErrorResultPage(title: String?, message: String?) {
        DispatchQueue.main.async {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let resultVC: ResultPageVCViewController = storyboard.instantiateViewController(withIdentifier: "ResultPageVCViewController") as! ResultPageVCViewController
            self.items[1].image = "error.png"
            self.items[1].leftText = ""
            self.items[1].rightText = title ?? ""
            self.items[2].rightText = message ?? ""
            resultVC.items = self.items
            resultVC.handleError = true
            self.presentPanModal(resultVC)
        }
    }
}

extension ProductDetailsViewController {
    func createReuseToken(encryptedCard: String, completion: @escaping (Bool, ResponseReuseToken?, String?) -> Void) {
        guard let reuseToken = Parameters.creditCard?.reuseToken else {
            self.alert(title: "Missing reuse token for credit card")
            return
        }
        let request = RequestReuseToken(tokenScope: reuseToken,
                                        encryptedCard: encryptedCard,
                                        publicKeyAlias: Parameters.creditCard!.publicKeyAlias!,
                                        tokenType: "REUSE",
                                        tokenExpiryDate: "2023-08-24")
        ProductsAPI.shared.createReuseToken(request: request) { (token, error) in
            guard error == nil else {
                completion(false, nil, error)
                return
            }
            
            guard let jwtToken = token else {
                completion(false, nil, error)
                return
            }
            
            completion(true, jwtToken, nil)
            
        }
    }
    
    func getJwt(completion: @escaping (Bool, ResponseJwt?, String?) -> Void) {
        let request = RequestJwt(threedsContractId: orderData.threedsContractId)
        ProductsAPI.shared.getJWT(request: request) { (token, error) in
            guard error == nil else {
                completion(false, nil, error)
                return
            }
            
            guard let jwtToken = token else {
                completion(false, nil, error)
                return
            }
            
            completion(true, jwtToken, nil)
        }
    }
    
    func lookup(request: OrderData, completion: @escaping (Bool, ResponseLookup?, String?) -> Void) {
        ProductsAPI.shared.lookup(request: request) { (res, error) in
            guard error == nil else {
                completion(false, nil, error)
                return
            }
            
            guard let lookResponse = res else {
                completion(false, nil, nil)
                return
            }
            
            completion(true, lookResponse, nil)
        }
    }
    
    func validate(request: RequestValidate, completion: @escaping (Bool, ValidateResponse?, String?) -> Void) {
        ProductsAPI.shared.validate(request: request) { (res, error) in
            guard error == nil else {
                completion(false, nil, error)
                return
            }
            
            guard let validateResponse = res else {
                completion(false, nil, nil)
                return
            }
            
            completion(true, validateResponse, nil)
        }
    }
    
    func initiateWalletPaymet(success: Bool, cardBrand: String, error: String?, applePayToken: ApplePayToken? = nil) {
        var request = RequestTransaction.applePay
        guard let params = Parameters.applePay else {
            self.alert(title: "\(missingParams) ApplePay")
            self.stopAnimation()
            return
        }
        
        request.setupApplePay(productPrice: product.price, cardBrand: cardBrand, paymentProviderContract: params.paymentProviderContract!, walletPayload: applePayToken!)
        
        ProductsAPI.shared.initiateWalletTransaction(request: request) { [weak self] (_, error) in
            self?.stopAnimation()
            guard error == nil else {
                self?.showErrorResultPage(title: "Error, initiate a wallet payment", message: error)
                return
            }
            // we will update it when we will get correct response...
            self?.showResultPage(merchantReference: "merchant reference")
        }
    }
    
    func isTokenExpired(tokenExpiryDate: String) -> Bool {
        let isoDate = "\(tokenExpiryDate)T00:00:00+0000"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: isoDate)!
        if date < Date() {
            return true
        }
        return false
    }
    
    func stopAnimation() {
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? BuyButtonCell {
                cell.buyButton.isEnabled = true
                cell.buyButton2.isEnabled = true
                cell.activityIndicator.stopAnimating()
                cell.activityIndicator2.stopAnimating()
            }
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? BuyButtonCellWithSingleButton {
                cell.buyButton.isEnabled = true
                cell.activityIndicator.stopAnimating()
            }
        }
    }
    
    func startAnimation() {
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? BuyButtonCell {
                cell.buyButton.isEnabled = true
                cell.buyButton2.isEnabled = true
                cell.activityIndicator.startAnimating()
                cell.activityIndicator2.startAnimating()
            }
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? BuyButtonCellWithSingleButton {
                cell.buyButton.isEnabled = true
                cell.activityIndicator.startAnimating()
            }
        }
    }
    
    func loadSettings() {
        if let color = getColor(key: "textfield_100") {
            verifoneTheme.primaryBackgorundColor = color
        }
        if let color = getColor(key: "textfield_101") {
            verifoneTheme.textfieldBackgroundColor = color
        }
        if let color = getColor(key: "textfield_102") {
            verifoneTheme.textfieldTextColor = color
        }
        if let color = getColor(key: "textfield_103") {
            verifoneTheme.labelColor = color
        }
        if let color = getColor(key: "textfield_104") {
            verifoneTheme.payButtonBackgroundColor = color
        }
        if let color = getColor(key: "textfield_105") {
            verifoneTheme.payButtonDisabledBackgroundColor = color
        }
        if let color = getColor(key: "textfield_106") {
            verifoneTheme.payButtonTextColor = color
        }
        if let color = getColor(key: "textfield_107") {
            verifoneTheme.cardTitleColor = color
        }
        if let value = defaults.string(forKey: "switch_108") {
            if value == "checked" {
                showCardSave = true
            } else {
                showCardSave = false
            }
        }
    }
    
    func getColor(key: String) -> UIColor? {
        if let value = defaults.string(forKey: key) {
            if let hex = Int(value, radix: 16) {
                return UIColorFromRGB(hex)
            }
        }
        return nil
    }
}

// MARK: Init Swish
extension ProductDetailsViewController {
    func initiateSwish() {
        guard isAppInstalled(appName: SwishParams.url) else {
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
        request.setupSwish(productPrice: product.price, entityId: params.entityId!)
        let headerFields = HeaderFields(apiUserId: params.apiUserID!, apiUserKey: params.apiKey!)
        ProductsAPI.shared.initiateTransaction(url: "\(MerchantAppConfig.shared.baseURL)/oidc/api/v2/transactions/swish", request: request, headerFields: headerFields) { [weak self] (result, error) in
            guard error == nil else {
                self?.showErrorResultPage(title: "Error, initiate swish", message: error)
                self?.stopAnimation()
                return
            }

            if let paymentRequestToken = result!.paymentRequestToken, let id = result?.id {
                print(paymentRequestToken, id)
                self?.transactionId = id
                self?.merchantReference = result?.merchantReference ?? ""
                openAppWithToken(SwishParams, paymentRequestToken)
            }
        }
    }

    func checkTransaction(transactionId: String, paymentType: PaymentMethodType) {
        var params: Parameters?
        switch paymentType {
        case .swish:
            params = Parameters.swish
        case .vipps:
            params = Parameters.vipps
        case .mobilePay:
            params = Parameters.mobilePay
        default: break
        }
        if params == nil {
            self.alert(title: "\(missingParams) \(paymentType.rawValue)")
            self.stopAnimation()
            return
        }
        let headerFields = HeaderFields(apiUserId: params!.apiUserID!, apiUserKey: params!.apiKey!)
        ProductsAPI.shared.checkTransaction(transactionId: transactionId, headerFields: headerFields) { [weak self] (result, error) in
            self?.stopAnimation()
            guard error == nil else {
                self?.showErrorResultPage(title: "Error, complete \(paymentType.rawValue)", message: error)
                return
            }
            if result?.status != nil && result?.status == "AUTHORIZED" || result?.status == "SALE SETTLED" || result?.status == "SALE AUTHORISED" {
                self?.showResultPage(merchantReference: self?.merchantReference ?? "")
            } else {
                self?.showErrorResultPage(title: "Error, complete \(paymentType.rawValue). Status: \(result?.status ?? "")", message: error)
            }
        }
    }

    @objc func completeSwitchAppPayment(_ notification: NSNotification) {
        // Delayed for 2 seconds while transaction status changed.
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if let payment = notification.userInfo?["payment"] as? String {
                var paymentMethod: PaymentMethodType!
                switch payment {
                case SwishParams.url:
                    paymentMethod = .swish
                case VippsParams.url:
                    paymentMethod = .vipps
                case MobilePayParams.url:
                    paymentMethod = .mobilePay
                default: break
                }
                self.checkTransaction(transactionId: self.transactionId!, paymentType: paymentMethod)
            }
        }
    }
}

// MARK: Initialize Klarna
extension ProductDetailsViewController: KlarnaVCDelegate {
    func initiateKlarna() {
        guard let params = Parameters.klarna else {
            self.alert(title: "\(missingParams) Klarna")
            self.stopAnimation()
            return
        }
        var request = RequestTransaction.klarna
        request.setupKlarna(productPrice: product.price,
                            customer: params.customer!,
                            entityId: params.organisationId!,
                            redirectUrl: params.redirectUrl)
        let headerFields = HeaderFields(apiUserId: params.apiUserID!, apiUserKey: params.apiKey!)
        ProductsAPI.shared.initiateTransaction(url: "\(MerchantAppConfig.shared.baseURL)/oidc/api/v2/transactions/klarna", request: request, headerFields: headerFields) { [weak self] (result, error) in
            guard error == nil else {
                self?.showErrorResultPage(title: "Error, initiate klarna", message: error)
                self?.stopAnimation()
                return
            }

            if let clientToken = result!.clientToken, let customerId = result?.customer {
                self?.transactionId = result!.id
                self?.customer = customerId
                self!.klarnaVC = KlarnaVC(delegate: self, clientToken: clientToken, urlScheme: SwishParams.callback)
                self!.present(self!.klarnaVC, animated: true)
            }
        }
    }

    func completeKlarna(transactionId: String?, authToken: String?) {
        if transactionId == nil || authToken == nil {
            self.stopAnimation()
            return
        }
        guard let params = Parameters.klarna else {
            self.alert(title: "\(missingParams) Klarna")
            self.stopAnimation()
            return
        }
        let request = AuthToken(authorizationToken: authToken!, customer: customer!)
        let headerFields = HeaderFields(apiUserId: params.apiUserID!, apiUserKey: params.apiKey!)
        requestInProgress = true
        ProductsAPI.shared.completeKlarna(url: "\(MerchantAppConfig.shared.baseURL)/oidc/api/v2/transactions/\(transactionId!)/klarna_complete", request: request, headerFields: headerFields) { [weak self] (result, error) in
            self?.stopAnimation()
            self?.requestInProgress = false
            guard error == nil else {
                self?.showErrorResultPage(title: "Error, complete klarna", message: error)
                return
            }

            self?.showResultPage(merchantReference: result?.merchantReference ?? "")
        }
    }

    func didReceiveFinilizeToken(authorizationToken: String?, error: String?) {
        if !requestInProgress {
            self.klarnaVC.dismiss(animated: true, completion: {
                self.completeKlarna(transactionId: self.transactionId, authToken: authorizationToken)
            })
        }
    }
}

// MARK: Paypal Initialise and Authorize
extension ProductDetailsViewController {
    func initiatePaypal(request: PaypalTransaction, completion: @escaping (Bool, PaypalTransactionInitiate?, String?) -> Void) {
        ProductsAPI.shared.ppInitiatePayment(request: request) { (res, error) in
            guard error == nil else {
                completion(false, nil, error)
                return
            }

            guard let ppResponse = res else {
                completion(false, nil, nil)
                return
            }
            completion(true, ppResponse, nil)
        }
    }

    func authorizePaypal(merchantReference: String, transactionID: String, completion: @escaping (Bool, PaypalTransactionResponse?, String?) -> Void) {
        ProductsAPI.shared.ppAuthorizePayment(merchantReference: merchantReference, transactionID: transactionID) { (res, error) in
            guard error == nil else {
                completion(false, nil, error)
                return
            }

            guard let ppResponse = res else {
                completion(false, nil, nil)
                return
            }
            completion(true, ppResponse, nil)
        }
    }
}

// MARK: Init Vipps
extension ProductDetailsViewController {
    func initiateVipps() {
        guard isAppInstalled(appName: VippsParams.url) else {
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
        request.setupVipps(productPrice: product.price,
                           paymentProviderContract: params.paymentProviderContract!, customer: params.customer!)
        let headerFields = HeaderFields(apiUserId: params.apiUserID!, apiUserKey: params.apiKey!)
        ProductsAPI.shared.initiateTransaction(url: "\(MerchantAppConfig.shared.baseURL)/oidc/api/v2/transactions/vipps", request: request, headerFields: headerFields) { [weak self] (result, error) in
            guard error == nil else {
                self?.showErrorResultPage(title: "Error, initiate vipps", message: error)
                self?.stopAnimation()
                return
            }
            if let redirectToken = result!.redirectUrl, let id = result?.id {
                self?.transactionId = id
                self?.merchantReference = result?.merchantReference ?? ""
                openAppWithToken(VippsParams, redirectToken)
            }
        }
    }
}

// MARK: Init Mobile
extension ProductDetailsViewController {
    func initiateMobilePay() {
        guard isAppInstalled(appName: MobilePayParams.url) else {
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
        request.setupMobilePay(productPrice: product.price,
                               paymentProviderContract: params.paymentProviderContract!, customer: params.customer!)
        let headerFields = HeaderFields(apiUserId: params.apiUserID!, apiUserKey: params.apiKey!)
        ProductsAPI.shared.initiateTransaction(url: "\(MerchantAppConfig.shared.baseURL)/oidc/api/v2/transactions/mobilepay", request: request, headerFields: headerFields) { [weak self] (result, error) in
            guard error == nil else {
                self?.showErrorResultPage(title: "Error, initiate mobilePay", message: error)
                self?.stopAnimation()
                return
            }
            if let redirectToken = result!.redirectUrl, let id = result?.id {
                self?.transactionId = id
                self?.merchantReference = result?.merchantReference ?? ""
                let paymentId = redirectToken.components(separatedBy: "id=")
                openAppWithToken(MobilePayParams, paymentId[1])
            }
        }
    }
}
