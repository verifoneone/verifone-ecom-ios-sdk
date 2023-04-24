//
//  ProductDetailViewModel.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 21.03.2023.
//

import Foundation

struct ProductDetailsViewModel {
    let clientAPI: ProductsAPI = ProductsAPI.shared

    func getHeaders(params: Parameters) -> RequestHeaders {
        var loginString: String!
        if let userKey = params.apiKey, let userID = params.apiUserID {
            loginString = String(format: "%@:%@", userID, userKey)
        } else {
            if MerchantAppConfig.shared.basicAuthUserId == nil || MerchantAppConfig.shared.basicAuthUserKey == nil {
                fatalError("Missing required parameters for credit card at least UserId and UserKey")
            }
            loginString = String(format: "%@:%@", MerchantAppConfig.shared.basicAuthUserId!, MerchantAppConfig.shared.basicAuthUserKey!)
        }
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()

        return [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": "Basic \(base64LoginString)",
            "x-vfi-api-idempotencyKey": UUID().uuidString
        ]
    }

    func getJWT(orderData: OrderData, completion: @escaping (ResponseJwt?, Error?) -> Void) {
        let request = RequestJwt(threedsContractId: orderData.threedsContractId)
        self.clientAPI.makeRequest(route: VerifoneApiEndPoint.getJWT(headers: getHeaders(params: .creditCard!), paramters: request.toDictConvertSnake())) { response, error in
            completion(response, error)
        }
    }

    func lookup(orderData: OrderData, completion: @escaping (ResponseLookup?, Error?) -> Void) {
        self.clientAPI.makeRequest(route: VerifoneApiEndPoint.lookup(headers: getHeaders(params: .creditCard!), paramters: orderData.toDictConvertSnake())) { response, error in
            completion(response, error)
        }
    }

    func validate(orderData: OrderData, responseLookup: ResponseLookup, serverJwt: String, completion: @escaping (ValidateResponse?, Error?) -> Void) {
        let request = RequestValidate(
            authenticationId: responseLookup.authenticationID!,
            jwt: serverJwt,
            threedsContractId: orderData.threedsContractId)
        self.clientAPI.makeRequest(route: VerifoneApiEndPoint.validate(headers: getHeaders(params: .creditCard!), paramters: request.toDictConvertSnake())) { response, error in
            completion(response, error)
        }
    }

    func validateResponse(price: Int, cardBrand: String?, validateResponse: ValidateResponse, lookupResponse: ResponseLookup, cardData: String? = nil, reuseToken: String? = nil,completion: @escaping (TransactionResponse?, Error?) -> Void) {
        let additionalData = AdditionalData(deviceChannel: "SDK",
                                            acsUrl: lookupResponse.acsURL ?? "")
        let threedAuthentication = ThreedAuthentication(validationResponse: validateResponse, dsTransactionID: lookupResponse.dsTransactionID, additionalData: additionalData)
        var request = RequestTransaction.creditCard
        let params = Parameters.creditCard!
        request.setupCreditCardWith3ds(productPrice: price,
                                       cardBrand: cardBrand, encryptedCard: cardData!,
                                       paymentProviderContract: params.paymentProviderContract!,
                                       publicKeyAlias: params.publicKeyAlias!,
                                       threedAuthentication: threedAuthentication)
        self.transaction(params: params, orderData: request) { res, err in
            completion(res, err)
        }
    }

    func transaction(params: Parameters, orderData: RequestTransaction, completion: @escaping (TransactionResponse?, Error?) -> Void) {
        self.clientAPI.makeRequest(route: VerifoneApiEndPoint.transaction(headers: getHeaders(params: params), paramters: orderData.toDictConvertSnake())) { response, error in
            completion(response, error)
        }
    }

    // Reuse token
    func createReuseToken(params: Parameters, tokenScope: String, encryptedCard: String, completion: @escaping (ResponseReuseToken?, Error?) -> Void) {
        let now = Date()
        let calendar = Calendar.current
        let nDate = calendar.date(byAdding: .month, value: 12, to: now)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let request = RequestReuseToken(tokenScope: tokenScope,
                                        encryptedCard: encryptedCard,
                                        publicKeyAlias: Parameters.creditCard!.publicKeyAlias!,
                                        tokenType: "REUSE",
                                        tokenExpiryDate: dateFormatter.string(from: nDate))
        self.clientAPI.makeRequest(route: VerifoneApiEndPoint.createReuseToken(headers: getHeaders(params: params), paramters: request.toDictConvertSnake())) { response, error in
            completion(response, error)
        }
    }

    func completeKlarna(transactionId: String, request: AuthToken, completion: @escaping (TransactionResponse?, Error?) -> Void) {
        self.clientAPI.makeRequest(route: VerifoneApiEndPoint.completeKlarna(headers: getHeaders(params: .klarna!),
                                                      paramters: request.toDictConvertSnake(),
                                                      transactionID: transactionId)) { response, error in
            completion(response, error)
        }
    }

    func initiateTransaction(params: Parameters, request: RequestTransaction, wallet: String?=nil, completion: @escaping (TransactionResponse?, Error?) -> Void) {
        if let wallet {
            self.clientAPI.makeRequest(route: VerifoneApiEndPoint.initiateWalletTransaction(
                headers: getHeaders(params: params),
                paramters: request.toDictConvertSnake(), wallet: wallet)) { response, error in
                completion(response, error)
            }
        } else {
            self.clientAPI.makeRequest(route: VerifoneApiEndPoint.initiateTransaction(headers: getHeaders(params: params), paramters: request.toDictConvertSnake())) { response, error in
                completion(response, error)
            }
        }
    }

    func checkTransaction(params: Parameters, transactionId: String, completion: @escaping (TransactionResponse?, Error?) -> Void) {
        self.clientAPI.makeRequest(route: VerifoneApiEndPoint.checkTransaction(
            headers: getHeaders(params: params),
            paramters: [:], transactionID: transactionId)) { response, error in
            completion(response, error)
        }
    }

    func authorizePaypal(params: Parameters, merchantReference: String, transactionID: String, completion: @escaping (PaypalTransactionResponse?, Error?) -> Void) {
        let request = ["merchantReference": merchantReference]
        self.clientAPI.makeRequest(route: VerifoneApiEndPoint.authorizePaypal(
            headers: getHeaders(params: params), paramters: request.toDictConvertSnake(),
            transactionID: transactionID)) { response, error in
            completion(response, error)
        }
    }

    func initiatePaypal(params: Parameters, request: PaypalTransaction, completion: @escaping (PaypalTransactionInitiate?, Error?) -> Void) {
        self.clientAPI.makeRequest(route: VerifoneApiEndPoint.initiatePaypal(headers: getHeaders(params: params), paramters: request.toDictConvert())) { response, error in
            completion(response, error)
        }
    }
}
