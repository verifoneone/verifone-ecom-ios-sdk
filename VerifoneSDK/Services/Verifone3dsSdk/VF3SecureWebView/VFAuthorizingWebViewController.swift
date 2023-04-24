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

public protocol AuthorizingPaymentWebViewControllerDelegate: AnyObject {
    func paymentAuhtorizingDidSelected(_ viewController: VFAuthorizingPaymentWebViewController, paymentMethod: VerifonePaymentMethodType)
    func authorizingPaymentViewController(_ viewController: VFAuthorizingPaymentWebViewController, didCompleteAuthorizing result: PaymentAuthorizingResult)

    func authorizingPaymentViewControllerDidCancel(_ viewController: VFAuthorizingPaymentWebViewController, callback: CallbackStatus)
}

public class VFAuthorizingPaymentWebViewController: UIViewController, PanModalPresentable, PaymentAuthorizingReloadDelegate {

    private var activityIndicatorView: UIActivityIndicatorView!
    private var titleCardForm: UILabel = UILabel(frame: .zero)
    private var closeButton: UIButton = UIButton(frame: .zero)
    private var edgeInsets = UIEdgeInsets(top: 0, left: 15.0, bottom: 0.0, right: 15.0)

    private var webView: WKWebView!
    private let hTopStackView = UIStackView()

    public var paymentMethod: VerifonePaymentMethodType!
    public var webConfig: VFWebConfig?
    public weak var delegate: AuthorizingPaymentWebViewControllerDelegate?

    var webViewConfiguration: WKWebViewConfiguration {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        return configuration
    }

    func reloadWebview(webConfig: VFWebConfig) {
        self.webConfig = webConfig
        guard let url = webConfig.url, !webConfig.expectedRedirectUrl!.isEmpty else {
            assertionFailure("Provide all required payment information")
            debugPrint("Missing authorizing payment information")
            return
        }

        debugPrint("Initializing auth payment proccess \(url.absoluteString)")
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
        self.view.backgroundColor = UIColor.VF.defaultBackground
        webView.backgroundColor = UIColor.VF.defaultBackground
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.uiDelegate = self
        webView.navigationDelegate = self
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
        delegate?.authorizingPaymentViewControllerDidCancel(self, callback: .cancel)
        self.dismiss(animated: true, completion: nil)
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
            dismiss(animated: true)
        }
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if let url = navigationAction.request.url, validatePaymentURL(url, expectedRedirectURL: webConfig!.expectedRedirectUrl!) {
            debugPrint("Redirected to expected \(url.absoluteString)")
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
            debugPrint("Redirected to cancel \(url.absoluteString)")
            cancel()
            decisionHandler(.cancel)
        } else {
            debugPrint("Redirected to non expected \(navigationAction.request.url?.absoluteString ?? "")")
            decisionHandler(.allow)
        }
    }
}

extension VFAuthorizingPaymentWebViewController {
    func createViews() {
        view.addSubview(activityIndicatorView)

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        closeButton.tintColor = UIColor.VF.label
        closeButton.setImage(UIImage(named: "Close", in: .module, compatibleWith: nil), for: .normal)
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
        NSLayoutConstraint.activate([
            hTopStackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10.0),
            hTopStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0),
            hTopStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
            hTopStackView.heightAnchor.constraint(equalToConstant: 35.0)
        ])

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: hTopStackView.bottomAnchor, constant: 0.0),
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),

            activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0.0),
            activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0.0)
        ])
    }
}
