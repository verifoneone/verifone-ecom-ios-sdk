//
//  VF3DSecureWebViewModal.swift
//  VerifoneSDK
//

import WebKit

public final class VFWebConfig {
    let payload: String?
    let termUrl: String?
    let acsUrl: String?
    let mdValue: String?

    let url: URL?
    let expectedRedirectUrl: [URLComponents]?
    let expectedCancelUrl: [URLComponents]?

    var threedsRequest: URLRequest {
        var components = URLComponents(string: acsUrl!)!
        components.queryItems = [URLQueryItem(name: "PaReq", value: payload), URLQueryItem(name: "TermUrl", value: termUrl), URLQueryItem(name: "MD", value: mdValue)]

        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")

        let url = components.url!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "x-www-form-urlencoded"]
        return request
    }

    var authorizingPaymentRequest: URLRequest {
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "x-www-form-urlencoded"]
        return request
    }

    var webViewConfiguration: WKWebViewConfiguration {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        return configuration
    }

    public init(payload: String, termUrl: String, acsUrl: String, mdValue: String) {
        self.payload = payload
        self.termUrl = termUrl
        self.acsUrl = acsUrl
        self.mdValue = mdValue

        self.url = nil
        self.expectedRedirectUrl = nil
        self.expectedCancelUrl = nil
    }

    public init(url: URL, expectedRedirectUrl: [URLComponents], expectedCancelUrl: [URLComponents]) {
        self.url = url
        self.expectedRedirectUrl = expectedRedirectUrl
        self.expectedCancelUrl = expectedCancelUrl

        self.payload = nil
        self.termUrl = nil
        self.acsUrl = nil
        self.mdValue = nil
    }
}
