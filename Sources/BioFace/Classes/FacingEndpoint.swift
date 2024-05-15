//
//  File.swift
//  
//
//  Created by Simao Coutinho on 15/05/2024.
//

import Foundation

public class FacingEndpoint {
    
    public static let UPLOAD_IMAGE = "UPLOAD_IMAGE"
    public static let COMPLIANCE = "compliance"
    public static let LIVENESS = "liveness"
    public static let DICA = "dica"
    public static let CDTA = "cdta"
    public static let SMAD = "smad"
    public static let EXTRACT = "extract"
    public static let COMPARE = "compare"
    
    public var endpoint: String
    public var parameters: [String: Any]
    
    init(endpoint: String, parameters: [String: Any]) {
        self.endpoint = endpoint
        self.parameters = parameters
    }
    
    
}
