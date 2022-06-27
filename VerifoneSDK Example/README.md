# Example App

Our VerifoneSDK Example app provides a sample integration for Card/3DS and PayPal payment options. This integration connects to the verifone API directly but it is important to note that your production app should only be connecting to the API from your server. To setup your verifone test credentials open `VerifoneSDK Example/MerchantAppConfig.swift` and replace the placeholder values under the Credentials config enum with your own.

| Field name | Placeholder |
| ------------- | ------------- |
| Verifone API User ID | **{USER_ID}** | 
| Verifone API Key | **{API_KEY}** | 
| Card Payment Contract ID | **{CARD_PAYMENT_PROVIDER_CONTRACT_ID}** | 
| PayPal Payment Contract ID | **{PAYPAL_PAYMENT_PROVIDER_CONTRACT_ID}** | 
| 3DS Contract ID | **{3DS_CONTRACT_ID}** | 
| Card Encryption Public Key Alias | **{PUBLIC_KEY_ALIAS}** | 
| Card Encryption Public Key | **{PUBLIC_KEY}** | 

