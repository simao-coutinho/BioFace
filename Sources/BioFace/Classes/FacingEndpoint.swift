//
//  File.swift
//
//
//  Created by Simao Coutinho on 15/05/2024.
//

import Foundation

public class FacingEndpoint {
    public var endpoint: Endpoint
    public var parameters: [String: Any]
    
    init(endpoint: Endpoint, parameters: [String: Any]) {
        self.endpoint = endpoint
        self.parameters = parameters
    }
    
    public static func getRegistrationAndVerifyDefaults() -> [Endpoint: Bool] {
        return [
            Endpoint.LIVENESS: true,
            Endpoint.COMPLIANCE: true
        ]
    }
    
    public static func getAddCardDefaults() -> [Endpoint: Bool] {
        return [
            Endpoint.DICA: true,
            Endpoint.CDTA: true,
            Endpoint.SMAD: true,
        ]
    }
}

public enum Endpoint: String, CaseIterable {
    case UPLOAD_IMAGE = "UPLOAD_IMAGE"
    case COMPLIANCE = "compliance"
    case LIVENESS = "liveness"
    case DICA = "dica"
    case CDTA = "cdta"
    case SMAD = "morphing/smad"
    case EXTRACT = "extract"
    case COMPARE = "compare"
    
    public static func fromRawValue(value: String) -> Endpoint {
        return Endpoint(rawValue: value) ?? LIVENESS
    }
}
