//
//  UIColor+Extensions.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 15.11.2022.
//

import UIKit

extension UIColor {
    public enum AppColors {
        public static let background: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                    if UITraitCollection.userInterfaceStyle == .dark {
                        return UIColor.systemBackground
                    } else {
                        return UIColor.white
                    }
                }
            } else {
                return UIColor.white
            }
        }()

        public static let textfieldRedColor: UIColor = {
            return UIColor(hex: "#FFEBEE")
        }()

        public static let lightGray: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.systemGray2
            } else {
                return UIColor.lightGray
            }
        }()

        public static let lineGray: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor(hex: "#E0E0E0")
            } else {
                return UIColor.lightGray
            }
        }()

        public static let defaultBlackLabelColor: UIColor = {
            if #available(iOS 13.0, *) {
                return UIColor.label
            } else {
                return UIColor.black
            }
        }()
    }

    convenience init(hex: String, alpha: CGFloat = 1) {
            let chars = Array(hex.dropFirst())
            self.init(red: .init(strtoul(String(chars[0...1]), nil, 16))/255,
                      green: .init(strtoul(String(chars[2...3]), nil, 16))/255,
                      blue: .init(strtoul(String(chars[4...5]), nil, 16))/255,
                      alpha: alpha)}
    convenience init(_ rgbValue: Int) {
        self.init(
            red: CGFloat((Float((rgbValue & 0xff0000) >> 16)) / 255.0),
            green: CGFloat((Float((rgbValue & 0x00ff00) >> 8)) / 255.0),
            blue: CGFloat((Float((rgbValue & 0x0000ff) >> 0)) / 255.0),
            alpha: 1.0)
    }
}
