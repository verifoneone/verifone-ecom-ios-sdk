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
    
    fileprivate var verifoneTheme = VerifoneSDK.defaultTheme
    private(set) var transactionId: String?
    
    let defaults = UserDefaults.standard
    var orderData: OrderData!
    var product: ItemViewModel!
    var items: [ResultData] = []
    var showCardSave = true
    var requestInProgress = false
    
    var cardHolder: String = ""
    var transactionID: String?
    
    let merchantReference = "123test"
    
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
        loadSettings()
        VerifoneSDK.defaultTheme.font = MerchantAppConfig.shared.getFont()
        VerifoneSDK.locale = MerchantAppConfig.shared.getLang()
        
        paymentConfiguration = VerifoneSDK.PaymentConfiguration(
            cardEncryptionPublicKey: MerchantAppConfig.shared.cardEncryptionPublicKey,
            paymentPanelStoreTitle: "Store Name",
            totalAmount: product.price,
            showCardSaveSwitch: showCardSave,
            allowedPaymentMethods: Array(MerchantAppConfig.shared.allowedPaymentMethods))
        threedsConfiguration = VerifoneSDK.ThreedsConfiguration(environment: .staging)
        applePayConfiguration = VerifoneSDK.ApplePayMerchantConfiguration(applePayMerchantId: "", supportedPaymentNetworks: [.amex, .discover, .visa, .masterCard], countryCode: "US", currencyCode: "USD", paymentSummaryItems: [PKPaymentSummaryItem(label: "Test Product", amount: 1.5)])
        
        verifonePaymentForm = VerifonePaymentForm(paymentConfiguration: paymentConfiguration)
        verifoneThreedsManager = Verifone3DSecureManager(threedsConfiguration: threedsConfiguration)
        
        
        orderData = OrderData(amount: product.price*100,
                              billingFirstName: "Testing",
                              billingLastName: "Tester",
                              billingAddress1: "123 test st",
                              billingCity: "Columbus",
                              billingState: "Oh",
                              billingCountryCode: "US",
                              currencyCode: "USD",
                              email: "testingtester@gmail.com",
                              merchantReference: "test123",
                              threedsContractId: MerchantAppConfig.shared.threedsContractID,
                              publicKeyAlias: MerchantAppConfig.shared.publicKeyAlias)
        
        items = [
            ResultData(image: "verifone.png", leftText: "", rightText: product.price.localized),
            ResultData(image: "success.png", rightText: "Thank you for your payment"),
            ResultData(leftText: "Customer", rightText: product.price.localized),
            ResultData(leftText: "Amount", rightText: product.price.localized),
            ResultData(leftText: "Reference", rightText: product.price.localized),
            ResultData(leftText: "Continue back to store", rightText: "Secure payments provided by Verifone"),
        ]
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
                cell.buyButton.setTitle("\("submitPay".localized()) $\(product.price)", for: .normal)
                cell.buyButton.addTarget(self,
                                         action: #selector(purchaseWithout3ds),
                                         for: .touchUpInside)
                return cell
            } else {
                let cell: BuyButtonCell = tableView.dequeueReusableCell(withIdentifier: Storyboard.buyButtonCell, for: indexPath) as! BuyButtonCell
                cell.buyButton.setTitle("\("submitPay".localized()) $\(product.price)", for: .normal)
                cell.buyButton2.setTitle("Pay without 3ds $\(product.price)", for: .normal)
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
    
    func showResultPage(merchantReference: String, cardHolder: String? = nil) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let resultVC: ResultPageVCViewController = storyboard.instantiateViewController(withIdentifier: "ResultPageVCViewController") as! ResultPageVCViewController
        if (cardHolder == nil) {
            self.items[2].rightText = ""
            self.items[2].leftText = ""
        } else {
            self.items[2].rightText = cardHolder
        }
        self.items[4].rightText = merchantReference
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
        let request = RequestReuseToken(tokenScope: "d19619ab-6a9f-412d-9e5e-c2e3860a7bd9",
                                        encryptedCard: encryptedCard,
                                        publicKeyAlias: "K1463",
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
        let request = RequestJwt(threedsContractId: MerchantAppConfig.shared.threedsContractID)
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
    
    func initiateWalletPaymet(success: Bool, cardBrand: String, error: String?, applePayToken: ApplePayToken? = nil) {
        
        let request = RequestTransaction(amount: product.price * 100,
                                         authType: "FINAL_AUTH",
                                         captureNow: true,
                                         cardBrand: cardBrand,
                                         currencyCode: "USD",
                                         dynamicDescriptor: "abc123",
                                         merchantReference: "TEST-ECOM123",
                                         paymentProviderContract: "d5dc07ec-0521-4676-ba75-96be6754eb35",
                                         shopperInteraction: "ECOMMERCE",
                                         walletType: "APPLE_PAY",
                                         walletPayload: applePayToken,
                                         scaComplianceLevel: "FORCE_3DS")
        ProductsAPI.shared.initiateWalletTransaction(request: request) { [weak self] (result, error) in
            self?.stopAnimation()
            guard error == nil else {
                self?.showErrorResultPage(title: "Error, initiate a wallet payment", message: error)
                return
            }
            // we will update it when we will get correct response...
            self?.showResultPage(merchantReference:"merchant reference", cardHolder: "static cardholder")
            
        }
    }
    
    func isTokenExpired(tokenExpiryDate: String) -> Bool {
        let isoDate = "\(tokenExpiryDate)T00:00:00+0000"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from:isoDate)!
        if (date < Date()) {
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
            if (value == "checked") {
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

//MARK: Initialize Klarna
extension ProductDetailsViewController: KlarnaVCDelegate {
    func initiateKlarna() {
        let request = RequestTransaction(amount: product.price * 100,
                                         authType: "FINAL_AUTH",
                                         captureNow: false,
                                         customer: "",
                                         redirectUrl: "",
                                         entityId: "",
                                         purchaseCountry: "SE",
                                         currencyCode: "SEK",
                                         dynamicDescriptor: "TEST AUTOMATION ECOM",
                                         merchantReference: "5678",
                                         paymentProviderContract: "",
                                         shopperInteraction: "",
                                         locale: AppLocale(countryCode: "SE", language: "en"),
                                         lineItems: [LineItem(
                                            imageURL: "https://demo.klarna.se/fashion/kp/media/wysiwyg/Accessoriesbagimg.jpg",
                                            type: "physical", reference: "AccessoryBag-Ref-ID-0001",
                                            name: "string", quantity: 1, unitPrice: Int(product.price) * 100,
                                            taxRate: 0, discountAmount: 0, totalTaxAmount: 0,
                                            totalAmount: Int(product.price) * 100, sku: "string", lineItemDescription: "string",
                                            category: "DIGITAL_GOODS")
                                        ]
        )
        
        ProductsAPI.shared.initiateTransaction(url: "\(MerchantAppConfig.baseURL)/api/v2/transactions/klarna", request: request, forceSetToken: "") { [weak self] (result, error) in
            guard error == nil else {
                self?.showErrorResultPage(title: "Error, initiate klarna", message: error)
                return
            }
            
            if let clientToken = result!.clientToken {
                self?.transactionId = result!.id
                let vc = KlarnaVC(clientToken: clientToken)
                vc.delegate = self
                self?.presentPanModal(vc)
            }
        }
    }
    
    func completeKlarna(transactionId: String?, authToken: String?) {
        
        if (transactionId == nil || authToken == nil) {
            self.stopAnimation()
            return
        }
        
        let request = AuthToken(authorizationToken: authToken!)
        requestInProgress = true
        ProductsAPI.shared.completeKlarna(url: "\(MerchantAppConfig.baseURL)/api/v2/transactions/\(transactionId!)/klarna_complete", request: request, forceSetToken: "") { [weak self] (result, error) in
            self?.stopAnimation()
            self?.requestInProgress = false
            guard error == nil else {
                self?.showErrorResultPage(title: "Error, complete klarna", message: error)
                return
            }
        
            self?.showResultPage(merchantReference: result?.instoreReference ?? "", cardHolder: nil)
        }
    }
    
    func didReceiveFinilizeToken(authToken: String?) {
        if (!requestInProgress) {
            self.completeKlarna(transactionId: self.transactionId, authToken: authToken)
        }
    }
}
