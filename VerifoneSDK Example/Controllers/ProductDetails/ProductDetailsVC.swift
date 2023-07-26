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
    var requestInProgress = false

    var transactionID: String?
    var merchantReference: String = "123test"
    public var missingParams: String = "Missing required parameters for"

    private(set) var merchantConfig: MerchantAppConfig!
    var viewModel = ProductDetailsViewModel()

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
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

    func configurePaymentSDK(validReuseToken: Bool = false, validReuseTokenForGiftCard: Bool = false) {
        merchantConfig = MerchantAppConfig.shared
        configureCardFormColors()
        VerifoneSDK.defaultTheme.font = merchantConfig.getFont()
        VerifoneSDK.locale = merchantConfig.getLang()
        
        paymentConfiguration = VerifoneSDK.PaymentConfiguration(
            cardEncryptionPublicKey: Parameters.creditCard == nil ? nil : Parameters.creditCard!.encryptionKey!,
            paymentPanelStoreTitle: "Store Name",
            totalAmount: "\(product.price) \(UserDefaults.standard.getCurrency(fromKey: Keys.currency))",
            showCardSaveSwitch: defaults.booleanValue(for: Keys.isCardSaveEnabled),
            allowedPaymentMethods: merchantConfig.allowedPaymentOptions,
            reuseTokenForCardPayment: validReuseToken,
            reuseTokenForGiftCardPayment: validReuseTokenForGiftCard
        )
        threedsConfiguration = VerifoneSDK.ThreedsConfiguration(environment: .staging)

        let billingAddress = PKContact()
        let shippingAddress = PKContact()
        let supportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard]
        let requiredShippingContactFields: Set<PKContactField> = [.name, .emailAddress, .phoneNumber, .phoneticName, .postalAddress]
        let requiredBillingContactFields: Set<PKContactField> = [.name, .emailAddress, .phoneNumber, .phoneticName, .postalAddress]

        applePayConfiguration = VerifoneSDK.ApplePayMerchantConfiguration(
            applePayMerchantId: "", supportedPaymentNetworks: [.amex, .discover, .visa, .masterCard],
            countryCode: "US",
            currencyCode: UserDefaults.standard.getCurrency(fromKey: Keys.currency),
            paymentSummaryItems: [PKPaymentSummaryItem(label: "Test Product", amount: 1.5)],
            requiredShippingContactFields: requiredShippingContactFields,
            requiredBillingContactFields: requiredBillingContactFields,
            supportedNetworks: supportedNetworks,
            billingContact: billingAddress,
            shippingContact: shippingAddress,
            shippingType: PKShippingType.delivery
        )

        verifonePaymentForm = VerifonePaymentForm(paymentConfiguration: paymentConfiguration, applepayConfiguration: applePayConfiguration)
        verifoneThreedsManager = Verifone3DSecureManager(threedsConfiguration: threedsConfiguration)

        items = [
            ResultData(image: "verifone.png", leftText: "", rightText: product.price.getCurrency()),
            ResultData(image: "success.png", rightText: "Thank you for your payment"),
            ResultData(leftText: "Amount", rightText: product.price.getCurrency()),
            ResultData(leftText: "Reference", rightText: product.price.getCurrency()),
            ResultData(leftText: "Continue back to store", rightText: "Secure payments provided by Verifone")
        ]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
            let cell: BuyButtonCell = tableView.dequeueReusableCell(withIdentifier: Storyboard.buyButtonCell, for: indexPath) as! BuyButtonCell
            cell.buyButton.setTitle("\("submitPay".localized()) \(product.price) \(UserDefaults.standard.getCurrency(fromKey: Keys.currency))", for: .normal)
            cell.buyButton.addTarget(self,
                                     action: #selector(purchase),
                                     for: .touchUpInside)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return 65
        }
        return UITableView.automaticDimension
    }

    func showResultPage(merchantReference: String) {
        self.stopAnimation()
        DispatchQueue.main.async {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let resultVC: ResultPageVCViewController = storyboard.instantiateViewController(withIdentifier: "ResultPageVCViewController") as! ResultPageVCViewController
            self.items[3].rightText = merchantReference
            resultVC.items = self.items
            self.present(resultVC, animated: true, completion: nil)
        }
    }

    func showErrorResultPage(title: String?, message: Error?) {
        var errorStr: String = ""
        if let error = message {
            if let errorDesc = error as? AppError {
                errorStr = errorDesc.errorDescription ?? ""
            } else {
                errorStr = error.localizedDescription
            }
        }
        DispatchQueue.main.async {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let resultVC: ResultPageVCViewController = storyboard.instantiateViewController(withIdentifier: "ResultPageVCViewController") as! ResultPageVCViewController
            self.items[1].image = "error.png"
            self.items[1].leftText = ""
            self.items[1].rightText = title ?? ""
            self.items[2].rightText = errorStr
            resultVC.items = self.items
            resultVC.handleError = true
            self.presentPanModal(resultVC)
        }
    }

    @objc func purchase(sender: UIButton) {
        if let cell: BuyButtonCell = sender.superview!.superview as? BuyButtonCell {
            cell.buyButton.isEnabled = false
            cell.buyButton.accessibilityTraits.insert(UIAccessibilityTraits.notEnabled)
            cell.activityIndicator.startAnimating()
        }
        self.configurePaymentSDK(
            validReuseToken: self.checkForValidReuseToken(
                forKey: Keys.reuseToken,
                isThreedsEnabled: defaults.booleanValue(for: Keys.threedsEnabled)) != nil,
            validReuseTokenForGiftCard: self.checkForValidReuseToken(
                forKey: Keys.reuseTokenForGiftCard,
                isThreedsEnabled: false) != nil
        )
        verifonePaymentForm.displayPaymentForm(from: self) { [weak self] result in
            guard let self = self else { return }
            self.didCardEncrypted(result, is3dsEnabled: self.defaults.booleanValue(for: Keys.threedsEnabled))
        }
    }

    func didCardEncrypted(_ result: Result<VerifoneFormResult, Error>, is3dsEnabled: Bool) {
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

                if is3dsEnabled && params.threedsContractID!.isEmpty {
                    self.alert(title: "Missing threeds contract id")
                    self.stopAnimation()
                    return
                }

                if is3dsEnabled {
                    handleCCPaymentWith3DS(result: verifoneResult, params: params)
                } else {
                    handleCCPaymentWithout3DS(result: verifoneResult, params: params)
                }
            case .giftCard:
                guard let params = Parameters.giftCard else {
                    self.alert(title: "\(missingParams) Gift card")
                    self.stopAnimation()
                    return
                }

                handleGiftCard(result: verifoneResult, params: params)
            case .paypal:
                //
                // Pay by link payment method selected.
                // Verify that the payment was redirected to the expected URL and make an authorization API call.
                // If the redirect URL is nil, make an API call to get the approval URL.
                //
                handlePaypalPaymentFlow(result: verifoneResult)
            case .applePay:
                handleApplePayPaymentFlow(result: verifoneResult)
            case .klarna:
                self.initiateKlarna()
            case .swish:
                self.initiateSwish()
            case .vipps:
                self.initiateVipps()
            case .mobilePay:
                self.initiateMobilePay()
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
}

extension ProductDetailsViewController {
    func stopAnimation() {
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? BuyButtonCell {
                cell.buyButton.isEnabled = true
                cell.activityIndicator.stopAnimating()
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
                cell.activityIndicator.startAnimating()
            }
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? BuyButtonCellWithSingleButton {
                cell.buyButton.isEnabled = true
                cell.activityIndicator.startAnimating()
            }
        }
    }

    // swiftlint: disable cyclomatic_complexity
    func configureCardFormColors() {
        if let color = getColor(key: "textfield_1000") {
            if #available(iOS 13.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    verifoneTheme.primaryBackgorundColor = UIColor.systemBackground
                } else {
                    verifoneTheme.primaryBackgorundColor = color
                }
            } else {
                verifoneTheme.primaryBackgorundColor = color
            }
        }
        if let color = getColor(key: "textfield_1001") {
            if #available(iOS 13.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    verifoneTheme.textfieldBackgroundColor = UIColor.systemBackground
                } else {
                    verifoneTheme.textfieldBackgroundColor = color
                }
            } else {
                verifoneTheme.textfieldBackgroundColor = color
            }
        }
        if let color = getColor(key: "textfield_1002") {
            if #available(iOS 13.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    verifoneTheme.textfieldTextColor = UIColor.label
                } else {
                    verifoneTheme.textfieldTextColor = color
                }
            } else {
                verifoneTheme.textfieldTextColor = color
            }
        }
        if let color = getColor(key: "textfield_1003") {
            if #available(iOS 13.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    verifoneTheme.labelColor = UIColor.label
                } else {
                    verifoneTheme.labelColor = color
                }
            } else {
                verifoneTheme.labelColor = color
            }
        }
        if let color = getColor(key: "textfield_1004") {
            if #available(iOS 13.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    verifoneTheme.payButtonBackgroundColor = UIColor(hex: "#0A69C7")
                } else {
                    verifoneTheme.payButtonBackgroundColor = color
                }
            } else {
                verifoneTheme.payButtonBackgroundColor = color
            }
        }
        if let color = getColor(key: "textfield_1005") {
            if #available(iOS 13.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    verifoneTheme.payButtonDisabledBackgroundColor = UIColor.secondaryLabel
                } else {
                    verifoneTheme.payButtonDisabledBackgroundColor = color
                }
            } else {
                verifoneTheme.payButtonDisabledBackgroundColor = color
            }
        }
        if let color = getColor(key: "textfield_1006") {
            if #available(iOS 13.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    verifoneTheme.payButtonTextColor = UIColor.white
                } else {
                    verifoneTheme.payButtonTextColor = color
                }
            } else {
                verifoneTheme.payButtonTextColor = color
            }
        }
        if let color = getColor(key: "textfield_1007") {
            if #available(iOS 13.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    verifoneTheme.cardTitleColor = UIColor.label
                } else {
                    verifoneTheme.cardTitleColor = color
                }
            } else {
                verifoneTheme.cardTitleColor = color
            }
        }
    }
    
    func getColor(key: String) -> UIColor? {
        if let value = defaults.string(forKey: key) {
            if let hex = Int(value, radix: 16) {
                return UIColor(hex)
            }
        }
        return nil
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
        request.setupKlarna(productPrice: product.getPrice(),
                            customer: params.customer!,
                            entityId: params.entityId!,
                            redirectUrl: params.redirectUrl)
        self.viewModel.initiateTransaction(params: params, request: request, wallet: "klarna") { [weak self] result, error in
            guard let self = self else { return }
            guard error == nil else {
                self.showErrorResultPage(title: "Error, initiate klarna", message: error)
                self.stopAnimation()
                return
            }
            DispatchQueue.main.async {
                if let clientToken = result!.clientToken, let customerId = result?.customer {
                    self.transactionId = result!.id
                    self.customer = customerId
                    self.klarnaVC = KlarnaVC(delegate: self, clientToken: clientToken, urlScheme: Keys.testAppScheme)
                    self.present(self.klarnaVC, animated: true)
                }
            }
        }
    }

    func completeKlarna(transactionId: String?, authToken: String?) {
        if transactionId == nil || authToken == nil {
            self.stopAnimation()
            return
        }
        let request = AuthToken(authorizationToken: authToken!, customer: customer!)
        requestInProgress = true
        self.viewModel.completeKlarna(transactionId: transactionId!, request: request) { [weak self] response, error in
            self?.stopAnimation()
            self?.requestInProgress = false
            guard error == nil else {
                self?.showErrorResultPage(title: "Error, complete klarna", message: error)
                return
            }

            self?.showResultPage(merchantReference: response?.merchantReference ?? "")
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
