//
//  PaypalTransaction.swift
//  VerifoneSDK Example
//
//  Created by Oraz Atakishiyev on 07.02.2022.
//

import Foundation

struct PaypalTransaction: Codable {
    var intent: String
    var customer: Customer?
    var applicationContext: ApplicationContext?
    var shipping: Shipping?
    var paymentProviderContract: String?
    var items: [Item]?
    var dynamicDescriptor, merchantReference: String
    var detailedAmount: DetailedAmount?
    var amount: Amount?
}

extension PaypalTransaction {
    static let paypal: Self = .init(
        intent: "AUTHORIZE",
        dynamicDescriptor: "Paypal order 123",
        merchantReference: "123test"
    )

    mutating func setupPaypal(returnUrl: String, cancelURL: String, itemName: String, price: Int, paymentProviderContract: String) {
        let mobile = PhoneNumber(phoneType: "MOBILE", value: "64646464")
        let identification = Identification(taxIdentificationNumber: "123456", taxIdentificationType: "BR_CNPJ")
        let address = Address(country: "US", postalCode: "570023", countrySubdivision: "IN-MH", city: "yyy", addressLine1: "add1", addressLine2: "add2")
        let customer = Customer(email: "verifone-buyer@paypal.com",
                                payerID: "WDJJHEBZ4X2LY", phoneNumber: mobile,
                                birthDate: "2000-01-31", identification: identification,
                                address: address, firstName: "James", lastName: "Smith")
        let shipping = Shipping(address: address, fullName: "JamesSmith")
        let applicationContext = ApplicationContext(brandName: "MAHENDRA", shippingPreference: "CustomerProvided", returnURL: returnUrl, cancelURL: cancelURL)
        let item = Item(name: itemName,
                        unitAmount: Amount(currencyCode: CurrencyCode.usd, value: price),
                        tax: Amount(currencyCode: .usd, value: 100), quantity: "1",
                        itemDescription: "Item description", sku: "123", category: "PHYSICAL_GOODS")
        let detailedAmount = DetailedAmount(discount: Amount(currencyCode: .usd, value: 200),
                                            shippingDiscount: Amount(currencyCode: .usd, value: 200),
                                            insurance: Amount(currencyCode: .usd, value: 100),
                                            handling: Amount(currencyCode: .usd, value: 100),
                                            shipping: Amount(currencyCode: .usd, value: 100))

        self.customer = customer
        self.applicationContext = applicationContext
        self.shipping = shipping
        self.paymentProviderContract = paymentProviderContract
        self.items = [item]
        self.detailedAmount = detailedAmount
        self.amount = Amount(currencyCode: .usd, value: (price+400)-400)
    }
}

// MARK: - Amount
class Amount: Codable {
    let currencyCode: CurrencyCode
    let value: Int

    init(currencyCode: CurrencyCode, value: Int) {
        self.currencyCode = currencyCode
        self.value = value
    }
}

enum CurrencyCode: String, Codable {
    case usd = "USD"
}

// MARK: - ApplicationContext
class ApplicationContext: Codable {
    let brandName, shippingPreference: String
    let returnURL, cancelURL: String

    enum CodingKeys: String, CodingKey {
        case brandName, shippingPreference
        case returnURL = "returnUrl"
        case cancelURL = "cancelUrl"
    }

    init(brandName: String, shippingPreference: String, returnURL: String, cancelURL: String) {
        self.brandName = brandName
        self.shippingPreference = shippingPreference
        self.returnURL = returnURL
        self.cancelURL = cancelURL
    }
}

// MARK: - Customer
class Customer: Codable {
    let email, payerID: String
    let phoneNumber: PhoneNumber
    let birthDate: String
    let identification: Identification
    let address: Address
    let firstName, lastName: String

    enum CodingKeys: String, CodingKey {
        case email
        case payerID = "payerId"
        case phoneNumber, birthDate, identification, address, firstName, lastName
    }

    init(email: String, payerID: String, phoneNumber: PhoneNumber, birthDate: String, identification: Identification, address: Address, firstName: String, lastName: String) {
        self.email = email
        self.payerID = payerID
        self.phoneNumber = phoneNumber
        self.birthDate = birthDate
        self.identification = identification
        self.address = address
        self.firstName = firstName
        self.lastName = lastName
    }
}

// MARK: - Address
class Address: Codable {
    let country, postalCode, countrySubdivision, city: String
    let addressLine1, addressLine2: String

    init(country: String, postalCode: String, countrySubdivision: String, city: String, addressLine1: String, addressLine2: String) {
        self.country = country
        self.postalCode = postalCode
        self.countrySubdivision = countrySubdivision
        self.city = city
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
    }
}

// MARK: - Identification
class Identification: Codable {
    let taxIdentificationNumber, taxIdentificationType: String

    init(taxIdentificationNumber: String, taxIdentificationType: String) {
        self.taxIdentificationNumber = taxIdentificationNumber
        self.taxIdentificationType = taxIdentificationType
    }
}

// MARK: - PhoneNumber
class PhoneNumber: Codable {
    let phoneType: String?
    let value: String

    init(phoneType: String?, value: String) {
        self.phoneType = phoneType
        self.value = value
    }
}

// MARK: - DetailedAmount
class DetailedAmount: Codable {
    let discount, shippingDiscount, insurance, handling: Amount
    let shipping: Amount

    init(discount: Amount, shippingDiscount: Amount, insurance: Amount, handling: Amount, shipping: Amount) {
        self.discount = discount
        self.shippingDiscount = shippingDiscount
        self.insurance = insurance
        self.handling = handling
        self.shipping = shipping
    }
}

// MARK: - Item
class Item: Codable {
    let name: String
    let unitAmount, tax: Amount
    let quantity, itemDescription, sku, category: String

    enum CodingKeys: String, CodingKey {
        case name, unitAmount, tax, quantity
        case itemDescription = "description"
        case sku, category
    }

    init(name: String, unitAmount: Amount, tax: Amount, quantity: String, itemDescription: String, sku: String, category: String) {
        self.name = name
        self.unitAmount = unitAmount
        self.tax = tax
        self.quantity = quantity
        self.itemDescription = itemDescription
        self.sku = sku
        self.category = category
    }
}

// MARK: - Shipping
class Shipping: Codable {
    let address: Address
    let fullName: String

    init(address: Address, fullName: String) {
        self.address = address
        self.fullName = fullName
    }
}
