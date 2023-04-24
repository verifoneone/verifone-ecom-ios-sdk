//
//  ResponseError.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 10.04.2023.
//

import Foundation

// MARK: - OrderResponse
struct OrderResponseError: Codable {
    let code: Int
    let details: Details
    let timestamp: Int
    let message: String
}

// MARK: - Details
struct Details: Codable {
    let error, serviceCode, cause: String?
}
