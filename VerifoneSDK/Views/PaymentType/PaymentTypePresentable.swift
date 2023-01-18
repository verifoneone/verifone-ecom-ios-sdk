import UIKit

struct PaymentTypePresentable: Equatable {
    let name: String
    let cardBrand: UIImage
    let type: VerifoneSDKPaymentTypeValue
}
