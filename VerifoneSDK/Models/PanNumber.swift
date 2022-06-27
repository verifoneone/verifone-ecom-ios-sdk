import Foundation
import UIKit

public struct PanNumber {
    let panNumber: String
    
    public var isValid: Bool {
        return CardValidator.validateCardNumber(number)
    }
    
    public var number: String {
        let startIndex = panNumber.index(panNumber.startIndex, offsetBy: max(0, panNumber.count - 10))
        let endEndex = panNumber.index(panNumber.endIndex, offsetBy: max(-panNumber.count, -4))
        let replacingRange = startIndex..<endEndex
        return panNumber.replacingOccurrences(
            of: "[0-9]",
            with: "X",
            options: String.CompareOptions.regularExpression,
            range: replacingRange
        )
    }
    
    public var brand: CardValidator.CardInfo? {
        return CardValidator.getCardType(panNumber)
    }
    
    public var suggestedSpaceFormattedIndexes: IndexSet {
        switch self {
        case CardValidator.CardInfo.AMEX.pattern, "^5[6-8]":
            return [ 4, 10 ]
        case "^50":
            return [ 4, 8 ]
        case "^3[0,6,8-9]":
            return [ 4, 10 ]
        case "^[0-9]":
            return [ 4, 8, 12 ]
        default: return []
        }
    }
    
    public init(_ panNumber: String) {
        self.panNumber = panNumber.replacingOccurrences(
            of: "[^0-9]",
            with: "",
            options: .regularExpression,
            range: nil
        )
    }
    
    public static func suggestedSpaceFormattedIndexesForPANPrefix(_ panPrefix: String) -> IndexSet {
        return PanNumber(panPrefix).suggestedSpaceFormattedIndexes
    }
}

extension PanNumber {
    static func ~= (brand: CardValidator.CardInfo, panNumber: PanNumber) -> Bool {
        return brand.pattern ~= panNumber
    }
    
    static func ~= (pattern: String, panNumber: PanNumber) -> Bool {
        return panNumber.panNumber.range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
