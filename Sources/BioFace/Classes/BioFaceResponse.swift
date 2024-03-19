//
//  File.swift
//  
//
//  Created by Simao Coutinho on 19/03/2024.
//

import Foundation

public typealias BioFaceResponse = (
    BioFaceStatus, DetailedResponse?, NSError?
) -> Void

@objc public enum BioFaceStatus: Int {
    /// The action succeeded.
    case succeeded
    /// The action was cancelled by the cardholder/user.
    case canceled
    /// The action failed. See the error code for more details.
    case failed
}

public struct DetailedResponse {
    
}
