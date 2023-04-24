//
//  PaymentChooserViewController.swift
//  Verifone
//
//  Created by Oraz Atakishiyev on 20.08.2021.
//

import UIKit
import PassKit

public class PaymentMethodsViewController: UITableViewController, PanModalPresentable {

    var paymentFlowSession: PaymentFlowSession!
    var creditCardForm: CreditCardViewController?
    var applePayService: ApplePayService?
    var allowedPaymentMethods: [VerifonePaymentMethodType] = []
    let headerView = PaymentTypeHeaderView()
    var headerPresentable: PaymentTypeHeaderPresentable!

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
            if self.tableView.adjustedContentInset.bottom > 0 {
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
        tableView.backgroundColor = UIColor.VF.defaultBackground
        self.view.backgroundColor = UIColor.VF.defaultBackground
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
            cell.cardBrandImageView.image = UIImage(named: VerifonePaymentMethodType.creditCard.rawValue, in: .module, compatibleWith: nil)!
            cell.nameLabel.text = "paymentProductCard".localized()
        case .paypal:
            cell.cardBrandImageView.image = UIImage(named: VerifonePaymentMethodType.paypal.rawValue, in: .module, compatibleWith: nil)!
            cell.nameLabel.text = "paymentProductPaypal".localized()
        case .applePay:
            cell.cardBrandImageView.image = UIImage(named: VerifonePaymentMethodType.applePay.rawValue, in: .module, compatibleWith: nil)!
            cell.nameLabel.text = "paymentProductApplePay".localized()
        case .klarna:
            cell.cardBrandImageView.image = UIImage(named: VerifonePaymentMethodType.klarna.rawValue, in: .module, compatibleWith: nil)!
            cell.nameLabel.text = "paymentProductKlarna".localized()
        case .swish:
            cell.cardBrandImageView.image = UIImage(named: VerifonePaymentMethodType.swish.rawValue, in: .module, compatibleWith: nil)!
            cell.nameLabel.text = "paymentProductSwish".localized()
        case .vipps:
            cell.cardBrandImageView.image = UIImage(named: VerifonePaymentMethodType.vipps.rawValue, in: .module, compatibleWith: nil)!
            cell.nameLabel.text = "paymentProductVipps".localized()
        case .mobilePay:
            cell.cardBrandImageView.image = UIImage(named: VerifonePaymentMethodType.mobilePay.rawValue, in: .module, compatibleWith: nil)!
            cell.nameLabel.text = "paymentProductMobilePay".localized()
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
            if !self.paymentFlowSession.paymentConfiguration!.reuseTokenForCardPayment {
                creditCardForm = CreditCardViewController(paymentConfiguration: paymentFlowSession!.paymentConfiguration!, theme: paymentFlowSession!.verifoneTheme)
                creditCardForm!.delegate = paymentFlowSession
                present(creditCardForm!, animated: true)
            } else {
                self.paymentFlowSession.delegate?.paymentAuthorizingDidSelected(self, paymentMethod: allowedPaymentMethods[indexPath.row])
            }
        case .paypal:
            let webview = VFAuthorizingPaymentWebViewController()
            webview.paymentMethod = allowedPaymentMethods[indexPath.row]
            webview.delegate = paymentFlowSession
            presentPanModal(webview)
        case .klarna, .swish, .vipps, .mobilePay:
            self.paymentFlowSession.delegate?.paymentAuthorizingDidSelected(self, paymentMethod: allowedPaymentMethods[indexPath.row])
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
        var height: CGFloat = 300.0
        let paymentMethodHeight: CGFloat = 40.0
        if allowedPaymentMethods.count > 4 {
            height += CGFloat(allowedPaymentMethods.count - 4) * paymentMethodHeight
        }
        return .contentHeight(height)
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
