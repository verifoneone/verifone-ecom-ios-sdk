//
//  Globals.swift
//  Verifone
//
//  Created by Oraz Atakishiyev on 20.08.2021.
//

import UIKit
import Foundation

extension Bundle {
    #if !SWIFT_PACKAGE
    static var module = Bundle(for: CreditCardViewController.self)
    #endif
}

typealias AccessibilityCustomRotorDirection = UIAccessibilityCustomRotor.Direction
typealias AttributedStringKey = NSAttributedString.Key
typealias ControlState = UIControl.State

let ViewLayoutFittingCompressedSize = UIView.layoutFittingCompressedSize
let AccessibilityNotificationAnnouncement = UIAccessibility.Notification.announcement

let NotificationKeyboardWillChangeFrameNotification: NSNotification.Name = UIResponder.keyboardWillChangeFrameNotification
let NotificationKeyboardWillHideFrameNotification: NSNotification.Name = UIResponder.keyboardWillHideNotification
let NotificationKeyboardWillShowFrameNotification: NSNotification.Name = UIResponder.keyboardWillShowNotification

let NotificationKeyboardFrameEndUserInfoKey = UIResponder.keyboardFrameEndUserInfoKey
let NotificationKeyboardFrameBeginUserInfoKey = UIResponder.keyboardFrameBeginUserInfoKey

enum HTTPHeaderField {
    static var contentType = "Content-Type"
    static var formURLEncoded = "x-www-form-urlencoded"
}
