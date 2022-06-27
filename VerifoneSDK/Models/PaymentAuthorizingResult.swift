//
//  PaymentAuthorizingResult.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 21.02.2022.
//

import Foundation
import PassKit

@objc(VFPaymentAuthorizingResult)
public class PaymentAuthorizingResult: NSObject {
    @objc public let queryStringDictionary: NSMutableDictionary?
    @objc public let redirectedUrl: URL
    
    public init(redirectedUrl: URL, queryStringDictionary: NSMutableDictionary?) {
        self.redirectedUrl = redirectedUrl
        self.queryStringDictionary = queryStringDictionary
    }
}
