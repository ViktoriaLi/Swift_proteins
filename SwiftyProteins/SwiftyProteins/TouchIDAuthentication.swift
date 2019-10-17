//
//  TouchIDAuthentication.swift
//  SwiftyProteins
//
//  Created by Ganna DANYLOVA on 10/16/19.
//  Copyright © 2019 Viktoria. All rights reserved.
//

import Foundation
import LocalAuthentication

enum BiometricType {
    case none
    case touchID
    case faceID
}

class BiometricIDAuth {
    var context = LAContext()
    var loginReason = "Logging in with Touch ID"
    
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func biometricType() -> BiometricType {
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        default:
            return .none
        }
    }
    
    func authenticateUser(completion: @escaping (String?, Bool) -> Void) {
        
        guard canEvaluatePolicy() else {
            completion("Touch ID not available", false)
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: loginReason) { (success, evaluateError) in
                                DispatchQueue.main.async {
                                    if success {
                                        completion(nil, false)
                                    }
                                    else {
                                        var message: String
                                        var ifCancel = false
                                        switch evaluateError {
                                        case LAError.authenticationFailed?:
                                            message = "There was a problem verifying your identity."
                                        case LAError.userCancel?:
                                            message = "You pressed cancel."
                                        case LAError.userFallback?:
                                            message = "You pressed password."
                                            ifCancel = true
                                        case LAError.biometryNotAvailable?:
                                            message = "Face ID/Touch ID is not available."
                                        case LAError.biometryNotEnrolled?:
                                            message = "Face ID/Touch ID is not set up."
                                        case LAError.biometryLockout?:
                                            message = "Face ID/Touch ID is locked."
                                        default:
                                            message = "Face ID/Touch ID may not be configured"
                                        }
                                        completion(message, ifCancel)
                                    }
                                }
        }
    }
}

