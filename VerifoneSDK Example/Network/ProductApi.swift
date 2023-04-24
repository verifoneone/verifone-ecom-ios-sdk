//
//  ProductApi.swift
//  sdkTest
//
//  Created by Oraz Atakishiyev on 17.09.2021.
//

import Foundation
import VerifoneSDK

struct Product {
    var identifier: UUID
    var image: String
    var title: String
    var description: String
    var price: String
}

class ProductsAPI {
    static var shared = ProductsAPI()
    var previousNumber: Int = -1

    func makeRequest<T: Decodable>(route: ApiEndPoint, completion: @escaping (T?, Error?) -> Void) {
        let config: URLSessionConfiguration = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        let session: URLSession = URLSession(configuration: config)

        guard let urlRequest = route.urlRequest() else {
            completion(nil, AppError.badRequest("Invalid URL for: \(route)"))
            return
        }
        Logger.request(request: urlRequest)
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
        #if DEBUG
            print("Result:\n\(String(data: data ?? Data(), encoding: .utf8) ?? "result")")
        #endif
            guard error == nil else {
                completion(nil, error)
                return
            }
            if let response = response as? HTTPURLResponse {
                let result = self.validateResponse(data: data, urlResponse: response, error: error)
                switch result {
                case .success:
                    do {
                        guard let data = data else {
                            completion(nil, AppError.noData)
                            return
                        }
                        let decoder = JSONDecoder()
                        let decodableData: T = try decoder.decode(T.self, from: data)
                        completion(decodableData, error)
                    } catch let exception {
                        debugPrint(exception)
                        completion(nil, AppError.invalidResponse(exception.localizedDescription))
                    }
                case .failure(let networkFailureError):
                    completion(nil, networkFailureError)
                }
            }
        }

        task.resume()
    }

    private func validateResponse(data: Any?, urlResponse: HTTPURLResponse, error: Error?) -> Result<Any, Error> {
        let decoder = JSONDecoder()
        var errorStr: String = ""
        switch urlResponse.statusCode {
        case 200...299:
            if let data = data {
                return .success(data)
            } else {
                return .failure(AppError.noData)
            }
        case 400...499:
            if let data = data as? Data {
                let decodableData: OrderResponseError? = try? decoder.decode(OrderResponseError.self, from: data)
                if let errorObj = decodableData {
                    errorStr += "\(String(describing: errorObj.code)) message: \(String(describing: errorObj.message))"
                    if let details = decodableData?.details {
                        errorStr += "\n\(String(describing: details.cause))"
                        errorStr += "\n\(String(describing: details.error))"
                    }
                }
            }
            return .failure(AppError.badRequest(errorStr))
        case 500...599:
            return .failure(AppError.serverError(error?.localizedDescription))
        default:
            return .failure(AppError.unknown)
        }
    }

    func getRandomInt() -> Int {
        // swiftlint: disable legacy_random
        var randomNumber = arc4random_uniform(15)+1
        while previousNumber == randomNumber {
            randomNumber = arc4random_uniform(15)+1
        }
        previousNumber = Int(randomNumber)
        return Int(randomNumber)
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
            var products: [Product] = []
            for _ in 0...10 {
                products.append(Product(identifier: UUID(),
                                        image: "\(self.getRandomInt())",
                                        title: "product".localized(),
                                        description: desc,
                                        price: "\(String(format: "%.2f", Float.random(in: 15...35)))"))
            }
            completion(.success(products))
        }
    }
}

struct Logger { 
    static func request(request: URLRequest) {
#if DEBUG
        print("\n- - - - - - -REQUEST STARTTED- - - - - -")

        let urlString = request.url?.absoluteString ?? ""
        var logStr = "\(urlString)\n"
        for (key, value) in request.allHTTPHeaderFields ?? [:] {
            logStr += "\(key): \(value) "
        }
        if let body = request.httpBody {
            logStr += "\n\(NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "")"
        }
        print(logStr)
#endif
    }
}
