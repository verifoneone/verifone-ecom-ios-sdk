//
//  PaymentChooserViewController.swift
//  Verifone
//
//  Created by Oraz Atakishiyev on 20.08.2021.
//

import UIKit
import PassKit

@objc(VFPaymentMethod)
public enum PaymentMethod: Int, CustomStringConvertible, Codable {
    
    case creditCard
    case paypal
    case applePay
    case klarna
    
    public var description: String {
        switch self {
        case .creditCard:
            return "Card"
        case .paypal:
            return "Paypal"
        case .applePay:
            return "ApplePay"
        case .klarna:
            return "Klarna"
        }
    }
}

@objc(VFPaymentMethodsViewController)
public class PaymentMethodsViewController: UITableViewController, PanModalPresentable {
    
    var paymentFlowSession: PaymentFlowSession!
    var creditCardForm: CreditCardViewController?
    var applePayService: ApplePayService?
    @objc var allowedPaymentMethods: [VerifoneSDKPaymentTypeValue] = []
    
    let headerView = PaymentTypeHeaderView()
    
    var headerPresentable: PaymentTypeHeaderPresentable!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        headerPresentable = PaymentTypeHeaderPresentable.init(title: self.paymentFlowSession.paymentConfiguration!.paymentPanelStoreTitle)
        setupTableView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public func panModalDidDismiss() {
        paymentFlowSession!.delegate?.paymentFlowSessionDidCancel(self)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if #available(iOS 11, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
            if (self.tableView.adjustedContentInset.bottom > 0) {
                self.tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
            }
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    // MARK: - View Configurations
    
    func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.register(PaymentTypeCell.self, forCellReuseIdentifier: "cell")
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderToFit()
    }
    
    private func sizeHeaderToFit() {
        if let headerView = tableView.tableHeaderView {
            
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var newFrame = headerView.frame
            
            // Needed or we will stay in viewDidLayoutSubviews() forever
            if height != newFrame.size.height {
                newFrame.size.height = height
                headerView.frame = newFrame
                
                tableView.tableHeaderView = headerView
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allowedPaymentMethods.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PaymentTypeCell
        else { return UITableViewCell() }
        
        switch allowedPaymentMethods[indexPath.row] {
        case .creditCard:
            cell.cardBrandImageView.image = UIImage(named: PaymentMethod.creditCard.description, in: .module, compatibleWith: nil)!
            cell.nameLabel.text = "paymentProductCard".localized()
        case .paypal:
            cell.cardBrandImageView.image = UIImage(named: PaymentMethod.paypal.description, in: .module, compatibleWith: nil)!
            cell.nameLabel.text = "paymentProductPaypal".localized()
        case .applePay:
            cell.cardBrandImageView.image = UIImage(named: PaymentMethod.applePay.description, in: .module, compatibleWith: nil)!
            cell.nameLabel.text = "paymentProductApplePay".localized()
        case .klarna:
            cell.cardBrandImageView.image = UIImage(named: PaymentMethod.klarna.description, in: .module, compatibleWith: nil)!
            cell.nameLabel.text = "paymentProductKlarna".localized()
        default: break
        }
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    // MARK: - UITableViewDelegate
    
    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView.configure(with: headerPresentable)
        headerView.closeButton.addTarget(self, action: #selector(closeForm(sender:)), for: .touchUpInside)
        return headerView
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch allowedPaymentMethods[indexPath.row] {
        case .creditCard:
            creditCardForm = CreditCardViewController(paymentConfiguration: paymentFlowSession!.paymentConfiguration!, theme: paymentFlowSession!.verifoneTheme)
            creditCardForm!.delegate = paymentFlowSession
            present(creditCardForm!, animated: true)
        case .paypal:
            let webview = VFAuthorizingPaymentWebViewController()
            webview.paymentMethod = .paypal
            webview.delegate = paymentFlowSession
            presentPanModal(webview)
        case .klarna:
            self.paymentFlowSession.delegate?.paymentAuthorizingDidSelected(self, paymentMethod: .klarna)
        case .applePay:
            applePayService = ApplePayService(applePayMerchantConfiguration: paymentFlowSession.applepayConfiguration)
            applePayService?.beginPayment(presentingController: self, completion: { [weak self] result in
                switch result {
                case .success(let payment):
                    self?.paymentFlowSession.delegate?.didReceiveResultFromAppleService(self!, result: payment)
                case .failure(let error):
                    self?.paymentFlowSession.delegate?.paymentFlowSessionCancelWithError(self!, error: error)
                }
            })
        default:
            break
        }
    }
    
    @objc func closeForm(sender: UIButton) {
        self.close()
    }
    
    private func close() {
        paymentFlowSession!.delegate?.paymentFlowSessionDidCancel(self, callBack: .cancel)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Pan Modal Presentable
    
    public var panScrollable: UIScrollView? {
        return nil
    }
    
    public var longFormHeight: PanModalHeight {
        return .contentHeight(300)
    }
    
    public var anchorModalToLongForm: Bool {
        return false
    }
    
    public var shouldRoundTopCorners: Bool {
        return true
    }
    
    public func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        true
    }
    
    public var allowsDragToDismiss: Bool {
        return false
    }
    
    public var allowsTapToDismiss: Bool {
        return false
    }
}
