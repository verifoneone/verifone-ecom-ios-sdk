//
//  ProductApi.swift
//  sdkTest
//
//  Created by Oraz Atakishiyev on 17.09.2021.
//

import Foundation
import VerifoneSDK

private var bearerTokenTransaction = ""

struct Product {
    var identifier: UUID
    var image: String
    var title: String
    var description: String
    var price: Double
}

struct HeaderFields {
    let apiUserId: String
    let apiUserKey: String
    let idempotencyKey: String = UUID().uuidString
}

class ProductsAPI {
    static var shared = ProductsAPI()
    var previousNumber: Int = -1

    func initiatePaypal(returnUrl: String, cancelURL: String, itemName: String, price: Int, paymentProviderContract: String) -> PaypalTransaction {
        var request = PaypalTransaction.paypal
        request.setupPaypal(returnUrl: returnUrl, cancelURL: cancelURL, itemName: itemName, price: price, paymentProviderContract: paymentProviderContract)
        return request
    }

    func getRandomInt() -> Int {
        var randomNumber = arc4random_uniform(15)+1
        while previousNumber == randomNumber {
            randomNumber = arc4random_uniform(15)+1
        }
        previousNumber = Int(randomNumber)
        return Int(randomNumber)
    }

    func getJWT(request: RequestJwt, completion: @escaping (ResponseJwt?, String?) -> Void) {
        var urlRequest: URLRequest?
        print(request.toDictConvertSnake())
        urlRequest = Request.create("\(MerchantAppConfig.shared.baseURL)/oidc/3ds-service/v2/jwt/create",
                                        with: request.toDictConvertSnake())

        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }

    func lookup(request: OrderData, completion: @escaping (ResponseLookup?, String?) -> Void) {
        var urlRequest: URLRequest?

        urlRequest = Request.create("\(MerchantAppConfig.shared.baseURL)/oidc/3ds-service/v2/lookup",
                                        with: request.toDictConvertSnake())

        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }

    func validate(request: RequestValidate, completion: @escaping (ValidateResponse?, String?) -> Void) {
        var urlRequest: URLRequest?

        urlRequest = Request.create("\(MerchantAppConfig.shared.baseURL)/oidc/3ds-service/v2/jwt/validate",
                                        with: request.toDictConvertSnake())

        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }

    func transaction(request: RequestTransaction, completion: @escaping (TransactionResponse?, String?) -> Void) {
        var urlRequest: URLRequest?
        print(request.toDictConvertSnake())
        urlRequest = Request.create("\(MerchantAppConfig.shared.baseURL)/oidc/api/v2/transactions/card",
                                        with: request.toDictConvertSnake())
        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }

    func initiateWalletTransaction(request: RequestTransaction, completion: @escaping (TransactionResponse?, String?) -> Void) {
        var urlRequest: URLRequest?
        print(request.toDictConvertSnake())
        urlRequest = Request.create("\(MerchantAppConfig.shared.baseURL)/oidc/api/v2/transactions/wallet",
                                    with: request.toDictConvertSnake(), authenticationType: "Bearer")

        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }

    func initiateTransaction(url: String, request: RequestTransaction, headerFields: HeaderFields, completion: @escaping (TransactionResponse?, String?) -> Void) {
        var urlRequest: URLRequest?
        print(request.toDictConvertSnake())
        urlRequest = Request.create(url,
                                    with: request.toDictConvertSnake(), authenticationType: "Basic", headerFields: headerFields)

        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }

    func checkTransaction(transactionId: String, headerFields: HeaderFields, completion: @escaping (TransactionResponse?, String?) -> Void) {
        var urlRequest: URLRequest?
        urlRequest = Request.create("\(MerchantAppConfig.shared.baseURL)/oidc/api/v2/transaction/\(transactionId)", with: nil, authenticationType: "Basic", httpMethod: "GET", headerFields: headerFields)

        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }

    // MARK: - Complete Klarna
    func completeKlarna(url: String, request: AuthToken, headerFields: HeaderFields, completion: @escaping (TransactionResponse?, String?) -> Void) {
        var urlRequest: URLRequest?

        print("klarna completion request: \(request.toDictConvertSnake())")
        urlRequest = Request.create(url,
                                    with: request.toDictConvertSnake(), authenticationType: "Basic", headerFields: headerFields)

        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }

    func createReuseToken(request: RequestReuseToken, completion: @escaping (ResponseReuseToken?, String?) -> Void) {
        var urlRequest: URLRequest?

        urlRequest = Request.create("\(MerchantAppConfig.shared.baseURL)/oidc/api/v2/card",
                                    with: request.toDictConvertSnake(), httpMethod: "PUT")

        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }

    func makeRequest<T: Decodable>(
        urlRequest: URLRequest?, completion: @escaping (T?, String?) -> Void) {
        let config: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: config)

        if let myRequest = urlRequest {
            let task = session.dataTask(with: myRequest, completionHandler: { (result, _, error) in

                #if DEBUG
                print("Result:\n\(String(data: result ?? Data(), encoding: .utf8) ?? "result")")
                #endif

                guard error == nil else {
                    completion(nil, "request error: " + error!.localizedDescription)
                    return
                }
                guard let data = result else {
                    completion(nil, "No data")
                    return
                }

                if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if let code = json["code"] {
                        guard let message = json["message"] as? String else {
                            completion(nil, "request error code: \(code)")
                            return
                        }
                        
                        if let data = try? JSONSerialization.data(withJSONObject: json["details"] ?? "", options: .prettyPrinted) {
                            if let string = String(data: data, encoding: String.Encoding.utf8) {
                                completion(nil, "\(string) \n \(message)")
                                return
                            }
                        }

                        completion(nil, message)
                        return
                    }
                    if let message = json["message"] as? String {
                        completion(nil, message)
                        return
                    }
                }

                do {
                    let decoder = JSONDecoder()
                    let decodableData: T = try decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(decodableData, nil)
                    }
                } catch let exception {
                    print("Exception: \(exception)")
                    let resultString = String(data: data, encoding: .utf8) ?? "empty data"
                    completion(nil, "decode error: " + exception.localizedDescription + "\nResult: \(resultString)")
                }
            })

            task.resume()
        } else {
            completion(nil, "Couldn't make api connection")
        }
    }
}

extension ProductsAPI {
    func ppInitiatePayment(request: PaypalTransaction, completion: @escaping (PaypalTransactionInitiate?, String?) -> Void) {
        var urlRequest: URLRequest?

        urlRequest = Request.create("\(MerchantAppConfig.shared.baseURL)/oidc/paypal-ecom/transactions",
                                    with: request.toDictConvert())

        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }

    func ppAuthorizePayment(merchantReference: String, transactionID: String, completion: @escaping (PaypalTransactionResponse?, String?) -> Void) {
        var urlRequest: URLRequest?
        let request = ["merchantReference": merchantReference]
        urlRequest = Request.create("\(MerchantAppConfig.shared.baseURL)/oidc/paypal-ecom/transactions/\(transactionID)/authorize",
                                    with: request)

        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }
}

struct Request {

    static func create(_ url: String,
                       with bodyParams: [String: Any?]?,
                       authenticationType: String = "Basic", httpMethod: String = "POST", headerFields: HeaderFields? = nil) -> URLRequest? {

        guard let urlRequest: URL = URL(string: url) else { return nil }
        var request: URLRequest = URLRequest(url: urlRequest)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if httpMethod == "POST" {
            guard let params = bodyParams else { return nil }
            let onlyValues = params.filter { (_, value) -> Bool in
                return value != nil
            }
            
            guard let postData = try? JSONSerialization.data(withJSONObject: onlyValues, options: []) else { return nil }
            
            request.httpBody = postData as Data
        }

        var loginString: String!
        if let headerFields = headerFields {
            loginString = String(format: "%@:%@", headerFields.apiUserId, headerFields.apiUserKey)
        } else {
            if MerchantAppConfig.shared.basicAuthUserId == nil || MerchantAppConfig.shared.basicAuthUserKey == nil {
                fatalError("Missing required parameters for credit card at least UserId and UserKey")
            }
            loginString = String(format: "%@:%@", MerchantAppConfig.shared.basicAuthUserId!, MerchantAppConfig.shared.basicAuthUserKey!)
        }
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()

        if authenticationType == "Basic" {
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("\(authenticationType) \(bearerTokenTransaction)", forHTTPHeaderField: "Authorization")
        }

        request.setValue(UUID().uuidString, forHTTPHeaderField: "x-vfi-api-idempotencyKey")
        print("Make request: \(urlRequest.absoluteString)", "Headers: ", request.allHTTPHeaderFields!)

        return request
    }
}

extension ProductsAPI {
    /// For demo purposes, this method simulates an API request with a pre-defined response and delay.
    func loadProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now()) { [self] in
            let desc =
            """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit,
            sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
            Ut enim ad minim veniam, quis nostrud exercitation ullamco
            laboris nisi ut aliquip ex ea commodo consequat.
            """
            completion(.success([
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 1", description: desc, price: 10.99),
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 2", description: desc, price: 20),
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 3", description: desc, price: 23),
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 4", description: desc, price: 21),
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 5", description: desc, price: 17),
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 6", description: desc, price: 40),
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 7", description: desc, price: 50),
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 8", description: desc, price: 13),
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 9", description: desc, price: 40),
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 10", description: desc, price: 40),
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 11", description: desc, price: 80),
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 5", description: desc, price: 17),
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 6", description: desc, price: 40),
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 7", description: desc, price: 50),
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 8", description: desc, price: 13),
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 9", description: desc, price: 40),
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 10", description: desc, price: 40),
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 11", description: desc, price: 80)
            ]))
        }
    }
}
