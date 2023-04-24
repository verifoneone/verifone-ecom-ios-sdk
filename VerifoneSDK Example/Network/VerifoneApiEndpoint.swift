//
//  VerifoneApiEndpoint.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 21.03.2023.
//

import Foundation

enum VerifoneApiEndPoint {
    case getJWT(headers: RequestHeaders, paramters: RequestParameters)
    case lookup(headers: RequestHeaders, paramters: RequestParameters)
    case validate(headers: RequestHeaders, paramters: RequestParameters)
    case transaction(headers: RequestHeaders, paramters: RequestParameters)
    case initiateTransaction(headers: RequestHeaders, paramters: RequestParameters)
    case initiateWalletTransaction(headers: RequestHeaders, paramters: RequestParameters, wallet: String)
    case checkTransaction(headers: RequestHeaders, paramters: RequestParameters, transactionID: String)
    case completeKlarna(headers: RequestHeaders, paramters: RequestParameters, transactionID: String)
    case createReuseToken(headers: RequestHeaders, paramters: RequestParameters)
    case initiatePaypal(headers: RequestHeaders, paramters: RequestParameters)
    case authorizePaypal(headers: RequestHeaders, paramters: RequestParameters, transactionID: String)
}

extension VerifoneApiEndPoint: ApiEndPoint {
    var headers: RequestHeaders {
        switch self {
        case .getJWT(let headers, _), .lookup(let headers, _),
                .validate(let headers, _), .transaction(let headers, _),
                .initiateTransaction(let headers, _),
                .initiateWalletTransaction(let headers, _, _),
                .checkTransaction(let headers, _, _),
                .completeKlarna(let headers, _, _),
                .createReuseToken(let headers, _),
                .initiatePaypal(let headers, _),
                .authorizePaypal(let headers, _, _):
            return headers
        }
    }

    var path: String {
        switch self {
        case .getJWT:
            return "/oidc/3ds-service/v2/jwt/create"
        case .lookup:
            return "/oidc/3ds-service/v2/lookup"
        case .validate:
            return "/oidc/3ds-service/v2/jwt/validate"
        case .transaction:
            return "/oidc/api/v2/transactions/card"
        case .initiateTransaction:
            return "/oidc/api/v2/transactions"
        case .initiateWalletTransaction(_, _, let wallet):
            return "/oidc/api/v2/transactions/\(wallet)"
        case .checkTransaction(_, _, let transactionID):
            return "/oidc/api/v2/transaction/\(transactionID)"
        case .completeKlarna(_, _, let transactionID):
            return "/oidc/api/v2/transactions/\(transactionID)/klarna_complete"
        case .createReuseToken:
            return "/oidc/api/v2/card"
        case .initiatePaypal:
            return "/oidc/paypal-ecom/transactions"
        case .authorizePaypal(_, _, let transactionID):
            return "/oidc/paypal-ecom/transactions/\(transactionID)/authorize"
        }
    }

    var method: RequestMethod {
        switch self {
        case .getJWT, .lookup, .validate, .transaction, .initiateTransaction, .initiateWalletTransaction,
             .completeKlarna, .initiatePaypal, .authorizePaypal:
            return .post
        case .checkTransaction:
            return .get
        case .createReuseToken:
            return .put
        }
    }

    var parameters: RequestParameters? {
        switch self {
        case .getJWT(_, let parameters), .lookup(_, let parameters),
                .validate(_, let parameters), .transaction(_, let parameters),
                .initiateTransaction(_, let parameters),
                .initiateWalletTransaction(_, let parameters, _),
                .checkTransaction(_, let parameters, _),
                .completeKlarna(_, let parameters, _),
                .createReuseToken(_, let parameters),
                .initiatePaypal(_, let parameters),
                .authorizePaypal(_, let parameters, _):
            return parameters
        }
    }
}
