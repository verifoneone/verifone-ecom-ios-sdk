//
//  UserDefaults+Extensions.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 10.11.2022.
//

import Foundation

extension UserDefaults {

    func save<T: Encodable>(customObject object: T, inKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            self.set(encoded, forKey: key)
        }
    }

    func saves<T: Encodable>(customObject object: [T], inKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            self.set(encoded, forKey: key)
        }
    }

    func retrieve<T: Decodable>(object type: T.Type, fromKey key: String) -> T? {
        if let data = self.data(forKey: key) {
            let decoder = JSONDecoder()
            if let object = try? decoder.decode(type, from: data) {
                return object
            } else {
                print("Couldnt decode object")
                return nil
            }
        } else {
            print("Couldnt find key")
            return nil
        }
    }

    func retrieves<T: Decodable>(object type: [T].Type, fromKey key: String) -> [T]? {
        if let data = self.data(forKey: key) {
            let decoder = JSONDecoder()
            if let object = try? decoder.decode(type, from: data) {
                return object
            } else {
                print("Couldnt decode object")
                return nil
            }
        } else {
            print("Couldnt find key")
            return nil
        }
    }

    func getCurrency(fromKey key: String) -> String {
        if let data = self.value(forKey: key) as? String {
            return data
        } else {
            return "USD"
        }
    }

    func getEnv(fromKey key: String) -> String {
        if let data = self.value(forKey: key) as? String {
            return data
        } else {
            return Env.CST.rawValue
        }
    }

    func booleanValue(for key: String) -> Bool {
        if let data = self.value(forKey: key) as? Bool {
            return data
        } else {
            return false
        }
    }

    func getEnabledPaymentOptions() -> [AppPaymentMethodType]? {
        if let options = self.stringArray(forKey: Keys.paymentOptions) {
            return options.filter {!$0.isEmpty}.map { AppPaymentMethodType(rawValue: $0)! }
        }
        return nil
    }

    func hasReuseToken(forKey: String) -> Bool {
        if self.retrieve(object: ResponseReuseToken.self, fromKey: forKey) != nil {
            return true
        }
        return false
    }
}
