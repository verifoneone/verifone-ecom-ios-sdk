//
//  EncodableExtensions.swift
//  VerifoneTestPaymentApp
//
//  Created by Oraz Atakishiyev on 09.08.2021.
//

import Foundation

public protocol SdkObject: Encodable {}

extension Encodable {
    func toDict() -> [String: Any] {
        var dict = [String: Any]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            if let key = child.label {
                if let array = child.value as? [SdkObject] {
                    dict[key] = array.map({ $0.toDict() })
                } else if let objc = child.value as? SdkObject {
                    dict[key] = objc.toDict()
                } else {
                    dict[key] = child.value
                }
            }
        }
        
        return dict
    }
    
    func debugJsonPrint() -> String {
        let jsonEncoder = JSONEncoder()
        guard let jsonData = try? jsonEncoder.encode(self) else { return "" }
        
        return String(data: jsonData, encoding: String.Encoding.utf8) ?? ""
    }
}
