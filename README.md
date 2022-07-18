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


## Usage

Required Parameters to setup the SDK.


```swift
let paymentConfiguration = VerifoneSDK.PaymentConfiguration(
 cardEncryptionPublicKey: "YOUR_CARD_ENCRYPTION_KEY",
 paymentPanelStoreTitle: "store_name", showCardSaveSwitch: "bool", allowedPaymentMethods: [.creditCard, .paypal, .applePay])

let applepayConfiguration = VerifoneSDK.ApplePayMerchantConfiguration(applePayMerchantId: "YOUR_MERCHANT_ID", supportedPaymentNetworks: [.amex, .discover, .visa, .masterCard], countryCode: "US", currencyCode: "USD", paymentSummaryItems: [PKPaymentSummaryItem(label: "Test Product", amount: 1.0)])

let verifonePaymentForm = VerifonePaymentForm(paymentConfiguration: paymentConfiguration, applepayConfiguration: applepayConfiguration)

verifonePaymentForm.displayPaymentForm(from: self) { result in
            // handle result based on payment method selected by the customer
}
```


###### Transaction flow without threed secure.

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
                        default: break
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

Transaction flow with threed secure.

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


### Customization

###### Localization

Set language in code. By default SDK will use system language.

```swift
VerifoneSDK.locale = Locale(identifier: "en")
```

###### Font

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

