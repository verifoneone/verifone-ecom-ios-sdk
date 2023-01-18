//
//  Colors.swift
//  Verifone
//
//  Created by Oraz Atakishiyev on 15.09.2021.
//

import UIKit

extension UIColor {

    public enum VF {

        public static var defaultBackground: UIColor {
            #if compiler(>=5.1)
            if #available(iOS 13, *) {
                return UIColor.systemBackground
            } else {
                return .white
            }
            #else
            return .white
            #endif
        }

        public static let text: UIColor = {
            #if compiler(>=5.1)
            if #available(iOS 13, *) {
                return UIColor { (traitCollection) -> UIColor in
                    if traitCollection.userInterfaceStyle == .dark {
                        return color(hex: 0xD1D1D6)
                    } else {
                        return color(hex: 0x364049)
                    }
                }
            } else {
                return color(hex: 0x364049)
            }
            #else
            return color(hex: 0x364049)
            #endif
        }()

        public static var label: UIColor {
            #if compiler(>=5.1)
            if #available(iOS 13, *) {
                return UIColor { (traitCollection) -> UIColor in
                    if traitCollection.userInterfaceStyle == .dark {
                        return color(hex: 0x8E8E93)
                    } else {
                        return color(hex: 0x858B9A)
                    }
                }
            } else {
                return color(hex: 0x858B9A)
            }
            #else
            return color(hex: 0x858B9A)
            #endif
        }

        public static var line: UIColor {
            #if compiler(>=5.1)
            if #available(iOS 13, *) {
                return UIColor { traitCollection -> UIColor in
                    if traitCollection.userInterfaceStyle == .dark {
                        return color(hex: 0x3A3A3C)
                    } else {
                        return color(hex: 0xE4E7ED)
                    }
                }
            } else {
                return color(hex: 0xE4E7ED)
            }
            #else
            return color(hex: 0xE4E7ED)
            #endif
        }

        public static let cardFormLabel = color(hex: 0x3C414D)

        public static let formButton = color(hex: 0x0A69C7)
        public static let footerText = color(hex: 0x617384)

        internal static func color(hex: UInt) -> UIColor {
            assert(hex >= 0x000000 && hex <= 0xFFFFFF,
                   "Invalid Hex number")
            return UIColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255.0,
                green: CGFloat((hex >> 8) & 0xFF) / 255.0,
                blue: CGFloat(hex & 0xFF) / 255.0,
                alpha: 1.0
            )
        }

    }

}
