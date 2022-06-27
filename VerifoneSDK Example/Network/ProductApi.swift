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
    var price: Int64
}

class ProductsAPI {
    static var shared = ProductsAPI()
    var previousNumber: Int = -1
    /// For demo purposes, this method simulates an API request with a pre-defined response and delay.
    func loadProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now()) { [self] in
            let desc = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. "
            completion(.success([
                Product(identifier: UUID(), image: "\(self.getRandomInt())", title: "\("product".localized()) 1", description: desc, price: 10),
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
    
    func initiatePp(returnUrl: String, cancelURL: String, itemName: String, price: Int) -> PaypalTransaction {
        let mobile = PhoneNumber(phoneType: "MOBILE", value: "64646464")
        let identification = Identification(taxIdentificationNumber: "123456", taxIdentificationType: "BR_CNPJ")
        let address = Address(country: "US", postalCode: "570023", countrySubdivision: "IN-MH", city: "yyy", addressLine1: "add1", addressLine2: "add2")
        let customer = Customer(email: "verifone-buyer@paypal.com", payerID: "WDJJHEBZ4X2LY", phoneNumber: mobile, birthDate: "2000-01-31", identification: identification, address: address, firstName: "James", lastName: "Smith")
        let shipping = Shipping(address: address, fullName: "JamesSmith")
        let applicationContext = ApplicationContext(brandName: "MAHENDRA", shippingPreference: "CustomerProvided", returnURL: returnUrl, cancelURL: cancelURL)
        let item = Item(name: itemName, unitAmount: Amount(currencyCode: CurrencyCode.usd, value: price), tax: Amount(currencyCode: .usd, value: 100), quantity: "1", itemDescription: "Item description", sku: "123", category: "PHYSICAL_GOODS")
        let detailedAmount = DetailedAmount(discount: Amount(currencyCode: .usd, value: 200), shippingDiscount: Amount(currencyCode: .usd, value: 200), insurance: Amount(currencyCode: .usd, value: 100), handling: Amount(currencyCode: .usd, value: 100), shipping: Amount(currencyCode: .usd, value: 100))
        let paypalData = PaypalTransaction(intent: "AUTHORIZE", customer: customer, applicationContext: applicationContext, shipping: shipping, paymentProviderContract: "6a012763-88e6-4073-8197-fdd193fb01cb", items: [item], dynamicDescriptor: "Paypal order 123", merchantReference: "123test", detailedAmount: detailedAmount, amount: Amount(currencyCode: .usd, value: (price+400)-400))
        return paypalData
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

        urlRequest = Request.create("\(MerchantAppConfig.baseURL)/3ds-service/v2/jwt/create",
                                        with: request.toDictConvertSnake())
        
        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }
    
    func lookup(request: OrderData, completion: @escaping (ResponseLookup?, String?) -> Void) {
        var urlRequest: URLRequest?

        urlRequest = Request.create("\(MerchantAppConfig.baseURL)/3ds-service/v2/lookup",
                                        with: request.toDictConvertSnake())
        
        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }
    
    func validate(request: RequestValidate, completion: @escaping (ValidateResponse?, String?) -> Void) {
        var urlRequest: URLRequest?

        urlRequest = Request.create("\(MerchantAppConfig.baseURL)/3ds-service/v2/jwt/validate",
                                        with: request.toDictConvertSnake())
        
        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }
    
    func transaction(request: RequestTransaction, completion: @escaping (TransactionResponse?, String?) -> Void) {
        var urlRequest: URLRequest?

        urlRequest = Request.create("\(MerchantAppConfig.baseURL)/api/v2/transactions/card",
                                        with: request.toDictConvertSnake())
        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }
    
    func initiateWalletTransaction(request: RequestTransaction, completion: @escaping (TransactionResponse?, String?) -> Void) {
        var urlRequest: URLRequest?
        print(request.toDictConvertSnake())
        urlRequest = Request.create("\(MerchantAppConfig.baseURL)/api/v2/transactions/wallet",
                                    with: request.toDictConvertSnake(), authenticationType: "Bearer", forceSetToken: "")
        
        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }
    
    func initiateTransaction(url: String, request: RequestTransaction, forceSetToken: String? = nil, completion: @escaping (TransactionResponse?, String?) -> Void) {
        var urlRequest: URLRequest?
        print(request.toDictConvertSnake())
        urlRequest = Request.create(url,
                                    with: request.toDictConvertSnake(), authenticationType: "Basic", forceSetToken: forceSetToken)
        
        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }
    
    // MARK: - Complete Klarna
    func completeKlarna(url: String, request: AuthToken, forceSetToken: String? = nil, completion: @escaping (TransactionResponse?, String?) -> Void) {
        var urlRequest: URLRequest?
        urlRequest = Request.create(url,
                                    with: request.toDictConvertSnake(), authenticationType: "Basic", forceSetToken: forceSetToken)
        
        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }
    
    func createReuseToken(request: RequestReuseToken, completion: @escaping (ResponseReuseToken?, String?) -> Void) {
        var urlRequest: URLRequest?

        urlRequest = Request.create("\(MerchantAppConfig.baseURL)/api/v2/card",
                                    with: request.toDictConvertSnake(), httpMethod: "PUT")
        
        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }
    
    func makeRequest<T: Decodable>(urlRequest: URLRequest?,
                               completion: @escaping (T?, String?) -> Void) {
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
                
                if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Dictionary<String,Any> {
                    if let code = json["code"] {
                        guard let message = json["message"] as? String else {
                            completion(nil, "request error code: \(code)")
                            return
                        }
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

        urlRequest = Request.create("\(MerchantAppConfig.baseURL)/paypal-ecom/transactions",
                                    with: request.toDictConvert())
        
        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }
    
    func ppAuthorizePayment(merchantReference: String, transactionID: String, completion: @escaping (PaypalTransactionResponse?, String?) -> Void) {
        var urlRequest: URLRequest?
        let request = ["merchantReference": merchantReference]
        urlRequest = Request.create("\(MerchantAppConfig.baseURL)/paypal-ecom/transactions/\(transactionID)/authorize",
                                    with: request)
        
        makeRequest(urlRequest: urlRequest) { response, str in
            completion(response, str)
        }
    }
}

struct Request {

    static func create(_ url: String,
                       with bodyParams: [String: Any?]?,
                       authenticationType: String = "Basic", httpMethod: String = "POST", forceSetToken: String? = nil) -> URLRequest? {

        guard let urlRequest: URL = URL(string: url) else { return nil }
        var request: URLRequest = URLRequest(url: urlRequest)
        request.httpMethod = httpMethod
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let params = bodyParams else { return nil }
        print("Make request: \(urlRequest.absoluteString)")
        let onlyValues = params.filter { (_, value) -> Bool in
            return value != nil
        }

        guard let postData = try? JSONSerialization.data(withJSONObject: onlyValues, options: []) else { return nil }

        request.httpBody = postData as Data

        let loginString: String! = String(format: "%@:%@", MerchantAppConfig.shared.basicAuthUserId, MerchantAppConfig.shared.basicAuthUserKey)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        if (authenticationType == "Basic") {
//            print("Basic \(base64LoginString)")
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        } else {
//            print(bearerTokenTransaction)
            request.setValue("\(authenticationType) \(bearerTokenTransaction)", forHTTPHeaderField: "Authorization")
        }
        if let token = forceSetToken {
            request.setValue(UUID().uuidString, forHTTPHeaderField: "x-vfi-api-idempotencyKey")
            request.setValue("\(authenticationType) \(token)", forHTTPHeaderField: "Authorization")
        }
        
        print(request.allHTTPHeaderFields!)
            
        return request
    }
}


