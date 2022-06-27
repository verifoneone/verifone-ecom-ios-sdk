//
//  ApplePayServiceProtocol.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 04.10.2021.
//

import PassKit
import Foundation

public typealias PaymentCallback = (_ payment: PKPayment?, _ error: Error?) -> Void

@objc public protocol ApplePayServiceProtocol: AnyObject {
    func isApplePaySupported() -> Bool

    func beginPayment(presentingController: UIViewController, completion: @escaping PaymentCallback)
}
