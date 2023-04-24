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

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"

    var errorDescription: String? {
        rawValue
    }
}

extension String {
    func localized() -> String {
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

        var errorRef: Unmanaged<CFError>?
        if CTFontManagerRegisterGraphicsFont(font, &errorRef) == false {
            print("UIFont+:  Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
        }
    }
}
