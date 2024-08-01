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
    
    public static func getRegistrationAndVerifyDefaults() -> [(Endpoint, Bool)] {
        var endpoints: [(Endpoint, Bool)] = []
        endpoints.append((Endpoint.LIVENESS, true))
        endpoints.append((Endpoint.COMPLIANCE, true))
        endpoints.append((Endpoint.LIVENESS, true))
         
        return endpoints
    }
    
    public static func getAddCardDefaults() -> [(Endpoint, Bool)] {
        var endpoints: [(Endpoint, Bool)] = []
        endpoints.append((Endpoint.DICA, true))
        endpoints.append((Endpoint.CDTA, true))
        endpoints.append((Endpoint.SMAD, true))
         
        return endpoints
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
    
    public static func fromDescribingValue(value: String) -> Endpoint {
        for endpoint in Endpoint.allCases {
            if String(describing: endpoint) == value {
                return endpoint
            }
        }
        
        return Endpoint(rawValue: value) ?? LIVENESS
    }
}
