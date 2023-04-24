//
//  KlarnaVC.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 26.04.2022.
//

import UIKit
import VerifoneSDK
import KlarnaMobileSDK

protocol KlarnaVCDelegate: AnyObject {
    func didReceiveFinilizeToken(authorizationToken: String?, error: String?)
}

class KlarnaVC: UIViewController {
    private var paymentView: KlarnaPaymentView!
    private var delegate: KlarnaVCDelegate?
    private var authorizationToken: String?
    private var clientToken: String
    private var urlScheme: String?
    private var activityIndicator: UIActivityIndicatorView! = UIActivityIndicatorView(style: .gray)

    public init(delegate: KlarnaVCDelegate?, clientToken: String, urlScheme: String?) {
        self.delegate = delegate
        self.clientToken = clientToken
        self.urlScheme = urlScheme
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                fatalError("`self` does not exist!")
            }

            self.paymentView = KlarnaPaymentView(category: "pay_now", eventListener: self)
            if let urlScheme = self.urlScheme, let url = URL(string: urlScheme) {
                self.paymentView.initialize(clientToken: self.clientToken, returnUrl: url)
            } else {
                self.paymentView.initialize(clientToken: self.clientToken)
            }
        }
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    func displayPaymentView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                fatalError("`self` does not exist!")
            }

            self.activityIndicator.stopAnimating()
            if let paymentView = self.paymentView {
                self.embed(subview: paymentView)
            } else {
                print("ViewController displayPaymentView: Payment view does not exist!")
            }
        }
    }
}

extension KlarnaVC: KlarnaPaymentEventListener {
    func removePaymentView() {
        if let paymentView = paymentView {
            paymentView.removeFromSuperview()
        }
    }

    func klarnaInitialized(paymentView: KlarnaPaymentView) {
        self.displayPaymentView()
        paymentView.load()
    }

    func klarnaLoaded(paymentView: KlarnaPaymentView) {
        paymentView.authorize(autoFinalize: true, jsonData: nil)
    }

    func klarnaLoadedPaymentReview(paymentView: KlarnaPaymentView) { }

    func klarnaAuthorized(paymentView: KlarnaPaymentView, approved: Bool, authToken: String?, finalizeRequired: Bool) {
        if let authToken = authToken {
            self.authorizationToken = authToken
            delegate?.didReceiveFinilizeToken(authorizationToken: authToken, error: nil)
        } else {
            if finalizeRequired {
                paymentView.finalise()
            } else {
                delegate?.didReceiveFinilizeToken(authorizationToken: nil, error: nil)
            }
        }
    }

    func klarnaReauthorized(paymentView: KlarnaPaymentView, approved: Bool, authToken: String?) {
        if let authToken = authToken {
            delegate?.didReceiveFinilizeToken(authorizationToken: authToken, error: nil)
        } else {
            delegate?.didReceiveFinilizeToken(authorizationToken: nil, error: nil)
        }
    }

    func klarnaResized(paymentView: KlarnaPaymentView, to newHeight: CGFloat) { }

    func klarnaFinalized(paymentView: KlarnaPaymentView, approved: Bool, authToken: String?) {
        if let authToken = authToken {
            delegate?.didReceiveFinilizeToken(authorizationToken: authToken, error: nil)
        } else {
            delegate?.didReceiveFinilizeToken(authorizationToken: nil, error: nil)
        }
    }

    func klarnaFailed(inPaymentView paymentView: KlarnaPaymentView, withError error: KlarnaPaymentError) {
        delegate?.didReceiveFinilizeToken(authorizationToken: nil, error: error.description)
    }
}

extension UIViewController {
    func embed(subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(subview)
        self.view.sendSubviewToBack(subview)

        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            subview.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15),
            subview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            subview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 15)
        ])
    }
}
