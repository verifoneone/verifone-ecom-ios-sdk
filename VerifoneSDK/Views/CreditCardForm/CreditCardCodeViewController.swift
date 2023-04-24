//
//  CreditCardViewController.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 22.11.2021.
//

import UIKit

public protocol CreditCardFormViewControllerDelegate: AnyObject {
    func creditCardFormViewControllerDidCardEncrypted(_ controller: CreditCardViewController, result: VerifoneFormResult)
    func creditCardFormViewControllerDidCancel(_ controller: CreditCardViewController, callback: CallbackStatus)
}

public class CreditCardViewController: UIViewController, UITextFieldDelegate {

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
    private var cardFormExpiryDateLabel: UILabel = UILabel(frame: .zero)
    private var cvcLabel: UILabel = UILabel(frame: .zero)

    private var cardFormNumberTextField: CardFormNumberTextField = CardFormNumberTextField(frame: .zero)
    private var cardFormExpiryDateTextField: CardFormExpiryDateTextField = CardFormExpiryDateTextField(frame: .zero)
    private var cvcTextField: CVVTextField = CVVTextField(frame: .zero)

    var gotoPreviousFieldBarButtonItem: UIBarButtonItem!
    var gotoNextFieldBarButtonItem: UIBarButtonItem! = UIBarButtonItem()
    var doneEditingBarButtonItem: UIBarButtonItem! = UIBarButtonItem()

    private var cardNumberErrorLabel: UILabel = UILabel(frame: .zero)
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
    private var edgeInsets = UIEdgeInsets(top: 0, left: 15.0, bottom: 0.0, right: -15.0)

    var confirmButton: FormButton = FormButton(frame: .zero)
    lazy var formFieldsAccessoryView: UIToolbar = {
        let formFieldsAccessoryView = UIToolbar()
        formFieldsAccessoryView.barStyle = .default
        formFieldsAccessoryView.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(CreditCardViewController.doneEditing(_:)))
        let flexibleSpaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)

        gotoPreviousFieldBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Back", in: .module, compatibleWith: nil)!,
            style: UIBarButtonItem.Style.plain, target: self,
            action: #selector(CreditCardViewController.gotoPreviousField(_:)))
        gotoNextFieldBarButtonItem.width = 50.0
        gotoNextFieldBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Next Field", in: .module, compatibleWith: nil)!,
            style: UIBarButtonItem.Style.plain, target: self,
            action: #selector(CreditCardViewController.gotoNextField(_:)))

        formFieldsAccessoryView.setItems([fixedSpaceButton,   gotoPreviousFieldBarButtonItem, fixedSpaceButton, gotoNextFieldBarButtonItem, flexibleSpaceButton, doneButton], animated: false)
        return formFieldsAccessoryView
    }()

    public var paymentConfiguration: VerifoneSDK.PaymentConfiguration!
    public weak var delegate: CreditCardFormViewControllerDelegate?

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
        cardFormInputFields.forEach {
            $0.invalidateIntrinsicContentSize()
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
                               cvcTextField]
        cardFormLabels = [cardFormNumberLabel,
                          cardFormExpiryDateLabel,
                          cvcLabel]
        cardFormErrorLabels = [cardNumberErrorLabel,
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
        delegate?.creditCardFormViewControllerDidCancel(self, callback: .cancel)
        debugPrint("cancel form")
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
        var cvcInfoIconName: String?
        if cardFormNumberTextField.cardBrand == "AMEX" {
            cvcInfoIconName = "CVV AMEX"
        } else if cardFormNumberTextField.cardBrand != nil {
            cvcInfoIconName = "CVV"
        }

        cardBrandImageView.image = cardBrandIconName.flatMap { UIImage(named: $0, in: .module, compatibleWith: nil) }
        cvcInfoImageView.image = cvcInfoIconName.flatMap { UIImage(named: $0, in: .module, compatibleWith: nil)}
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
            self?.result.cardBrand = self?.cardFormNumberTextField.cardBrand!.uppercased()
            self?.result.cardData = ""
            switch cardEncryptionResult {
            case let .success(cardData):
                self?.result.cardData = cardData
                self?.delegate?.creditCardFormViewControllerDidCardEncrypted(self!, result: self!.result)

            case let .failure(error):
                self?.result = VerifoneFormResult(error: error)
                self?.delegate?.creditCardFormViewControllerDidCardEncrypted(self!, result: self!.result)
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
        case (VFTextFieldValidationError.invalidData, cardFormExpiryDateTextField):
            return "cardExpiryDateFormat".localized(withComment: "Card expiry date is invalid")
        case (VFTextFieldValidationError.invalidData, cvcTextField):
            return "cvvNotValid".localized(withComment: "CVV code is invalid")

        case (_, cardFormNumberTextField),
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
        sender.borderColor = theme.textfieldBorderColor
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

    public override func accessibilityPerformEscape() -> Bool {
        return cancelCardForm()
    }

}

// MARK: - Setup constraints
extension CreditCardViewController {
    // swiftlint: disable function_body_length
    func createViews() {

        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(contentView)

        self.contentView.addSubview(cardBrandImageView)

        self.contentView.addSubview(titleCardForm)
        self.contentView.addSubview(closeButton)

        self.contentView.addSubview(cardFormNumberLabel)
        self.contentView.addSubview(cardFormExpiryDateLabel)
        self.contentView.addSubview(cvcLabel)

        self.contentView.addSubview(cardFormNumberTextField)
        self.contentView.addSubview(cardFormExpiryDateTextField)
        self.contentView.addSubview(cvcTextField)

        self.contentView.addSubview(cardNumberErrorLabel)
        self.contentView.addSubview(cardExpiryDateErrorLabel)
        self.contentView.addSubview(cardCVCErrorLabel)

        titleCardForm.text = "cardTitle".localized()
        closeButton.tintColor = UIColor.VF.label
        closeButton.setImage(UIImage(named: "Close", in: .module, compatibleWith: nil), for: .normal)
        verifoneLogo.contentMode = UIView.ContentMode.scaleAspectFit
        lockImage.contentMode = UIView.ContentMode.scaleAspectFit

        footerText.text = "footerText".localized()
        footerText.textColor = UIColor.VF.footerText

        cardFormNumberLabel.text = "cardNumberLabel".localized()
        cardFormExpiryDateLabel.text = "cardExpiryLabel".localized()
        cvcLabel.text = "cvvLabel".localized()

        switchButtonLabel.text = "switchButtonText".localized(withComment: "Save details for next time")

        confirmButton.setTitle("\("submitPay".localized()) \(!self.paymentConfiguration.totalAmount.isEmpty ? "\(self.paymentConfiguration.totalAmount)" : "")", for: .normal)
        confirmButton.cornerRadius = 3
        cardFormExpiryDateTextField.placeholder = "expiryPlaceholder".localized()

        // SET LABEL COLOR
        cardFormNumberLabel.textColor = UIColor.VF.cardFormLabel
        cardFormExpiryDateLabel.textColor = UIColor.VF.cardFormLabel
        cvcLabel.textColor = UIColor.VF.cardFormLabel
        switchButtonLabel.textColor = UIColor.VF.cardFormLabel

        // SET FONT
        cardFormNumberLabel.font = UIFont(name: theme.font.familyName, size: 15)
        cardFormExpiryDateLabel.font = UIFont(name: theme.font.familyName, size: 15)
        cvcLabel.font = UIFont(name: theme.font.familyName, size: 15)
        footerText.font = UIFont(name: theme.font.familyName, size: 10)

        switchButtonLabel.font = UIFont(name: theme.font.familyName, size: 16)
        titleCardForm.font = UIFont(name: "\(theme.font.familyName)", size: 17.0)
        confirmButton.titleLabel?.font = UIFont(name: theme.font.familyName, size: 17)

        cardFormNumberTextField.font = UIFont(name: theme.font.familyName, size: 13)
        cardFormExpiryDateTextField.font = UIFont(name: theme.font.familyName, size: 13)
        cvcTextField.font = UIFont(name: theme.font.familyName, size: 13)

        cardNumberErrorLabel.font = UIFont(name: theme.font.familyName, size: 12)
        cardExpiryDateErrorLabel.font = UIFont(name: theme.font.familyName, size: 12)
        cardCVCErrorLabel.font = UIFont(name: theme.font.familyName, size: 12)

        cardFormNumberTextField.textContentType = UITextContentType.creditCardNumber
        cardFormExpiryDateTextField.autocapitalizationType = UITextAutocapitalizationType.none
        cardFormExpiryDateTextField.keyboardType = UIKeyboardType.numberPad
        cvcTextField.autocapitalizationType = UITextAutocapitalizationType.none

        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleCardForm.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        verifoneLogo.translatesAutoresizingMaskIntoConstraints = false
        footerText.translatesAutoresizingMaskIntoConstraints = false

        cardFormNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        cardFormExpiryDateLabel.translatesAutoresizingMaskIntoConstraints = false
        cvcLabel.translatesAutoresizingMaskIntoConstraints = false

        cardFormNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        cardFormExpiryDateTextField.translatesAutoresizingMaskIntoConstraints = false
        cvcTextField.translatesAutoresizingMaskIntoConstraints = false

        cardNumberErrorLabel.translatesAutoresizingMaskIntoConstraints = false
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
        if paymentConfiguration.showCardSaveSwitch {
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

        NSLayoutConstraint.activate([
            titleCardForm.widthAnchor.constraint(equalToConstant: 145),
            titleCardForm.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            // SET FOOTER VIEWS
            lockImage.centerYAnchor.constraint(equalTo: hFooterStackView.centerYAnchor, constant: 0),
            verifoneLogo.centerYAnchor.constraint(equalTo: hFooterStackView.centerYAnchor, constant: 0),
            footerText.centerYAnchor.constraint(equalTo: hFooterStackView.centerYAnchor, constant: 0)
        ])

        NSLayoutConstraint.activate([
            lockImage.widthAnchor.constraint(equalToConstant: 10.0),
            lockImage.heightAnchor.constraint(equalToConstant: 10.0),
            verifoneLogo.heightAnchor.constraint(equalToConstant: 30.0),
            verifoneLogo.widthAnchor.constraint(equalToConstant: 50.0)
        ])

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
            contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0),
            contentView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0),
            contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
            contentView.contentLayoutGuide.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0.0)
        ])

        // SET CONSTRAINTS TO TOP STACK VIEW
        NSLayoutConstraint.activate([
            hTopStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10.0),
            hTopStackView.heightAnchor.constraint(equalToConstant: 35),
            hTopStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            hTopStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: edgeInsets.right)
        ])

        // CARD FORM NUMBER INPUT
        NSLayoutConstraint.activate([
            cardFormNumberLabel.topAnchor.constraint(equalTo: hTopStackView.bottomAnchor, constant: 15.0),
            cardFormNumberLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            cardFormNumberLabel.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: edgeInsets.right),
            // CARD NUMBER TEXTFIELD
            cardFormNumberTextField.topAnchor.constraint(equalTo: cardFormNumberLabel.bottomAnchor, constant: 6.0),
            cardFormNumberTextField.heightAnchor.constraint(equalToConstant: 40),
            cardFormNumberTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            cardFormNumberTextField.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: edgeInsets.right),
            // CARD NUMBER ERROR LABEL
            cardNumberErrorLabel.topAnchor.constraint(equalTo: cardFormNumberTextField.bottomAnchor, constant: 6.0),
            cardNumberErrorLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            cardNumberErrorLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: edgeInsets.right)
        ])

        // CARD FORM EXPIRE INPUT
        NSLayoutConstraint.activate([
            cardFormExpiryDateLabel.topAnchor.constraint(equalTo: cardFormNumberTextField.bottomAnchor, constant: 25.0),
            cardFormExpiryDateLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            // CARD EXPIRE TEXTFIELD
            cardFormExpiryDateTextField.topAnchor.constraint(equalTo: cardFormExpiryDateLabel.bottomAnchor, constant: 6.0),
            cardFormExpiryDateTextField.heightAnchor.constraint(equalToConstant: 40.0),
            cardFormExpiryDateTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            // CARD EXPIRE ERROR LABEL
            cardExpiryDateErrorLabel.topAnchor.constraint(equalTo: cardFormExpiryDateTextField.bottomAnchor, constant: 6.0),
            cardExpiryDateErrorLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left)
        ])

        // CARD FORM CVC INPUT
        NSLayoutConstraint.activate([
            cvcLabel.topAnchor.constraint(equalTo: cardFormNumberTextField.bottomAnchor, constant: 25.0),
            cvcLabel.leadingAnchor.constraint(equalTo: cvcTextField.leadingAnchor, constant: edgeInsets.left),
            // CARD CVC TEXTFIELD
            cvcTextField.topAnchor.constraint(equalTo: cvcLabel.bottomAnchor, constant: 6.0),
            cvcTextField.heightAnchor.constraint(equalToConstant: 40.0),
            cvcTextField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: edgeInsets.right),
            // CARD CVC ERROR LABEL
            cardCVCErrorLabel.topAnchor.constraint(equalTo: cvcTextField.bottomAnchor, constant: 6.0),
            cardCVCErrorLabel.leadingAnchor.constraint(equalTo: cvcTextField.leadingAnchor, constant: edgeInsets.left)
        ])

        // CARD FORM CVC AND EXPIRE WIDTH AND SPACE
        NSLayoutConstraint.activate([
            cardFormExpiryDateTextField.widthAnchor.constraint(equalTo: cvcTextField.widthAnchor, constant: 0.0),
            cardFormExpiryDateTextField.trailingAnchor.constraint(equalTo: cvcTextField.leadingAnchor, constant: -40)
        ])

        // BOTTOM STACKVIEW
        if paymentConfiguration.showCardSaveSwitch {
            NSLayoutConstraint.activate([
                hBottomStackView.topAnchor.constraint(equalTo: cvcTextField.bottomAnchor, constant: 20.0),
                hBottomStackView.heightAnchor.constraint(equalToConstant: 40.0),
                confirmButton.topAnchor.constraint(equalTo: hBottomStackView.bottomAnchor, constant: 20.0),
                hBottomStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0.0),
                hBottomStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -7)
            ])
        } else {
            NSLayoutConstraint.activate([
                confirmButton.topAnchor.constraint(equalTo: cvcTextField.bottomAnchor, constant: 30.0)
            ])
        }

        // CONFIRM BUTTON
        NSLayoutConstraint.activate([
            confirmButton.heightAnchor.constraint(equalToConstant: 44.0),
            confirmButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: edgeInsets.left),
            confirmButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: edgeInsets.right),

            requestingIndicatorView.centerXAnchor.constraint(equalTo: confirmButton.centerXAnchor, constant: 0.0),
            requestingIndicatorView.centerYAnchor.constraint(equalTo: confirmButton.centerYAnchor, constant: 0.0)
        ])

        // BOTTOM STACK VIEW
        NSLayoutConstraint.activate([
            hFooterStackView.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 5.0),
            hFooterStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -30.0),
            hFooterStackView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor, constant: 0.0)
        ])
    }
}
