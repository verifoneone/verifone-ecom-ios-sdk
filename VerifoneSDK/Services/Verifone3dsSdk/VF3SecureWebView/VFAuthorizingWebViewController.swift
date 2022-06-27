//
//  VF3DSecureWebViewController.swift
//  VerifoneSDK
//

import UIKit
import WebKit

protocol PaymentAuthorizingReloadDelegate: AnyObject {
    func reloadWebview(webConfig: VFWebConfig)
    func cancelByLink(completion: @escaping (() -> Void))
}

public struct PaymentAuthorizingWithURL {
    weak var reloadDelegate: PaymentAuthorizingReloadDelegate?
    public static var shared = PaymentAuthorizingWithURL()

    public func load(webConfig: VFWebConfig) {
        DispatchQueue.main.async {
            self.reloadDelegate?.reloadWebview(webConfig: webConfig)
        }
    }
    
    public func cancelPayByLink(completion: @escaping (() -> Void)) {
        DispatchQueue.main.async {
            self.reloadDelegate?.cancelByLink(completion: completion)
        }
    }
}

@objc(VFAuthorizingPaymentWebViewControllerDelegate)
public protocol AuthorizingPaymentWebViewControllerDelegate: AnyObject {
    func paymentAuhtorizingDidSelected(_ viewController: VFAuthorizingPaymentWebViewController, paymentMethod: PaymentMethodType)
    func authorizingPaymentViewController(_ viewController: VFAuthorizingPaymentWebViewController, didCompleteAuthorizing result: PaymentAuthorizingResult)
    
    func authorizingPaymentViewControllerDidCancel(_ viewController: VFAuthorizingPaymentWebViewController, callback: CallbackStatus)
}

@objc(VFAuthorizingPaymentViewController)
public class VFAuthorizingPaymentWebViewController: UIViewController, PanModalPresentable, PaymentAuthorizingReloadDelegate {
    
    private var activityIndicatorView: UIActivityIndicatorView!
    private var titleCardForm: UILabel = UILabel(frame: .zero)
    private var closeButton: UIButton = UIButton(frame: .zero)
    private var edgeInsets = UIEdgeInsets(top: 0, left: 15.0, bottom: 0.0, right: 15.0)
    
    private var webView: WKWebView!
    private let hTopStackView = UIStackView()
    
    public var paymentMethod: PaymentMethodType!
    public var webConfig: VFWebConfig?
    public weak var delegate: AuthorizingPaymentWebViewControllerDelegate?
    
    var didFailed: (() -> Void)?
    var didValidated: ((String) -> Void)?
    var payload: String?
    
    func reloadWebview(webConfig: VFWebConfig) {
        self.webConfig = webConfig
        guard let url = webConfig.url, !webConfig.expectedRedirectUrl!.isEmpty else {
            assertionFailure("Provide all required payment information")
            AppLog.log("Missing authorizing payment information", log: uiLogObject, type: .error)
            return
        }
 
        AppLog.log("Initializing auth payment proccess %{private}@", log: uiLogObject, type: .info, url.absoluteString)
        webView.load(webConfig.authorizingPaymentRequest)
    }
    
    func cancelByLink(completion: @escaping (() -> Void)) {
        delegate?.authorizingPaymentViewControllerDidCancel(self, callback: .cancel)
        dismiss(animated: true, completion: completion)
    }
    
    private func initWebView() {
        self.activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        self.webView = WKWebView(frame: self.view.bounds, configuration: webViewConfiguration)
        view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.uiDelegate = self
        webView.navigationDelegate = self
    }
    
    @objc(authorizingPaymentViewControllerWithAuthorizedURL:expectedReturnURL:expectedReturnURL:delegate:)
    public static func createAuthorizingPaymentViewControllerWithAuthorizedURL(_ authorizedURL: URL, expectedReturnURL: [URLComponents], expectedCancelURL: [URLComponents], delegate: AuthorizingPaymentWebViewControllerDelegate) -> VFAuthorizingPaymentWebViewController {
        let webConfig: VFWebConfig = VFWebConfig(url: authorizedURL, expectedRedirectUrl: expectedReturnURL, expectedCancelUrl: expectedCancelURL)
        let viewController = VFAuthorizingPaymentWebViewController()
        viewController.webConfig = webConfig
        viewController.delegate = delegate
        
        return viewController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        PaymentAuthorizingWithURL.shared.reloadDelegate = self
        initWebView()
        delegate?.paymentAuhtorizingDidSelected(self, paymentMethod: paymentMethod)
        setEventHandlers()
        createViews()
        activityIndicatorView.startAnimating()
    }
    
    private func setEventHandlers() {
        closeButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
    }
    
    @objc private func cancel() {
//        dismiss(animated: true) {
//            self.didFailed?()
//        }
        
        delegate?.authorizingPaymentViewControllerDidCancel(self, callback: .cancel)
        self.dismiss(animated: true, completion: nil)
    }
    
    public func onCompletion(didValidated: @escaping ((String) -> Void), didFailed: @escaping (() -> Void)) {
        self.didValidated = didValidated
        self.didFailed = didFailed
    }
    var webViewConfiguration: WKWebViewConfiguration {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        return configuration
    }
    
    private func validatePaymentURL(_ url: URL, expectedRedirectURL: [URLComponents]) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }

        return expectedRedirectURL.contains { redirectURLComponents -> Bool in
            return redirectURLComponents.scheme == components.scheme
                && redirectURLComponents.host == components.host
                && components.path.hasPrefix(redirectURLComponents.path)
        }
    }
    
    public var panScrollable: UIScrollView? {
        return webView.scrollView
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
    
    public func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        true
    }
    
    public var allowsExtendedPanScrolling: Bool {
        return true
    }
}

extension VFAuthorizingPaymentWebViewController: WKNavigationDelegate, WKUIDelegate {
    public func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        self.activityIndicatorView.stopAnimating()
        if !webView.hasOnlySecureContent {
            dismiss(animated: true) {
                self.didFailed?()
            }
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if let url = navigationAction.request.url, validatePaymentURL(url, expectedRedirectURL: webConfig!.expectedRedirectUrl!) {
            AppLog.log("Redirected to expected %{private}@ url", log: uiLogObject, type: .info, url.absoluteString)
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            
            let dict: NSMutableDictionary = [:]
            for keyVal in components!.queryItems! {
                let name = keyVal.name
                let val = keyVal.value
                dict.setValue(val, forKey: name)
            }
            
            let result = PaymentAuthorizingResult(redirectedUrl: url, queryStringDictionary: dict)
            delegate?.authorizingPaymentViewController(self, didCompleteAuthorizing: result)
            decisionHandler(.cancel)
        } else if let url = navigationAction.request.url, validatePaymentURL(url, expectedRedirectURL: webConfig!.expectedCancelUrl!) {
            AppLog.log("Redirected to cancel %{private}@ url", log: uiLogObject, type: .debug, url.absoluteString)
            cancel()
            decisionHandler(.cancel)
        } else {
            AppLog.log("Redirected to non expected %{private}@ url", log: uiLogObject, type: .debug, navigationAction.request.url?.absoluteString ?? "no url")
            decisionHandler(.allow)
        }
    }
}

extension VFAuthorizingPaymentWebViewController {
    func createViews() {
        view.addSubview(activityIndicatorView)
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        closeButton.tintColor = UIColor.VF.label
        closeButton.setImage(UIImage(named: "Close", in:.module, compatibleWith: nil), for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        // HTOPStack View for title and close button
        hTopStackView.backgroundColor = .white
        hTopStackView.axis  = NSLayoutConstraint.Axis.horizontal
        hTopStackView.distribution  = UIStackView.Distribution.equalSpacing
        hTopStackView.alignment = UIStackView.Alignment.center
        hTopStackView.layoutMargins = UIEdgeInsets(top: 0, left: edgeInsets.left, bottom: 0, right: 10.0)
        hTopStackView.isLayoutMarginsRelativeArrangement = true
        
        hTopStackView.addArrangedSubview(titleCardForm)
        hTopStackView.addArrangedSubview(closeButton)
        hTopStackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(hTopStackView)
        
        // constraints for top stack view
        self.view.addConstraints([
            NSLayoutConstraint(item: hTopStackView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: hTopStackView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: hTopStackView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant:  0.0),
            NSLayoutConstraint(item: hTopStackView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 35),
            NSLayoutConstraint(item: hTopStackView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.0, constant: self.view.frame.width)
        ])
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: webView!, attribute: .top, relatedBy: .equal, toItem: hTopStackView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
        ])
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: activityIndicatorView!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: activityIndicatorView!, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ])
    }
}
