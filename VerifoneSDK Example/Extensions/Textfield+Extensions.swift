//
//  Textfield+Extensions.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 09.11.2022.
//

import UIKit

class AppTextField: UITextField {
    private var insets: UIEdgeInsets {
        let edgeInsets: UIEdgeInsets = UIEdgeInsets(
                top: layoutMargins.top,
                left: layoutMargins.left,
                bottom: layoutMargins.bottom,
                right: layoutMargins.right
            )

        return edgeInsets
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: textAreaViewRect(forBounds: bounds))
    }

    open override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return super.clearButtonRect(forBounds: textAreaViewRect(forBounds: bounds))
    }

    public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.rightViewRect(forBounds: textAreaViewRect(forBounds: bounds))
    }

    public override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return super.leftViewRect(forBounds: textAreaViewRect(forBounds: bounds))
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: textAreaViewRect(forBounds: bounds))
    }

    func textAreaViewRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }
}

extension UITextField {
    func setIcon(_ image: UIImage) {
        let iconView = UIImageView(frame:
                                    CGRect(x: 10, y: 5, width: 20, height: 20))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame:
                                                CGRect(x: 20, y: 0, width: 35, height: 30))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }

    func setRightIcon(_ color: UIColor) {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 30))
        let colorContainerView: UIView = UIView(frame: CGRect(x: -5, y: 0, width: 30, height: 30))
        colorContainerView.backgroundColor = color
        colorContainerView.layer.cornerRadius = 15
        colorContainerView.layer.masksToBounds = true
        colorContainerView.layer.borderWidth = 0.2
        colorContainerView.layer.borderColor = UIColor.gray.cgColor
        containerView.addSubview(colorContainerView)
        rightView = containerView
        rightViewMode = .always
    }
}
