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
                        return UIColor.groupTableViewBackground
                    } else {
                        return UIColor.white
                    }
                }
            } else {
                return UIColor.white
            }
        }()
    }

    convenience init(hex: String, alpha: CGFloat = 1) {
            let chars = Array(hex.dropFirst())
            self.init(red: .init(strtoul(String(chars[0...1]), nil, 16))/255,
                      green: .init(strtoul(String(chars[2...3]), nil, 16))/255,
                      blue: .init(strtoul(String(chars[4...5]), nil, 16))/255,
                      alpha: alpha)}
}
