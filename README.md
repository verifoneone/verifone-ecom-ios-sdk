# Verifone iOS SDK

Verifone SDKs provide the ability to encrypt and validate card payments, handles 3D Secure verification and interacts with alternative payment methods.

<img width="210" src="screens/1.png" /> <img width="210" src="screens/2.png" />     

### Requirements

- Xcode 10.2 or higher
- Swift 5.0 or higher

### Suppported Payment Methods

- Credit Cards (with 3D Secure support)
- Paypal
- Apple Pay
- Klarna
- Swish
- Vipps
- MobilePay


### Installation

VerifoneSDK is available through either CocoaPods and Carthage.

##### CocoaPods

1. Add the following line to your Podfile: `pod 'VerifoneSDK', :git => 'https://github.com/verifoneone/verifone-ecom-ios-sdk.git'`
2. Run `pod install`

##### Carthage

To integrate the VerifoneSDK into your Xcode project using Carthage, proceed with the following steps:

1. Add the following line to your Cartfile: `github "verifoneone/verifone-ecom-ios-sdk" "main"`
2. Run `carthage update --use-xcframeworks`
3. Link the frameworks with your target as described in [Carthage Readme](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).


### Usage

Required Parameters to setup the SDK.


```swift
let paymentConfiguration = VerifoneSDK.PaymentConfiguration(
 cardEncryptionPublicKey: "YOUR_CARD_ENCRYPTION_KEY",
 paymentPanelStoreTitle: "store_name", showCardSaveSwitch: "bool", allowedPaymentMethods: [.creditCard, .paypal, .applePay])

let billingAddress = PKContact()
let shippingAddress = PKContact()
let supportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard]
let requiredShippingContactFields: Set<PKContactField> = [.name, .emailAddress, .phoneNumber, .phoneticName, .postalAddress]
let requiredBillingContactFields: Set<PKContactField> = [.name, .emailAddress, .phoneNumber, .phoneticName, .postalAddress]

let applepayConfiguration = VerifoneSDK.ApplePayMerchantConfiguration(
    applePayMerchantId: "YOUR_MERCHANT_ID",
    supportedPaymentNetworks: [.amex, .discover, .visa, .masterCard], countryCode: "US", currencyCode: "USD", paymentSummaryItems: [PKPaymentSummaryItem(label: "Test Product", amount: 1.0)],
    requiredShippingContactFields: requiredShippingContactFields,
    requiredBillingContactFields: requiredBillingContactFields,
    supportedNetworks: supportedNetworks,
    billingContact: billingAddress,
    shippingContact: shippingAddress,
    shippingType: PKShippingType.delivery
)

let verifonePaymentForm = VerifonePaymentForm(paymentConfiguration: paymentConfiguration, applepayConfiguration: applepayConfiguration)

verifonePaymentForm.displayPaymentForm(from: self) { result in
            // handle result based on payment method selected by the customer
}
```


##### Transaction flow without threed secure.

A simple completion handler for encrypted card data looks like this. Here we will check ```verifoneResult.paymentMethodType``` which payment method was selected. 

If the customer selected credit card, the sdk will return the encrypted card data to perform transaction request to the merchant server.

If the customer selected PayPal, you will have to do a create transaction API call, and then pass to the sdk the "approvalUrl" and "id". The sdk will display the confirmation PaypPal screen inside a webview and provide you with the details necessary to perform the confirmation API call.

```swift
verifonePaymentForm.displayPaymentForm(from: self) { result in
                switch result {
                case .success(let verifoneResult):
                    switch verifoneResult.paymentMethodType {
                        case .creditCard:
                        print(verifoneResult)
                        // verifoneResult.cardData: String
                        // verifoneResult.cardBrand: String
                        // verifoneResult.cardHolder: String
                        // verifoneResult.saveCard: Bool
                        // You can then use the verifoneResult.cardData to make an encrypted card payment request or create a reuse token to create a transaction later.
                        // https://verifone.cloud/api-catalog/verifone-ecommerce-api#operation/saleTransaction
                        // https://verifone.cloud/api-catalog/verifone-ecommerce-api#operation/createUpdateToken
                        case .paypal:
                            print(verifoneResult)
                            // Verify that the payment was redirected to the expected URL
                            // and make an authorization API call.
                            // If the redirect URL is nil, make an API call to get the approval URL.
                            if (verifoneResult.paymentAuthorizingResult != nil) {
                                // verifoneResult.paymentAuthorizingResult.redirectedUrl: URL
                                // verifoneResult.paymentAuthorizingResult.queryStringDictionary: NSMutableDictionary
                                // You can then use the verifoneResult.paymentAuthorizingResult.queryStringDictionary to authorize or capture the transaction
                                // https://verifone.cloud/api-catalog/paypal-ecomm-api#operation/postTransactionsIdAuthorize
                                // https://verifone.cloud/api-catalog/paypal-ecomm-api#operation/postTransactionsIdCapture
                            } else {
                                // make the server side PayPal transaction API call
                                // https://verifone.cloud/api-catalog/paypal-ecomm-api#operation/postTransactions
                                let paypalUrl = URL(string: "paypal url returned from initiate API call")!
                                let expectedRedirectUrl = URLComponents(string: "https://verifone.cloud")!
                                let expectedCancelUrl = URLComponents(string: "https://verifone.cloud")!
                                PaymentAuthorizingWithURL.shared.load(webConfig: VFWebConfig(url: paypalUrl, expectedRedirectUrl: [expectedRedirectUrl], expectedCancelUrl: [expectedCancelUrl]))
                            }
                        case .applePay:
                            print(verifoneResult.paymentApplePayResult!.token.paymentData)
                            // make the server side wallet transaction API call using the 'token.paymentData' as the wallet payload
                            // https://verifone.cloud/api-catalog/verifone-ecommerce-api#operation/walletTransaction
                        case .klarna:
                            // make an API call to receive the client token
                            // https://verifone.cloud/api-catalog/verifone-ecommerce-api#tag/Ecom-Payments/operation/klarnaInitTransaction
                            // use the Klarna SDK to initialize the Klarna payment with received client token 
                            // https://docs.klarna.com/in-app/inapp-ios-overview/klarna-payments-native/
                            // after successful authorization, get an authorization token and complete the transaction by calling the API call
                            // https://verifone.cloud/api-catalog/verifone-ecommerce-api#tag/Payment-Modifications/operation/klarnaPaymentTransaction
                        case .swish:
                            // check the integration section of Swish
                            // make the server side Swish transaction API call
                            // https://verifone.cloud/api-catalog/verifone-ecommerce-api#tag/Ecom-Payments/operation/swishTransaction
                            // launch the wallet app with the token to authorize the payment
                            // get redirected to your app (merchant app)
                            // make an API call to check the status of the transaction
                        case .vipps:
                            // check the integration section of Vipps
                            // make the server side Swish transaction API call
                            // https://verifone.cloud/api-catalog/verifone-ecommerce-api#tag/Ecom-Payments/operation/vippsTransaction
                            // launch the wallet app with the token to authorize the payment
                            // get redirected to your app (merchant app)
                            // make an API call to check the status of the transaction
                        case .mobilePay:
                            // check the integration section of MobilePay
                            // make the server side Swish transaction API call
                            // https://verifone.cloud/api-catalog/verifone-ecommerce-api#tag/Ecom-Payments/operation/mobilePayTransaction
                            // launch the wallet app with the token to authorize the payment
                            // get redirected to your app (merchant app)
                            // make an API call to check the status of the transaction
                        default: break
                    }
                case .failure(let error):
                    let error = error as NSError?
                    // Here we can catch all possible errors
                    switch error {
                        case VerifoneError.cancel:
                            print("The form closed or cancelled by user")
                        case VerifoneError.invalidPublicKey
                            print("Missing card encryption public Key")
                        case VerifoneError.invalidCardData:
                            print("Required parameters are missing or invalid")
                        default:
                            print(error!)
                        }
                }            
}
```

### (Swish, Vipps, MobilePay) Integration
###### URL Schemes
In order to access wallet app (Siwsh, Vipps, MobilePay), you need to specify the app's scheme in the 'LSApplicationQueriesSchemes' section of the Info.plist file. This enables your app to communicate with the wallet app and authorize the transaction. 

Additionally, you should specify a custom URL for the payment app to redirect to once the process is finished. This can be done by adding it to the 'URL Types' array in the Info.plist file.
You can read more about the URL schemes on [https://developers.apple.com](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app)

###### Swish
```swift
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>swish</string>
</array>
```
###### Vipps
```swift
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>vipps</string>
    <string>vippsMT</string>
</array>
```
###### MobilePay
```swift
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>mobilepayonline</string>
    <string>mobilepay-test</string>
</array>
```

To ensure a smooth payment experience for your users, it is advisable to verify if they have the wallet app installed before continueing the payment process. VerifoneSDK class provides a convenient methods to accomplish this.
```swift
VerifoneSDK.isSwishAppAvailable()
VerifoneSDK.isVippsAppAvailable()
VerifoneSDK.isMobilePayAppAvailable()
```
###### Initiate a payment
Initiate a wallet transaction on the server side by making an API call to obtain a payment request token. Use the token to launch the wallet app for the user to authorize the payment. Once the user completes the payment, the wallet app will redirect back to your app, regardless of the success or failure of the transaction.

```swift
// SWISH
VerifoneSDK.authorizeSwishPayment(token: "token", returnUrl: "testAppUrl") { [weak self] in
    // make an API call to check the status of the transaction
    // https://verifone.cloud/api-catalog/verifone-ecommerce-api#tag/Transaction/operation/readTransaction
} failure: {
    // catch failure
}

// VIPPS
VerifoneSDK.authorizeVippsPayment(token: "token", returnUrl: "testAppUrl") { [weak self] in
    // make an API call to check the status of the transaction
    // https://verifone.cloud/api-catalog/verifone-ecommerce-api#tag/Transaction/operation/readTransaction
} failure: {
    // catch failure
}

// MOBILE PAY
VerifoneSDK.authorizeMobilePayPayment(token: "token", returnUrl: "testAppUrl") { [weak self] in
    // make an API call to check the status of the transaction
    // https://verifone.cloud/api-catalog/verifone-ecommerce-api#tag/Transaction/operation/readTransaction
} failure: {
    // catch failure
}
```

You can find an example of the entire payment flow, including the server-side transaction API call, launching the wallet app, and checking the transaction status, in [VerifoneSDK Example](https://github.com/verifoneone/verifone-ecom-ios-sdk/tree/main/VerifoneSDK%20Example).

##### Transaction flow with threed secure.

1. Initialize threeds manager.
2. Create the threeds JWT.
3. Use the JWT to setup the threeds, on completion threeds our sdk returns the device ID.
4. Use the device ID and encrypted card to perform lookup request.
5. Continue the threed secure authentication, using the payload and transaction ID returned from the lookup request.
6. If the authentication is successfull, we can validate the JWT and perform the transaction.

```swift
let verifoneThreedsManager = Verifone3DSecureManager(environment: Environment.sandbox) // use Environment.production for production

verifonePaymentForm.displayPaymentForm(from: self) { result in
                switch result {
                case .success(let verifoneResult):
                    switch verifoneResult.paymentMethodType {
                        case .creditCard:
                        print(verifoneResult)
                        // verifoneResult.cardData: String
                        // verifoneResult.cardBrand: String
                        // verifoneResult.cardHolder: String
                        // verifoneResult.saveCard: Bool
                        // Use the verifoneResult.cardData to make the JWT and lookup API calls
                        // https://verifone.cloud/api-catalog/3d-secure-api#operation/postV2JwtCreate
                        // https://verifone.cloud/api-catalog/3d-secure-api#operation/postV2Lookup
                        verifoneThreedsManager.setup(with: "jwt", completion: { deviceID in
                        // Set transaction id and payload parameters to continue session
                        verifoneThreedsManager.complete3DSecureValidation(with: "transaction_id", payload:"payload") { serverJwt in
                            // Validate authorization and request transaction.
                        } didFailed: {
                            // Handle failure
                        }
                    }, failure: { cardinalResponse in
                        // Handle cardinal setup failure.
                    })
                    }
                case .failure(let error):
                    let error = error as NSError?
                    // Here we can catch all possible errors
                    switch error {
                        case VerifoneError.cancel:
                            print("The form closed or cancelled by user")
                        case VerifoneError.invalidCardData:
                            print("Missing card encryption public Key")
                        default:
                            print(error!)
                        }
                }            
}
```

##### Card Encryption without UI

```swift

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
let iso8601String = dateFormatter.string(from: Date()) + "Z"

let encryptedData = EncryptedData(cardNumber: "4111111111111111",
                                                expiryMonth: 12,
                                                expiryYear: 25,
                                                cvv: "123",
                                                captureTime: iso8601String
   
let cardData = CardEncryption(publicKey: "YOUR_PUBLIC_ENCRYPTION_KEY", cardData: encryptedData)
              cardData.getEncryptedData { cardEncryptionResult in
                  switch cardEncryptionResult {
                  case let .success(_):
                      print(cardEncryptionResult)

                  case let .failure(error):
                      print(error)
                  }
              }

```

##### Gift Card Encryption

```swift

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
let iso8601String = dateFormatter.string(from: Date()) + "Z"

let encryptedData = EncryptedData(cardNumber: "4111111111111111111",
                                    captureTime: iso8601String,
                                    svcAccessCode: "1234")

let cardData = CardEncryption(publicKey: publicKey, cardData: encryptedData)
cardData.getEncryptedData { cardEncryptionResult in
    switch cardEncryptionResult {
    case let .success(cardEncryptionResult):
        print(cardEncryptionResult)
    case let .failure(error):
        print(error)
    }
}

```


### Customization

##### Localization

Set language in code. By default SDK will use system language.

```swift
VerifoneSDK.locale = Locale(identifier: "en")
```

##### Font

Set font in code. By default SDK will use system font.

```swift
VerifoneSDK.defaultTheme.font = UIFont(name: "Helvetica", size: 15)
```

##### Customize the card form

Configure default theme properties for a credit card form.

```swift 
VerifoneSDK.defaultTheme.primaryBackgroundColor = UIColor.grey
```

List of properties for customizing the credit card form.

N | PROPERTY NAME | DESCRIPTION  
| --- | --- | --- |  
1 | primaryBackgorundColor | Card form view background color |
2 | textfieldBackgroundColor | Background color for any text fields in a card form |
3 | textfieldTextColor | Text color for any text fields in a card form |
4 | labelColor | Text color for any labels in a card form |
5 | payButtonBackgroundColor | Pay button background color |
6 | payButtonDisabledBackgroundColor | Pay button background color for disabled state |
7 | payButtonTextColor | Pay button text color |
8 | cardTitleColor | Card form title color |

<img width="400"  src="screens/7.png" />  

