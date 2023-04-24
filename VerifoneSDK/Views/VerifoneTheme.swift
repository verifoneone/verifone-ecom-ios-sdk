//
//  VerifoneTheme.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 08.12.2021.
//

import UIKit

extension VerifoneSDK {
    public class Theme: NSObject {
        public static let defaultTheme = Theme()

        public var primaryBackgorundColor: UIColor = VerifoneThemeDefaultPrimaryBackgroundColor
        public var textfieldBackgroundColor: UIColor = VerifoneThemeDefaultTextfieldBackgroundColor
        public var textfieldTextColor: UIColor = VerifoneThemeDefaultTextfieldTextColor
        public var textfieldBorderColor: UIColor = VerifoneThemeDefaultTextfieldBorderColor
        public var payButtonBackgroundColor: UIColor = VerifoneThemeDefaultPayButtonBackgroundColor
        public var payButtonDisabledBackgroundColor: UIColor = VerifoneThemeDefaultPayButtonDisabledBackgroundColor
        public var payButtonTextColor: UIColor = VerifoneThemeDefaultPayButtonTextColor
        public var labelColor: UIColor = VerifoneThemeDefaultLabelColor
        public var cardTitleColor: UIColor = VerifoneThemeDefaultCardTitleColor

        public var font: UIFont {
            get {
                if let _font = _font {
                    return _font
                } else {
                    let fontMetrics = UIFontMetrics(forTextStyle: .body)
                    return fontMetrics.scaledFont(for: VerifoneDefaultFont)
                }
            }
            set {
                _font = newValue
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
