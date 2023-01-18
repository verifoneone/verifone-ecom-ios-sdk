//
//  Vfi#ds.swift
//  VerifoneTestPaymentApp
//

import CardinalMobile

public class Verifone3DSecureManager {

    fileprivate var threedsConfiguration: VerifoneSDK.ThreedsConfiguration?

    fileprivate var session: CardinalSession!

    fileprivate var didValidated: ((String) -> Void)?
    fileprivate var didFailed: (() -> Void)?

    fileprivate var onCompletion: ((CallbackStatus, String?) -> Void)!

    public init(threedsConfiguration: VerifoneSDK.ThreedsConfiguration?) {
        self.threedsConfiguration = threedsConfiguration

        configureCardinalSession(customUi: nil)
    }

    public func setup(with jwt: String, completion: @escaping ((String) -> Void), failure: @escaping ((CardinalResponse) -> Void)) {
        session.setup(jwtString: jwt, completed: { consumerSessionId in
            // You may have your Submit button disabled on page load. Once you are setup
            // for CCA, you may then enable it. This will prevent users from submitting
            // their order before CCA is ready.
            completion(consumerSessionId)
        }) { validateResponse in
            // Handle failed setup
            // If there was an error with setup, cardinal will call this function with
            // validate response and empty serverJWT
            failure(validateResponse)
        }
    }

    public func complete3DSecureValidation(with transactionId: String, payload: String, acsUrl: String? = nil, termUrl: String? = nil, isThreeDSV1: Bool = false, didValidated: @escaping ((String) -> Void), didFailed: @escaping (() -> Void)) {
        self.didValidated = didValidated
        self.didFailed = didFailed

        if isThreeDSV1 && termUrl == nil {
            didFailed()
            return
        }

        if termUrl == nil && !isThreeDSV1 {
            session.continueWith(transactionId: transactionId, payload: payload, validationDelegate: self)
        }
    }

    private func configureCardinalSession(customUi: VFCustomUi?) {
        var waringMessageTitle: String = ""
        var waringMessageMessage: String = ""

        if self.threedsConfiguration == nil {
            AppLog.log("Missing threeds configuration", log: sdkLogObject, type: .error)
            waringMessageTitle = "Missing threeds configurration information."
            waringMessageMessage = "Please set the threeds configuration to initilize."

            assertionFailure("\(waringMessageTitle) \(waringMessageMessage)")
        }

        session = CardinalSession()
        let config = CardinalSessionConfiguration()

        switch threedsConfiguration!.environment {
        case .production:
            config.deploymentEnvironment = .production
        case .staging:
            config.deploymentEnvironment = .staging
        }

        config.uiType = .both

        if let yourCustomUi = customUi {
            config.uiCustomization = yourCustomUi
        }

        config.renderType = [CardinalSessionRenderTypeOTP,
                             CardinalSessionRenderTypeHTML]
        config.enableDFSync = true
        session.configure(config)
    }
}

extension Verifone3DSecureManager: CardinalValidationDelegate {
    public func cardinalSession(cardinalSession session: CardinalSession!,
                                stepUpValidated validateResponse: CardinalResponse!,
                                serverJWT: String!) {

        switch validateResponse.actionCode {
        case .timeout: break

        case .success:
            self.didValidated?(serverJWT)
        case .cancel, .noAction, .failure, .error:
            self.didFailed?()
        @unknown default:
            self.didFailed?()
        }
    }
}
