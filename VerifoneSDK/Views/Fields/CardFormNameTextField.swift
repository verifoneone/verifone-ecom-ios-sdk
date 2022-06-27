import Foundation
import UIKit

@IBDesignable
@objc(VFCardFormNameTextField) public class CardFormNameTextField: BaseTextField {
    public override var isValid: Bool {
        return !text.isNilOrEmpty
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initializeInstance()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeInstance()
    }
    
    override init() {
        super.init(frame: CGRect.zero)
        initializeInstance()
    }
    
    private func initializeInstance() {
        keyboardType = .default
        textContentType = .name
    }
}
