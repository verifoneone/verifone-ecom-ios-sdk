//
//  Environment.swift
//  VerifoneTestPaymentApp
//
//  Created by Oraz Atakishiyev on 09.08.2021.
//

import Foundation

@objc public enum Environment: Int {
    case staging
    case production
}

extension Environment: Codable {
    public init(from decor: Decoder) throws {
        self = try Environment(rawValue: decor.singleValueContainer().decode(RawValue.self)) ?? .production
    }
}
