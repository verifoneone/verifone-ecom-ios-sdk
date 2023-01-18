import Foundation

extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

extension String {
    func localized(withComment comment: String = "") -> String {
        return VerifoneSDK.getBundle().localizedString(forKey: self,
                                                            value: "**\(self)**",
                                                            table: nil)
    }
}
