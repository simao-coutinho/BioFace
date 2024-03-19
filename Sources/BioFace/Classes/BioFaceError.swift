//
//  File.swift
//  
//
//  Created by Simao Coutinho on 19/03/2024.
//

import Foundation

private let errorDomain = "BioFaceHandlerErrorDomain"

@objc public enum BioFaceError: Int {
    /// Endpoint TimeOut
    case timeOutErrorCode
    /// The api token given is invalid check if is added on AppDelegate
    case invalidApiTokenErrorCode
    /// The session id given is invalid check if is added correctly
    case invalidSessionIdErrorCode
}

func _error(
    for errorCode: BioFaceError,
    apiErrorCode: String? = nil,
    userInfo additionalUserInfo: [AnyHashable: Any]? = nil
) -> NSError {
    var userInfo: [AnyHashable: Any] = additionalUserInfo ?? [:]
    
    switch errorCode {
    case .timeOutErrorCode:
        userInfo[NSLocalizedDescriptionKey] = "Timed out using this method -- try again"
        break
    case .invalidApiTokenErrorCode:
        userInfo[NSLocalizedDescriptionKey] = "The api token given is invalid check if is added on AppDelegate"
        break
    case .invalidSessionIdErrorCode:
        userInfo[NSLocalizedDescriptionKey] = "The session id given is invalid check if is added correctly"
        break
    }
    
    return NSError(
        domain: errorDomain, code: errorCode.rawValue,
        userInfo: userInfo as? [String: Any])
}
