import Foundation
import CardinalMobile

open class VFCustomUi: UiCustomization {
    public func setButton(_ customButton: VFCustomButton, buttonType: CustomButtonType) {
        self.setButton(customButton, buttonTypeString: buttonType.rawValue)
    }
}

/// Customizable proprierties:
/// headerText, backgroundColor, buttonText, textFontName, textColor, textFontSize
open class VFCustomToolbar: ToolbarCustomization {}

/// Customizable proprierties:
/// backgroundColor, cornerRadius, textFontName, textColor, textFontSize
open class VFCustomButton: ButtonCustomization {}

/// Customizable proprierties:
/// textFontName, textColor, textFontSize, headingTextColor, headingTextFontName, headingTextFontSize
open class VFCustomLabel: LabelCustomization {}

/// Customizable proprierties:
/// textFontName, textColor, textFontSize, borderWidth, borderColor, cornerRadius
open class VFCustomTextBox: TextBoxCustomization {}

public enum CustomButtonType: String {
    /**ButtonTypeVerify Verify button.*/
    case buttonTypeVerify = "ButtonTypeVerify"
    
    /**ButtonTypeContinue Continue button.*/
    case buttonTypeContinue = "ButtonTypeContinue"
    
    /**ButtonTypeNext Next button.*/
    case buttonTypeNext = "ButtonTypeNext"
    
    /**ButtonTypeCancel Cancel button.*/
    case buttonTypeCancel = "ButtonTypeCancel"
    
    /**ButtonTypeResend Resend button.*/
    case buttonTypeResend = "ButtonTypeResend"
}
