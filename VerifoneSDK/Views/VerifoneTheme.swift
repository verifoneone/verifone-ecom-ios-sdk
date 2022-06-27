//
//  VerifoneTheme.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 08.12.2021.
//

import UIKit

extension VerifoneSDK {
    @objc(VerifoneSDKTheme) public class Theme: NSObject {
        @objc public static let defaultTheme = Theme()
        
        @objc public var primaryBackgorundColor: UIColor = VerifoneThemeDefaultPrimaryBackgroundColor
        @objc public var textfieldBackgroundColor: UIColor = VerifoneThemeDefaultTextfieldBackgroundColor
        @objc public var textfieldTextColor: UIColor = VerifoneThemeDefaultTextfieldTextColor
        @objc public var textfieldBorderColor: UIColor = VerifoneThemeDefaultTextfieldBorderColor
        @objc public var payButtonBackgroundColor: UIColor = VerifoneThemeDefaultPayButtonBackgroundColor
        @objc public var payButtonDisabledBackgroundColor: UIColor = VerifoneThemeDefaultPayButtonDisabledBackgroundColor
        @objc public var payButtonTextColor: UIColor = VerifoneThemeDefaultPayButtonTextColor
        @objc public var labelColor: UIColor = VerifoneThemeDefaultLabelColor
        @objc public var cardTitleColor: UIColor = VerifoneThemeDefaultCardTitleColor
        
        @objc public var font: UIFont {
            set {
                _font = newValue
            }
            get {
                if let _font = _font {
                    return _font
                } else {
                    let fontMetrics = UIFontMetrics(forTextStyle: .body)
                    return fontMetrics.scaledFont(for: VerifoneDefaultFont)
                }
            }
        }
        private var _font: UIFont?
        
        // MARK: Default Font
        private let VerifoneDefaultFont = UIFont.systemFont(ofSize: 17)
    }
}

private var VerifoneThemeDefaultPrimaryBackgroundColor: UIColor {
    return UIColor.VF.defaultBackground
}

private var VerifoneThemeDefaultTextfieldBackgroundColor: UIColor {
    return UIColor.VF.defaultBackground
}

private var VerifoneThemeDefaultTextfieldTextColor: UIColor {
    return UIColor.VF.text
}

private var VerifoneThemeDefaultTextfieldBorderColor: UIColor {
    return UIColor.VF.color(hex: 0xE4E7ED)
}

private var VerifoneThemeDefaultPayButtonBackgroundColor: UIColor {
    return  UIColor.VF.formButton
}

private var VerifoneThemeDefaultPayButtonDisabledBackgroundColor: UIColor {
    return  UIColor.VF.line
}

private var VerifoneThemeDefaultPayButtonTextColor: UIColor {
    return  UIColor.white
}

private var VerifoneThemeDefaultLabelColor: UIColor {
    return UIColor.VF.text
}

private var VerifoneThemeDefaultCardTitleColor: UIColor {
    return UIColor.black
}
