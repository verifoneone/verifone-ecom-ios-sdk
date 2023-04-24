//
//  VF3DSecureWebViewModal.swift
//  VerifoneSDK
//

import WebKit

public class VFWebConfig {

    let url: URL?
    let expectedRedirectUrl: [URLComponents]?
    let expectedCancelUrl: [URLComponents]?

    var authorizingPaymentRequest: URLRequest {
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [HTTPHeaderField.contentType: HTTPHeaderField.formURLEncoded]
        return request
    }

    public init(url: URL, expectedRedirectUrl: [URLComponents], expectedCancelUrl: [URLComponents]) {
        self.url = url
        self.expectedRedirectUrl = expectedRedirectUrl
        self.expectedCancelUrl = expectedCancelUrl
    }
}
