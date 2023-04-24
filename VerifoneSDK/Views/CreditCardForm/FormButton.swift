//
//  FormButton.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 19.10.2021.
//

import UIKit

@IBDesignable
public class FormButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    private var backgroundColors: [ControlState: UIColor] = [:]

    @IBInspectable public var defaultBackgroundColor: UIColor? {
        didSet {
            setBackgroundColor(defaultBackgroundColor, for: .normal)
        }
    }

    @IBInspectable public var disabledBackgroundColor: UIColor? {
        didSet {
            setBackgroundColor(disabledBackgroundColor, for: .disabled)
        }
    }

    public override var isEnabled: Bool {
        didSet {
            updateBackgroundColor()
        }
    }

    public override var backgroundColor: UIColor? {
        get {
            return backgroundColors[state] ?? backgroundColors[.normal] ?? self.defaultBackgroundColor
        }
        set {
            defaultBackgroundColor = newValue
            updateBackgroundColor()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        updateBackgroundColor()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateBackgroundColor()
    }

    func setBackgroundColor(_ color: UIColor?, for state: ControlState) {
        backgroundColors[state] = color
        updateBackgroundColor()
    }

    private func updateBackgroundColor() {
        super.backgroundColor = self.backgroundColor
    }

    func backgroundColor(for state: ControlState) -> UIColor? {
        return backgroundColors[state]
    }
}
