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
    func didReceiveFinilizeToken(authToken: String?)
}

class KlarnaVC: UIViewController, PanModalPresentable {
    private(set) var paymentView: KlarnaPaymentView?
    private var authorizationToken: String?
    private var clientToken: String?
    private var categories = [String]()
    
    public var delegate: KlarnaVCDelegate?
    
    var activityIndicator: UIActivityIndicatorView! = UIActivityIndicatorView(style: .gray)
    
    init(clientToken: String) {
        self.clientToken = clientToken
        KlarnaMobileSDKCommon.setLoggingLevel(.off)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboard are a pain")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                fatalError("`self` does not exist!")
            }
            if let clientToken = self.clientToken {
                self.paymentView = KlarnaPaymentView(category: "pay_now", eventListener: self)
                self.paymentView!.initialize(clientToken: clientToken, returnUrl: URL(string:"verifonesdk://")!)
            }
        }
    }
    
    override func loadView() {
        view  = UIView()
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
            }
            else {
                print("ViewController displayPaymentView: Payment view does not exist!")
            }
        }
    }
    
    public var panScrollable: UIScrollView? {
        return nil
    }
    
    public var longFormHeight: PanModalHeight {
        return .maxHeight
    }
    
    public var anchorModalToLongForm: Bool {
        return true
    }
    
    public var shouldRoundTopCorners: Bool {
        return true
    }
    
    func panModalDidDismiss() {
        self.delegate?.didReceiveFinilizeToken(authToken: self.authorizationToken)
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
        print("loaded")
        self.paymentView?.authorize()
    }
    
    func klarnaLoadedPaymentReview(paymentView: KlarnaPaymentView) {
        print("klarnaLoadedPaymentReview")
    }
    
    func klarnaAuthorized(paymentView: KlarnaPaymentView, approved: Bool, authToken: String?, finalizeRequired: Bool) {
        self.authorizationToken = authToken
        self.removePaymentView()
        self.dismiss(animated: true, completion: {
            self.delegate?.didReceiveFinilizeToken(authToken: self.authorizationToken)
        })
    }
    
    func klarnaReauthorized(paymentView: KlarnaPaymentView, approved: Bool, authToken: String?) {
    }
    
    func klarnaFinalized(paymentView: KlarnaPaymentView, approved: Bool, authToken: String?) {
    }
    
    func klarnaResized(paymentView: KlarnaPaymentView, to newHeight: CGFloat) {
        print("KlarnaPaymentViewDelegate paymentView resizedToHeight: \(newHeight)")
    }
    
    func klarnaFailed(inPaymentView paymentView: KlarnaPaymentView, withError error: KlarnaPaymentError) {
        print("KlarnaPaymentViewDelegate paymentView failedWithError: \(error.debugDescription)")
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
