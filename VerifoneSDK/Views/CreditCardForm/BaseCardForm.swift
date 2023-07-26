//
//  BaseCardForm.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 03.07.2023.
//

import UIKit

public class BaseCardForm: UIViewController {
    var contentView: UIScrollView! = UIScrollView()

    var cardFormInputFields: [BaseTextField]! = []
    var cardFormLabels: [UILabel]! = []
    var cardFormErrorLabels: [UILabel]! = []
    var currentEditingTextField: BaseTextField?

    var gotoPreviousFieldBarButtonItem: UIBarButtonItem!
    var gotoNextFieldBarButtonItem: UIBarButtonItem! = UIBarButtonItem()
    var doneEditingBarButtonItem: UIBarButtonItem! = UIBarButtonItem()

    @objc func keyboardWillAppear(_ notification: Notification) {
        guard let frameEnd = notification.userInfo?[NotificationKeyboardFrameEndUserInfoKey] as? CGRect,
              let frameStart = notification.userInfo?[NotificationKeyboardFrameBeginUserInfoKey] as? CGRect,
              frameEnd != frameStart else {
                  return
              }

        let intersectedFrame = contentView.convert(frameEnd, from: nil)
        contentView.contentInset.bottom = intersectedFrame.height

        let bottomScrollIndicatorInset: CGFloat = intersectedFrame.height
        contentView.contentInset.bottom = bottomScrollIndicatorInset
        contentView.scrollIndicatorInsets.bottom = bottomScrollIndicatorInset
    }

    @objc func keyboardWillChangeFrame(_ notification: NSNotification) {
        let keyboardsize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        guard let activeTextField = currentEditingTextField, let keyboardHeight = keyboardsize?.height else {
            return
        }

        let bottomScrollIndicatorInset: CGFloat = keyboardHeight + activeTextField.frame.height
        contentView.contentInset.bottom = bottomScrollIndicatorInset
        contentView.scrollIndicatorInsets.bottom = bottomScrollIndicatorInset
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        contentView.contentInset.bottom = 0.0
        contentView.scrollIndicatorInsets.bottom = 0.0
    }
}
