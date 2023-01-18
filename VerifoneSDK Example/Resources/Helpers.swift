//
//  Helpers.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 23.11.2022.
//

import UIKit

struct PaymentAppParams {
    let host: String
    let url: String
    let callback: String
    let scheme: String
}

let SwishParams = PaymentAppParams(host: "paymentrequest",
                                   url: "swish://",
                                   callback: "verifonesdk://",
                                   scheme: "swish")
let VippsParams = PaymentAppParams(host: "",
                                   url: "vippsMT://",
                                   callback: "verifonesdk://",
                                   scheme: "vippsMT")
let MobilePayParams = PaymentAppParams(host: "online",
                                   url: "mobilepay-test://",
                                   callback: "verifonesdk://",
                                   scheme: "mobilepay-test")

func isAppInstalled(appName: String) -> Bool {
  guard let url = URL(string: appName) else {
    preconditionFailure("Invalid url")
  }

  return UIApplication.shared.canOpenURL(url)
}

func encodedCallbackUrl(callback: String) -> String? {
    let disallowedCharacters = NSCharacterSet(charactersIn: "!*'();:@&=+$,/?%#[]")
    let allowedCharacters = disallowedCharacters.inverted
    return callback.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
}

func openAppWithToken(_ appParams: PaymentAppParams, _ token: String) {
    var token: String = token
    var urlComponents = URLComponents()
    var queryItems: [URLQueryItem] = [URLQueryItem]()
    
    guard isAppInstalled(appName: appParams.url) else {
        preconditionFailure("\(appParams.url) app not found!")
    }

    guard let callback = encodedCallbackUrl(callback: appParams.callback) else {
        preconditionFailure("Callback url is required")
    }

    if let range = token.range(of: "token=") {
        token = String(token[range.upperBound...])
    }

    UserDefaults.standard.set(appParams.url, forKey: Keys.switchedApp)
    queryItems = [URLQueryItem(name: "token", value: token),
                  URLQueryItem(name: "callbackurl", value: callback),
                  URLQueryItem(name: "fallBack", value: callback)]

    if appParams.scheme == MobilePayParams.scheme {
        queryItems = [
            URLQueryItem(name: "paymentid", value: token),
            URLQueryItem(name: "redirect_url", value: callback)
        ]
    }

    urlComponents.host = appParams.host
    urlComponents.scheme = appParams.scheme
    urlComponents.queryItems = queryItems

    guard let url = urlComponents.url else {
        preconditionFailure("Invalid url")
    }
    
    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
        if !success {

        }
    })
}
