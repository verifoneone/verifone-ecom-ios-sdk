//
//  CallbackStatus.swift
//  VerifoneTestPaymentApp
//
//  Created by Oraz Atakishiyev on 09.08.2021.
//

import Foundation

public enum CallbackStatus: Int, CustomStringConvertible, Codable {
    case success
    case cancel

    public var description: String {
        switch self {
        case .cancel:
            return "cancel"
        case .success:
            return "success"
        }
    }
}
