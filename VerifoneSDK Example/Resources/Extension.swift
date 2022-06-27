//
//  Extension.swift
//  sdkTest
//
//  Created by Oraz Atakishiyev on 17.09.2021.
//

import UIKit

extension UIViewController {
    func select(product: Product) {
        let viewc = ProductDetailsViewController()
        show(viewc, sender: self)
    }
    
    func show(error: Error) {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.showDetailViewController(alert, sender: self)
        }
}

extension DispatchQueue {
    static func mainAsyncIfNeeded(execute work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            main.async(execute: work)
        }
    }
}

extension Encodable {
    func toDictConvertSnake() -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let enc = try? encoder.encode(self) else {
            return [:]
        }
        guard let dictionary = try? JSONSerialization.jsonObject(with: enc, options: .allowFragments) as? [String: Any] else {
            return [:]
            }
        return dictionary
    }
    
    func toDictConvert() -> [String: Any] {
        let encoder = JSONEncoder()
        guard let enc = try? encoder.encode(self) else {
            return [:]
        }
        guard let dictionary = try? JSONSerialization.jsonObject(with: enc, options: .allowFragments) as? [String: Any] else {
            return [:]
            }
        return dictionary
    }
}

protocol FormattableNumeric {}
extension FormattableNumeric {
    var localized: String {
        guard let number = self as? NSNumber else { return "NaN" }
        return "$\(number.description(withLocale: Locale.current))"
    }
}
extension Int: FormattableNumeric {}
extension Int64: FormattableNumeric {}
extension UInt: FormattableNumeric {}
extension Float: FormattableNumeric {}
extension Double: FormattableNumeric {}

protocol ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}

extension UserDefaults: ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
}

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}

extension String {
    func localized() ->String {
        let bundle = MerchantAppConfig.shared.bundle
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}

public extension UIFont {
    static func jbs_registerFont(withFilenameString filenameString: String, bundle: Bundle) {
        guard let pathForResourceString = bundle.path(forResource: filenameString, ofType: nil) else {
            print("UIFont+:  Failed to register font - path for resource not found.")
            return
        }

        guard let fontData = NSData(contentsOfFile: pathForResourceString) else {
            print("UIFont+:  Failed to register font - font data could not be loaded.")
            return
        }

        guard let dataProvider = CGDataProvider(data: fontData) else {
            print("UIFont+:  Failed to register font - data provider could not be loaded.")
            return
        }

        guard let font = CGFont(dataProvider) else {
            print("UIFont+:  Failed to register font - font could not be loaded.")
            return
        }

        var errorRef: Unmanaged<CFError>? = nil
        if (CTFontManagerRegisterGraphicsFont(font, &errorRef) == false) {
            print("UIFont+:  Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        
        downloaded(from: url, contentMode: mode)
    }
}
