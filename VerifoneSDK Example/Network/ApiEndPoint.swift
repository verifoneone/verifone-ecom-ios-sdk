//
//  ApiEndpoint.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 21.03.2023.
//

import Foundation

public typealias RequestHeaders = [String: String]
public typealias RequestParameters = [String: Any]

public enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

/// protocol ApiEndPoint defines the basic properties that a request object should have
public protocol ApiEndPoint {
    var path: String { get }
    var method: RequestMethod { get }
    var parameters: RequestParameters? { get }
    var headers: RequestHeaders { get }
}

/// extension ApiEndPoint provides an implementation for creating a URLRequest object
public extension ApiEndPoint {
    /// urlRequest creates a URLRequest object with the properties defined in the protocol
    func urlRequest() -> URLRequest? {
        guard let url = url(with: MerchantAppConfig.shared.baseURL) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = jsonBody
        return request
    }

    /// url creates a URL object by combining the baseURL and the path properties
    private func url(with baseURL: String) -> URL? {
        guard var urlComponents = URLComponents(string: baseURL) else {
            return nil
        }
        urlComponents.path = urlComponents.path + path
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }

    /// queryItems creates an array of URLQueryItem objects from the parameters property
    private var queryItems: [URLQueryItem]? {
        guard method == .get, let parameters = parameters else {
            return nil
        }
        return parameters.map { (key: String, value: Any?) -> URLQueryItem in
            let valueString = String(describing: value)
            return URLQueryItem(name: key, value: valueString)
        }
    }

    /// jsonBody creates a JSON encoded Data object from the parameters property
    private var jsonBody: Data? {
        guard [.post, .put].contains(method), let parameters = parameters else {
            return nil
        }
        var jsonBody: Data?
        do {
            jsonBody = try JSONSerialization.data(withJSONObject: parameters,
                                                  options: [])
        } catch {
            print(error)
        }
        return jsonBody
    }
}
