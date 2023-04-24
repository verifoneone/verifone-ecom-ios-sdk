//
//  UISwitch+Extensions.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 03.04.2023.
//

import UIKit

class AppSwitchButton: UISwitch {

    // MARK: - Functions

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let height = 40.0
        let width = 20.0
        let newArea = CGRect(
            x: self.bounds.origin.x - width/2,
            y: self.bounds.origin.y - height/2,
            width: self.bounds.size.width + width,
            height: self.bounds.size.height + height
        )
        return newArea.contains(point)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
