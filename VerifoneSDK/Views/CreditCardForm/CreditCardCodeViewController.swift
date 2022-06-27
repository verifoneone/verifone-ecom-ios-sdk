//
//  CreditCardViewController.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 22.11.2021.
//

import UIKit

@objc public protocol VFCreditCardFormViewControllerDelegate: AnyObject {
    @objc func creditCardFormViewControllerDidCardEncrypted(_ controller: CreditCardViewController, result: VerifoneFormResult)
    @objc func creditCardFormViewControllerDidCancel(_ controller: CreditCardViewController, callback: CallbackStatus)
}

public protocol CreditCardFormViewControllerDelegate: AnyObject {
    func creditCardFormViewControllerDidCardEncrypted(_ controller: CreditCardViewController, result: VerifoneFormResult)
    func creditCardFormViewControllerDidCancel(_ controller: CreditCardViewController, callback: CallbackStatus)
}

@objc(VFCreditCardFormViewController)
public class CreditCardViewController: UIViewController, UITextFieldDelegate  {
    
    public var didSaveCardStateChanged: ((_ isOn: Bool) -> Void)?
    var theme: VerifoneSDK.Theme!
    
    private var result: VerifoneFormResult! = VerifoneFormResult()
    var currentEditingTextField: BaseTextField?
    var contentView: UIScrollView! = UIScrollView()
    private var titleCardForm: UILabel = UILabel(frame: .zero)
    private var closeButton: UIButton = UIButton(frame: .zero)
    private var verifoneLogo: UIImageView = UIImageView(image: UIImage(named: "logo", in: .module, compatibleWith: nil))
    private var lockImage: UIImageView = UIImageView(image: UIImage(named: "lock", in: .module, compatibleWith: nil))
    private var footerText: UILabel = UILabel(frame: .zero)
    
    private var cardFormNumberLabel: UILabel = UILabel(frame: .zero)
    private var cardFormNameLabel: UILabel = UILabel(frame: .zero)
    private var cardFormExpiryDateLabel: UILabel = UILabel(frame: .zero)
    private var cvcLabel: UILabel = UILabel(frame: .zero)
    
    private var cardFormNumberTextField: CardFormNumberTextField = CardFormNumberTextField(frame: .zero)
    private var cardFormNameTextField: CardFormNameTextField = CardFormNameTextField(frame: .zero)
    private var cardFormExpiryDateTextField: CardFormExpiryDateTextField = CardFormExpiryDateTextField(frame: .zero)
    private var cvcTextField: CVVTextField = CVVTextField(frame: .zero)
    
    var gotoPreviousFieldBarButtonItem: UIBarButtonItem!
    var gotoNextFieldBarButtonItem: UIBarButtonItem! = UIBarButtonItem()
    var doneEditingBarButtonItem: UIBarButtonItem! = UIBarButtonItem()
    
    private var cardNumberErrorLabel: UILabel = UILabel(frame: .zero)
    private var cardHolderNameErrorLabel: UILabel = UILabel(frame: .zero)
    private var cardExpiryDateErrorLabel: UILabel = UILabel(frame: .zero)
    private var cardCVCErrorLabel: UILabel = UILabel(frame: .zero)
    
    private var switchButtonLabel: UILabel = UILabel(frame: .zero)
    private var switchButton: UISwitch = UISwitch(frame: .zero)
    private var hBottomStackView: UIStackView   = UIStackView()
    
    var cardFormInputFields: [BaseTextField]! = []
    var cardFormLabels: [UILabel]! = []
    var cardFormErrorLabels: [UILabel]! = []
    
    var cardBrandImageView: UIImageView! = UIImageView()
    var cvcInfoImageView: UIImageView! = UIImageView()
    var requestingIndicatorView: UIActivityIndicatorView! = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    private var edgeInsets = UIEdgeInsets(top: 0, left: 15.0, bottom: 0.0, right: 15.0)
    
    var confirmButton: FormButton = FormButton(frame: .zero)
    lazy var formFieldsAccessoryView: UIToolbar = {
        let formFieldsAccessoryView = UIToolbar()
        formFieldsAccessoryView.barStyle = .default
        formFieldsAccessoryView.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(CreditCardViewController.doneEditing(_:)))
        let flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)

        gotoPreviousFieldBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back", in: .module, compatibleWith: nil)!, style: UIBarButtonItem.Style.plain, target: self, action: #selector(CreditCardViewController.gotoPreviousField(_:)))
        gotoNextFieldBarButtonItem.width = 50.0
        gotoNextFieldBarButtonItem = UIBarButtonItem(image: UIImage(named: "Next Field", in: .module, compatibleWith: nil)!, style: UIBarButtonItem.Style.plain, target: self, action: #selector(CreditCardViewController.gotoNextField(_:)))

        formFieldsAccessoryView.setItems([fixedSpaceButton,  gotoPreviousFieldBarButtonItem, fixedSpaceButton, gotoNextFieldBarButtonItem, flexibleSpaceButton, doneButton], animated: false)
        return formFieldsAccessoryView
    }()
    
    public var paymentConfiguration: VerifoneSDK.PaymentConfiguration!
    /// Delegate to receive CreditCardFormController result.
    public weak var delegate: CreditCardFormViewControllerDelegate?
    @objc(delegate) public weak var __delegate: VFCreditCardFormViewControllerDelegate?
    
    public init(paymentConfiguration: VerifoneSDK.PaymentConfiguration, theme: VerifoneSDK.Theme) {
        super.init(nibName: nil, bundle: nil)
        self.paymentConfiguration = paymentConfiguration
        self.theme = theme
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setEventHandlers()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if #available(iOS 11, *) {
        } else {
            cardFormInputFields.forEach {
                $0.invalidateIntrinsicContentSize()
            }
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear(_:)),
            name: NotificationKeyboardWillShowFrameNotification,
            object: nil
        )
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter().removeObserver(self, name: NotificationKeyboardWillShowFrameNotification, object: nil)
    }
    
    public override func loadView() {
        super.loadView()
        createViews()
        setColors()
      
        view.backgroundColor = theme.primaryBackgorundColor
        
        confirmButton.setTitleColor(theme.payButtonTextColor, for: .normal)
        confirmButton.defaultBackgroundColor = theme.payButtonBackgroundColor
        confirmButton.disabledBackgroundColor = theme.payButtonDisabledBackgroundColor
        cardFormNameTextField.autocorrectionType = .no

        formFieldsAccessoryView.barTintColor = UIColor.VF.defaultBackground
    }
    
    var isCardInputDataValid: Bool {
        return cardFormInputFields.areFieldsValid()
    }
    
    private func setEventHandlers() {
        closeButton.addTarget(self, action: #selector(cancelCardForm), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(CreditCardViewController.encryptCard), for: .touchUpInside)
        switchButton.addTarget(self, action: #selector(CreditCardViewController.saveCardSwitchChanged), for: .valueChanged)
        
        cardFormInputFields.forEach {
            $0.addTarget(self, action: #selector(updateAccessibilityValue(_:)), for: .valueChanged)
            $0.addTarget(self, action: #selector(updateAccessibilityValue(_:)), for: .editingChanged)
            $0.addTarget(self, action: #selector(updateInputAccessoryViewFor(_:)), for: .editingDidBegin)
            $0.addTarget(self, action: #selector(validateTextFieldDataOf(_:)), for: .editingDidEnd)
        }
    }
    
    private func setColors() {
        guard isViewLoaded else {
            return
        }
        cardFormInputFields = [cardFormNumberTextField,
                              cardFormExpiryDateTextField,
                               cvcTextField,
                               cardFormNameTextField]
        cardFormLabels = [cardFormNumberLabel,
                          cardFormNameLabel,
                          cardFormExpiryDateLabel,
                          cvcLabel]
        cardFormErrorLabels = [cardNumberErrorLabel,
                               cardHolderNameErrorLabel,
                               cardExpiryDateErrorLabel,
                               cardCVCErrorLabel]

        cardFormInputFields.forEach {
            $0.inputAccessoryView = formFieldsAccessoryView
        }

        cardFormErrorLabels.forEach {
            $0.textColor = UIColor.red
        }

        cardFormInputFields.forEach(self.updateAccessibilityValue)

        cardFormInputFields.forEach {
            $0.backgroundColor = theme.textfieldBackgroundColor
            $0.borderWidth = 1
            $0.cornerRadius = 3
            $0.textColor = theme.textfieldTextColor
            $0.borderColor = theme.textfieldBorderColor
            $0.placeholderTextColor = UIColor.VF.label
        }

        cardFormLabels.forEach {
            $0.textColor = theme.labelColor
        }

        switchButtonLabel.textColor = theme.labelColor
        titleCardForm.textColor = theme.cardTitleColor

        updateCardBrand()
        setConfigAccessibility()
        cardFormInputFields.forEach {
            $0.adjustsFontForContentSizeCategory = true
        }
        cardFormLabels.forEach {
            $0.adjustsFontForContentSizeCategory = true
        }
        confirmButton.titleLabel?.adjustsFontForContentSizeCategory = true

        if #available(iOS 11, *) {
        } else {
            automaticallyAdjustsScrollViewInsets = true
        }

        cardFormNumberTextField.rightView = cardBrandImageView
        cvcTextField.rightView = cvcInfoImageView

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: NotificationKeyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: NotificationKeyboardWillHideFrameNotification,
            object: nil
        )
    }
    
    private func cancelForm() {
        cancelCardForm()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc @discardableResult
    private func cancelCardForm() -> Bool {
        if let delegate = self.delegate {
            delegate.creditCardFormViewControllerDidCancel(self, callback: .cancel)
            AppLog.log("cancel form", log: uiLogObject, type: .default)
            return true
        } else if let delegate =  __delegate {
            delegate.creditCardFormViewControllerDidCancel(self, callback: .cancel)
            AppLog.log("cancel form", log: uiLogObject, type: .default)
            return true
        }
        return true
    }
    
    private func updateCardBrand() {
        let valid = isCardInputDataValid
        confirmButton.isEnabled = valid

        if valid {
            confirmButton.accessibilityTraits.remove(UIAccessibilityTraits.notEnabled)
        } else {
            confirmButton.accessibilityTraits.insert(UIAccessibilityTraits.notEnabled)
        }

        let cardBrandIconName: String? = cardFormNumberTextField.cardBrand
        var cvcInfoIconName: String? = nil
        if cardFormNumberTextField.cardBrand == "AMEX" {
            cvcInfoIconName = "CVV AMEX"
        } else if cardFormNumberTextField.cardBrand != nil {
            cvcInfoIconName = "CVV"
        }
        
        cardBrandImageView.image = cardBrandIconName.flatMap { UIImage(named: $0, in: .module, compatibleWith: nil) }
        cvcInfoImageView.image = cvcInfoIconName.flatMap{ UIImage(named: $0, in: .module, compatibleWith: nil)}
        cardFormNumberTextField.rightViewMode = cardBrandImageView.image != nil ? .always : .never
        cvcTextField.rightViewMode = cvcInfoImageView.image != nil ? .always : .never
        
    }
    
    @objc private func validateField(_ textField: BaseTextField) {
        guard let errorLabel = setCardInputErrorFor(textField) else {
            return
        }
        do {
            try textField.validate()
            errorLabel.alpha = 0.0
        } catch {
            errorLabel.text = validationErrorText(for: textField, error: error)
            errorLabel.alpha = errorLabel.text != "-" ? 1.0 : 0.0
        }
    }
    
    fileprivate func setCardInputErrorFor(_ textField: BaseTextField) -> UILabel? {
        switch textField {
        case cardFormNumberTextField:
            return cardNumberErrorLabel
        case cardFormNameTextField:
            return cardHolderNameErrorLabel
        case cardFormExpiryDateTextField:
            return cardExpiryDateErrorLabel
        case cvcTextField:
            return cardCVCErrorLabel
        default:
            return nil
        }
    }
    
    private func startActivityIndicator() {
        requestingIndicatorView.startAnimating()
        confirmButton.isEnabled = false
        view.isUserInteractionEnabled = false
    }
    
    private func stopActivityIndicator() {
        requestingIndicatorView.stopAnimating()
        confirmButton.isEnabled = true
        view.isUserInteractionEnabled = true
    }
    
    public var panScrollable: UIScrollView? {
        return nil
    }
    
    public var longFormHeight: PanModalHeight {
        return .maxHeight
    }

    public var anchorModalToLongForm: Bool {
        return true
    }

    public var shouldRoundTopCorners: Bool {
        return true
    }

    public func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        true
    }

    @objc private func keyboardWillAppear(_ notification: Notification) {
        guard let frameEnd = notification.userInfo?[NotificationKeyboardFrameEndUserInfoKey] as? CGRect,
              let frameStart = notification.userInfo?[NotificationKeyboardFrameBeginUserInfoKey] as? CGRect,
              frameEnd != frameStart else {
                  return
              }

        let intersectedFrame = contentView.convert(frameEnd, from: nil)
        contentView.contentInset.bottom = intersectedFrame.height

        let bottomScrollIndicatorInset: CGFloat
        if #available(iOS 11.0, *) {
            bottomScrollIndicatorInset = intersectedFrame.height - contentView.safeAreaInsets.bottom
        } else {
            bottomScrollIndicatorInset = intersectedFrame.height
        }

        contentView.contentInset.bottom = bottomScrollIndicatorInset
        contentView.scrollIndicatorInsets.bottom = bottomScrollIndicatorInset
    }
    
    @objc func keyboardWillChangeFrame(_ notification: NSNotification) {
        let keyboardsize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        guard let activeTextField = currentEditingTextField, let keyboardHeight = keyboardsize?.height else{
            return
        }

        let bottomScrollIndicatorInset: CGFloat
        if #available(iOS 11.0, *) {
            bottomScrollIndicatorInset = (keyboardHeight + activeTextField.frame.height) - contentView.safeAreaInsets.bottom
        } else {
            bottomScrollIndicatorInset = keyboardHeight + activeTextField.frame.height
        }
        contentView.contentInset.bottom = bottomScrollIndicatorInset
        contentView.scrollIndicatorInsets.bottom = bottomScrollIndicatorInset
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        contentView.contentInset.bottom = 0.0
        contentView.scrollIndicatorInsets.bottom = 0.0
    }
    
}

extension CreditCardViewController {
    
    @objc private func saveCardSwitchChanged() {
        result.setSaveCardState(saveCard: switchButton.isOn)
        didSaveCardStateChanged?(switchButton.isOn)
    }
    
    @objc private func encryptCard() {
        doneEditing(nil)
        startActivityIndicator()
        UIAccessibility.post(notification: AccessibilityNotificationAnnouncement, argument: "Encrypt card data")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let iso8601String = dateFormatter.string(from: Date()) + "Z"
        let cardData = CardEncryption(publicKey: paymentConfiguration.cardEncryptionPublicKey,
                                      cardData: EncryptedData(cardNumber: cardFormNumberTextField.text!,
                                                              expiryMonth: cardFormExpiryDateTextField.selectedMonth ?? 0,
                                                              expiryYear: cardFormExpiryDateTextField.selectedYear ?? 0,
                                                              cvv: cvcTextField.text ?? "",
                                                              captureTime: iso8601String))
        cardData.getEncryptedData { [weak self] cardEncryptionResult in
            self?.result.cardBrand = self?.cardFormNumberTextField.panNumber.brand!.getName()!.uppercased()
            self?.result.cardData = ""
            self?.result.cardHolder = self?.cardFormNameTextField.text
            switch cardEncryptionResult {
            case let .success(cardData):
                self?.result.cardData = cardData
                if let delegate = self?.delegate {
                    delegate.creditCardFormViewControllerDidCardEncrypted(self!, result: self!.result)
                } else if let delegate = self?.__delegate {
                    delegate.creditCardFormViewControllerDidCardEncrypted(self!, result: self!.result)
                }
                
            case let .failure(error):
                self?.result = VerifoneFormResult(error: error)
                if let delegate = self?.delegate {
                    delegate.creditCardFormViewControllerDidCardEncrypted(self!, result: self!.result)
                } else if let delegate = self?.__delegate {
                    delegate.creditCardFormViewControllerDidCardEncrypted(self!, result: self!.result)
                }
            }
            
            DispatchQueue.main.async {
                self!.stopActivityIndicator()
            }
        }
    }
    
    private func validationErrorText(for textField: UITextField, error: Error) -> String {
        switch (error, textField) {
        case (VFTextFieldValidationError.emptyText, _):
            return "-"
        case (VFTextFieldValidationError.invalidData, cardFormNumberTextField):
            return "nrNotValid".localized(withComment: "Credit card number is invalid")
        case (VFTextFieldValidationError.invalidData, cardFormNameTextField):
            return "cardHolderNameInvalid".localized()
        case (VFTextFieldValidationError.invalidData, cardFormExpiryDateTextField):
            return "cardExpiryDateFormat".localized(withComment: "Card expiry date is invalid")
        case (VFTextFieldValidationError.invalidData, cvcTextField):
            return "cvvNotValid".localized(withComment: "CVV code is invalid")

        case (_, cardFormNumberTextField),
            (_, cardFormNameTextField),
            (_, cardFormExpiryDateTextField),
            (_, cvcTextField):
            return error.localizedDescription
        default:
            return "-"
        }
    }
}

// MARK: - Fields Accessory methods
extension CreditCardViewController {
    
    @IBAction private func validateTextFieldDataOf(_ sender: BaseTextField) {
        let duration = TimeInterval(UINavigationController.hideShowBarDuration)
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState, .layoutSubviews]) {
            self.validateField(sender)
        }
        sender.borderColor = .gray
    }
    
    @IBAction private func updateInputAccessoryViewFor(_ sender: BaseTextField) {
        if let errorLabel = setCardInputErrorFor(sender) {
            let duration = TimeInterval(UINavigationController.hideShowBarDuration)
            UIView.animate(withDuration: duration,
                           delay: 0.0,
                           options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState, .layoutSubviews]) {
                errorLabel.alpha = 0.0
            }
        }

        sender.borderColor = view.tintColor
        updateInputAccessoryViewWithFirstResponder(sender)
    }
    
    @IBAction private func gotoPreviousField(_ button: UIBarButtonItem) {
        gotoPreviousField()
    }
    
    @IBAction private func gotoNextField(_ button: UIBarButtonItem) {
        gotoNextField()
    }
    
    @IBAction private func doneEditing(_ button: UIBarButtonItem?) {
        doneEditing()
    }
}

// MARK: - Accessibility
extension CreditCardViewController {
    
    @IBAction private func updateAccessibilityValue(_ sender: BaseTextField) {
        updateCardBrand()
    }
    
    private func setConfigAccessibility() {
        cardFormLabels.forEach {
            $0.adjustsFontForContentSizeCategory = true
        }
        cardFormInputFields.forEach {
            $0.adjustsFontForContentSizeCategory = true
        }

        confirmButton.titleLabel?.adjustsFontForContentSizeCategory = true

        let inputFields = [
            cardFormNumberTextField,
            cardFormNameTextField,
            cardFormExpiryDateTextField,
            cvcTextField
        ] as [BaseTextField]

        func accessiblityElementAfter(
            _ element: NSObjectProtocol?,
            matchingPredicate predicate: (BaseTextField) -> Bool,
            direction: AccessibilityCustomRotorDirection
        ) -> NSObjectProtocol? {
            guard let element = element else {
                switch direction {
                case .previous:
                    return inputFields.reversed().first(where: predicate)?.accessibilityElements?.last as? NSObjectProtocol
                    ?? inputFields.reversed().first(where: predicate)
                case .next:
                    fallthrough
                @unknown default:
                    return inputFields.first(where: predicate)?.accessibilityElements?.first as? NSObjectProtocol
                    ?? inputFields.first(where: predicate)
                }
            }

            let fieldOfElement = inputFields.first { field in
                guard let accessibilityElements = field.accessibilityElements as? [NSObjectProtocol] else {
                    return element === field
                }

                return accessibilityElements.contains { $0 === element }
            } ?? cardFormNameTextField

            func filedAfter(
                _ field: BaseTextField,
                matchingPredicate predicate: (BaseTextField) -> Bool,
                direction: AccessibilityCustomRotorDirection
            ) -> BaseTextField? {
                guard let indexOfField = inputFields.firstIndex(of: field) else { return nil }
                switch direction {
                case .previous:
                    return inputFields[inputFields.startIndex..<indexOfField].reversed().first(where: predicate)
                case .next: fallthrough
                @unknown default:
                    return inputFields[inputFields.index(after: indexOfField)...].first(where: predicate)
                }
            }

            let nextField = filedAfter(fieldOfElement, matchingPredicate: predicate, direction: direction)

            guard let currentAccessibilityElements = (fieldOfElement.accessibilityElements as? [NSObjectProtocol]),
                  let indexOfAccessibilityElement = currentAccessibilityElements.firstIndex(where: { $0 === element }) else {
                      switch direction {
                      case .previous:
                          return nextField?.accessibilityElements?.last as? NSObjectProtocol ?? nextField
                      case .next:
                          fallthrough
                      @unknown default:
                          return nextField?.accessibilityElements?.first as? NSObjectProtocol ?? nextField
                      }
                  }

            switch direction {
            case .previous:
                if predicate(fieldOfElement) && indexOfAccessibilityElement > currentAccessibilityElements.startIndex {
                    return currentAccessibilityElements[currentAccessibilityElements.index(before: indexOfAccessibilityElement)]
                } else {
                    return nextField?.accessibilityElements?.last as? NSObjectProtocol ?? nextField
                }
            case .next:
                fallthrough
            @unknown default:
                if predicate(fieldOfElement) && indexOfAccessibilityElement < currentAccessibilityElements.endIndex - 1 {
                    return currentAccessibilityElements[currentAccessibilityElements.index(after: indexOfAccessibilityElement)]
                } else {
                    return nextField?.accessibilityElements?.first as? NSObjectProtocol ?? nextField
                }
            }
        }

        accessibilityCustomRotors = [
            UIAccessibilityCustomRotor(name: "Fields") { (predicate) -> UIAccessibilityCustomRotorItemResult? in
                return accessiblityElementAfter(predicate.currentItem.targetElement,
                                                matchingPredicate: { _ in true },
                                                direction: predicate.searchDirection)
                    .map { UIAccessibilityCustomRotorItemResult(targetElement: $0, targetRange: nil) }
            },
            UIAccessibilityCustomRotor(name: "Invalid Data Fields") { (predicate) -> UIAccessibilityCustomRotorItemResult? in
                return accessiblityElementAfter(predicate.currentItem.targetElement,
                                                matchingPredicate: { !$0.isValid },
                                                direction: predicate.searchDirection)
                    .map { UIAccessibilityCustomRotorItemResult(targetElement: $0, targetRange: nil) }
            }
        ]
    }
    
    public override func accessibilityPerformMagicTap() -> Bool {
        guard isCardInputDataValid else {
            return false
        }
        encryptCard()
        return true
    }

    public override func accessibilityPerformEscape() -> Bool {
        return cancelCardForm()
    }

}

// MARK: - Setup constraints
extension CreditCardViewController {
    func createViews() {
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(contentView)

        self.contentView.addSubview(cardBrandImageView)
        
        self.contentView.addSubview(titleCardForm)
        self.contentView.addSubview(closeButton)
        
        self.contentView.addSubview(cardFormNumberLabel)
        self.contentView.addSubview(cardFormNameLabel)
        self.contentView.addSubview(cardFormExpiryDateLabel)
        self.contentView.addSubview(cvcLabel)
        
        self.contentView.addSubview(cardFormNumberTextField)
        self.contentView.addSubview(cardFormNameTextField)
        self.contentView.addSubview(cardFormExpiryDateTextField)
        self.contentView.addSubview(cvcTextField)

        self.contentView.addSubview(cardNumberErrorLabel)
        self.contentView.addSubview(cardHolderNameErrorLabel)
        self.contentView.addSubview(cardExpiryDateErrorLabel)
        self.contentView.addSubview(cardCVCErrorLabel)
        
        titleCardForm.text = "cardTitle".localized()
        closeButton.tintColor = UIColor.VF.label
        closeButton.setImage(UIImage(named: "Close", in:.module, compatibleWith: nil), for: .normal)
        verifoneLogo.contentMode = UIView.ContentMode.scaleAspectFit
        lockImage.contentMode = UIView.ContentMode.scaleAspectFit
        
        footerText.text = "footerText".localized()
        footerText.textColor = UIColor.VF.footerText
        
        cardFormNumberLabel.text = "cardNumberLabel".localized()
        cardFormExpiryDateLabel.text = "cardExpiryLabel".localized()
        cvcLabel.text = "cvvLabel".localized()
        cardFormNameLabel.text = "customerText".localized()
        
        switchButtonLabel.text = "switchButtonText".localized(withComment: "Save details for next time")
        
        confirmButton.setTitle("\("submitPay".localized()) \(self.paymentConfiguration.totalAmount > 0 ? "$\(self.paymentConfiguration.totalAmount)" : "")", for: .normal)
        confirmButton.cornerRadius = 3
        cardFormExpiryDateTextField.placeholder = "expiryPlaceholder".localized()
        
        // set label color
        cardFormNumberLabel.textColor = UIColor.VF.cardFormLabel
        cardFormExpiryDateLabel.textColor = UIColor.VF.cardFormLabel
        cvcLabel.textColor = UIColor.VF.cardFormLabel
        cardFormNameLabel.textColor = UIColor.VF.cardFormLabel
        switchButtonLabel.textColor = UIColor.VF.cardFormLabel
        
        // set font
        cardFormNumberLabel.font = UIFont(name: theme.font.familyName, size: 15)
        cardFormNameLabel.font = UIFont(name: theme.font.familyName, size: 15)
        cardFormExpiryDateLabel.font = UIFont(name: theme.font.familyName, size: 15)
        cvcLabel.font = UIFont(name: theme.font.familyName, size: 15)
        footerText.font = UIFont(name: theme.font.familyName, size: 10)
        
        switchButtonLabel.font = UIFont(name: theme.font.familyName, size: 16)
        titleCardForm.font = UIFont(name: "\(theme.font.familyName)", size: 17.0)
        confirmButton.titleLabel?.font = UIFont(name: theme.font.familyName, size: 17)
        
        cardFormNumberTextField.font = UIFont(name: theme.font.familyName, size: 13)
        cardFormNameTextField.font = UIFont(name: theme.font.familyName, size: 13)
        cardFormExpiryDateTextField.font = UIFont(name: theme.font.familyName, size: 13)
        cvcTextField.font = UIFont(name: theme.font.familyName, size: 13)
        
        cardNumberErrorLabel.font = UIFont(name: theme.font.familyName, size: 12)
        cardHolderNameErrorLabel.font = UIFont(name: theme.font.familyName, size: 12)
        cardExpiryDateErrorLabel.font = UIFont(name: theme.font.familyName, size: 12)
        cardCVCErrorLabel.font = UIFont(name: theme.font.familyName, size: 12)
        
        cardFormNameTextField.textContentType = UITextContentType.name
        cardFormNameTextField.autocapitalizationType = UITextAutocapitalizationType.words
        cardFormNameTextField.autocorrectionType = UITextAutocorrectionType.no
        cardFormNumberTextField.textContentType = UITextContentType.creditCardNumber
        cardFormExpiryDateTextField.autocapitalizationType = UITextAutocapitalizationType.none
        cardFormExpiryDateTextField.keyboardType = UIKeyboardType.numberPad
        cvcTextField.autocapitalizationType = UITextAutocapitalizationType.none
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
//        errorBannerView.translatesAutoresizingMaskIntoConstraints = false
        titleCardForm.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        verifoneLogo.translatesAutoresizingMaskIntoConstraints = false
        footerText.translatesAutoresizingMaskIntoConstraints = false
        
        cardFormNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        cardFormNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardFormExpiryDateLabel.translatesAutoresizingMaskIntoConstraints = false
        cvcLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardFormNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        cardFormNameTextField.translatesAutoresizingMaskIntoConstraints = false
        cardFormExpiryDateTextField.translatesAutoresizingMaskIntoConstraints = false
        cvcTextField.translatesAutoresizingMaskIntoConstraints = false

        cardNumberErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        cardHolderNameErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        cardExpiryDateErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        cardCVCErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.backgroundColor = UIColor.VF.formButton
        
        // HTOPStack View for title and close button
        let hTopStackView   = UIStackView()
        hTopStackView.axis  = NSLayoutConstraint.Axis.horizontal
        hTopStackView.distribution  = UIStackView.Distribution.equalSpacing
        hTopStackView.alignment = UIStackView.Alignment.center
        hTopStackView.layoutMargins = UIEdgeInsets(top: 0, left: edgeInsets.left, bottom: 0, right: 10.0)
        hTopStackView.isLayoutMarginsRelativeArrangement = true
        
        hTopStackView.addArrangedSubview(titleCardForm)
        hTopStackView.addArrangedSubview(closeButton)
        hTopStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // HBottomStack view for switch button
        hBottomStackView.axis   = NSLayoutConstraint.Axis.horizontal
        hBottomStackView.distribution  = UIStackView.Distribution.fill
        hBottomStackView.alignment = UIStackView.Alignment.center
        hBottomStackView.spacing   = 20.0
        hBottomStackView.layoutMargins = UIEdgeInsets(top: 0, left: edgeInsets.left, bottom: 0, right: 10.0)
        hBottomStackView.isLayoutMarginsRelativeArrangement = true
        
        hBottomStackView.addArrangedSubview(switchButtonLabel)
        hBottomStackView.addArrangedSubview(switchButton)
        hBottomStackView.translatesAutoresizingMaskIntoConstraints = false
        requestingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(hTopStackView)
        if (paymentConfiguration.showCardSaveSwitch) {
            self.contentView.addSubview(hBottomStackView)
        }
        self.contentView.addSubview(confirmButton)
        self.confirmButton.addSubview(requestingIndicatorView)
        
        let hFooterStackView   = UIStackView()
        hFooterStackView.axis  = NSLayoutConstraint.Axis.horizontal
        hFooterStackView.distribution  = UIStackView.Distribution.fill
        hFooterStackView.alignment = UIStackView.Alignment.center
        hFooterStackView.spacing = 3
        hFooterStackView.isLayoutMarginsRelativeArrangement = true
        
        
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let spacerViewRight = UIView()
        spacerViewRight.setContentHuggingPriority(.defaultLow, for: .horizontal)
        hFooterStackView.addArrangedSubview(spacerView)
        hFooterStackView.addArrangedSubview(lockImage)
        hFooterStackView.addArrangedSubview(footerText)
        hFooterStackView.addArrangedSubview(verifoneLogo)
        hFooterStackView.addArrangedSubview(spacerViewRight)
        hFooterStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(hFooterStackView)
        
        
        self.view.addConstraints([
            NSLayoutConstraint(item: titleCardForm, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 145),
            NSLayoutConstraint(item: closeButton, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40),
        ])
        titleCardForm.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10.0).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10.0).isActive = true
        
        // set footer views
        lockImage.centerYAnchor.constraint(equalTo: hFooterStackView.centerYAnchor).isActive = true
        verifoneLogo.centerYAnchor.constraint(equalTo: hFooterStackView.centerYAnchor).isActive = true
        footerText.centerYAnchor.constraint(equalTo: hFooterStackView.centerYAnchor).isActive = true
        self.view.addConstraints([
            NSLayoutConstraint(item: lockImage, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: lockImage, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: verifoneLogo, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: verifoneLogo, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 50),
        ])
        
        self.view.addConstraints([
            NSLayoutConstraint(item: contentView!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .topMargin, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: contentView!, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: contentView!, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: contentView!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0),
        ])
        self.contentView.contentLayoutGuide.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0).isActive = true
        
        // constraints for top stack view
        self.view.addConstraints([
            NSLayoutConstraint(item: hTopStackView, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: hTopStackView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 35),
        ])
        hTopStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left).isActive = true
        hTopStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -edgeInsets.right).isActive = true
        
        // card number label
        self.view.addConstraints([
            NSLayoutConstraint(item: cardFormNumberLabel, attribute: .top, relatedBy: .equal, toItem: hTopStackView, attribute: .bottom, multiplier: 1.0, constant: 15.0),
        ])
        cardFormNumberLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left).isActive = true
        cardFormNumberLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -edgeInsets.right).isActive = true
        
        // card form number
        self.view.addConstraints([
            NSLayoutConstraint(item: cardFormNumberTextField, attribute: .top, relatedBy: .equal, toItem: cardFormNumberLabel, attribute: .bottom, multiplier: 1.0, constant: 6.0),
            NSLayoutConstraint(item: cardFormNumberTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40),
        ])
        cardFormNumberTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left).isActive = true
        cardFormNumberTextField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -edgeInsets.right).isActive = true
        
//         card form number error label
        self.view.addConstraints([
            NSLayoutConstraint(item: cardNumberErrorLabel, attribute: .top, relatedBy: .equal, toItem: cardFormNumberTextField, attribute: .bottom, multiplier: 1.0, constant: 6.0),
        ])
        cardNumberErrorLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left).isActive = true
        cardNumberErrorLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -edgeInsets.right).isActive = true

        // card form expire label
        self.view.addConstraints([
            NSLayoutConstraint(item: cardFormExpiryDateLabel, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: cardFormNumberTextField, attribute: .bottom, multiplier: 1.0, constant: 25.0),
        ])
        cardFormExpiryDateLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left).isActive = true

        // card form card expire textfield
        self.view.addConstraints([
            NSLayoutConstraint(item: cardFormExpiryDateTextField, attribute: .top, relatedBy: .equal, toItem: cardFormExpiryDateLabel, attribute: .bottom, multiplier: 1.0, constant: 6.0),
            NSLayoutConstraint(item: cardFormExpiryDateTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40),
        ])
        cardFormExpiryDateTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left).isActive = true

        // card form expire error label
        self.view.addConstraints([
            NSLayoutConstraint(item: cardExpiryDateErrorLabel, attribute: .top, relatedBy: .equal, toItem: cardFormExpiryDateTextField, attribute: .bottom, multiplier: 1.0, constant: 6.0),
        ])
        cardExpiryDateErrorLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left).isActive = true


        // card form cvc label
        self.view.addConstraints([
            NSLayoutConstraint(item: cvcLabel, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: cardFormNumberTextField, attribute: .bottom, multiplier: 1.0, constant: 25.0),
            NSLayoutConstraint(item: cvcLabel, attribute: .leading, relatedBy: .equal, toItem: cvcTextField, attribute: .leading, multiplier: 1.0, constant: 0.0),
        ])

        // card form card cvc textfield
        self.view.addConstraints([
            NSLayoutConstraint(item: cvcTextField, attribute: .top, relatedBy: .equal, toItem: cvcLabel, attribute: .bottom, multiplier: 1.0, constant: 6.0),
            NSLayoutConstraint(item: cvcTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40),
        ])
        cvcTextField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -edgeInsets.right).isActive = true

        // card form cvc error label
        self.view.addConstraints([
            NSLayoutConstraint(item: cardCVCErrorLabel, attribute: .top, relatedBy: .equal, toItem: cvcTextField, attribute: .bottom, multiplier: 1.0, constant: 6.0),
            NSLayoutConstraint(item: cardCVCErrorLabel, attribute: .leading, relatedBy: .equal, toItem: cvcTextField, attribute: .leading, multiplier: 1.0, constant: 0.0),
        ])

        // card form cvc and expire date width, space between
        self.view.addConstraints([
            NSLayoutConstraint(item: cardFormExpiryDateTextField, attribute: .width, relatedBy: .equal, toItem: cvcTextField, attribute: .width, multiplier: 1, constant: 6.0),
            NSLayoutConstraint(item: cardFormExpiryDateTextField, attribute: .trailing, relatedBy: .equal, toItem: cvcTextField, attribute: .leading, multiplier: 1.0, constant: -40)
        ])

        self.view.addConstraints([
            NSLayoutConstraint(item: cardFormNameLabel, attribute: .top, relatedBy: .equal, toItem: cardFormExpiryDateTextField, attribute: .bottom, multiplier: 1.0, constant: 25.0),
        ])
        cardFormNameLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left).isActive = true

        self.view.addConstraints([
            NSLayoutConstraint(item: cardFormNameTextField, attribute: .top, relatedBy: .equal, toItem: cardFormNameLabel, attribute: .bottom, multiplier: 1.0, constant: 6.0),
            NSLayoutConstraint(item: cardFormNameTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40),
        ])
        cardFormNameTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left).isActive = true
        cardFormNameTextField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -edgeInsets.right).isActive = true

        // card form cvc error label
        self.view.addConstraints([
            NSLayoutConstraint(item: cardHolderNameErrorLabel, attribute: .top, relatedBy: .equal, toItem: cardFormNameTextField, attribute: .bottom, multiplier: 1.0, constant: 6.0),
        ])
        cardHolderNameErrorLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left).isActive = true
        cardHolderNameErrorLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -edgeInsets.right).isActive = true

        // constraints for bottom stack view
        if (paymentConfiguration.showCardSaveSwitch) {
            self.view.addConstraints([
                NSLayoutConstraint(item: hBottomStackView, attribute: .top, relatedBy: .equal, toItem: cardFormNameTextField, attribute: .bottom, multiplier: 1.0, constant: 20.0),
                NSLayoutConstraint(item: hBottomStackView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40),
                NSLayoutConstraint(item: confirmButton, attribute: .top, relatedBy: .equal, toItem: hBottomStackView, attribute: .bottom, multiplier: 1.0, constant: 20.0),
            ])
            hBottomStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0.0).isActive = true
            hBottomStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -7).isActive = true
        } else {
            self.view.addConstraint(NSLayoutConstraint(item: confirmButton, attribute: .top, relatedBy: .equal, toItem: cardHolderNameErrorLabel, attribute: .bottom, multiplier: 1.0, constant: 30.0))
        }

        // constraints for confirm button
        self.view.addConstraints([
            NSLayoutConstraint(item: confirmButton, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 44)
        ])
        confirmButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -edgeInsets.right).isActive = true


        self.view.addConstraints([
            NSLayoutConstraint(item: requestingIndicatorView!, attribute: .centerX, relatedBy: .equal, toItem: confirmButton, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: requestingIndicatorView!, attribute: .centerY, relatedBy: .equal, toItem: confirmButton, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ])

        // constraints for top stack view
        self.view.addConstraints([
            NSLayoutConstraint(item: hFooterStackView, attribute: .top, relatedBy: .equal, toItem: self.confirmButton, attribute: .bottom, multiplier: 1.0, constant: 5.0),
            NSLayoutConstraint(item: hFooterStackView, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: -30.0),
            NSLayoutConstraint(item: hFooterStackView, attribute: .centerX, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerX, multiplier: 1, constant: 0)
        ])
    }
}
