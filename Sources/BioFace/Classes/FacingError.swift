//
//  File.swift
//  
//
//  Created by Simao Coutinho on 19/03/2024.
//

import Foundation

private let errorDomain = "BioFaceHandlerErrorDomain"

@objc public enum FacingError: Int {
    /// Endpoint TimeOut
    case timeOutErrorCode
    /// The api token given is invalid check if is added on AppDelegate
    case invalidApiTokenErrorCode
    /// The session id given is invalid check if is added correctly
    case invalidSessionIdErrorCode
    case invalidTemplateFromSecureKey
    case invalidTemplateFromServer
}

func _error(
    for errorCode: FacingError,
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
    case .invalidTemplateFromSecureKey:
        userInfo[NSLocalizedDescriptionKey] = "The template stored in secure storage is invalid! Please register the user again"
    case .invalidTemplateFromServer:
        userInfo[NSLocalizedDescriptionKey] = "The template retrieve from the server is invalid! Please try again"
    }
    
    return NSError(
        domain: errorDomain, code: errorCode.rawValue,
        userInfo: userInfo as? [String: Any])
}
