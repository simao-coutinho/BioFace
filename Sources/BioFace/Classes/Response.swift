//
//  File.swift
//  
//
//  Created by Simao Coutinho on 14/03/2024.
//

import Foundation

public struct Response: Decodable {
    public private(set) var success: Bool
    public private(set) var data: ExtractResponse?
}

public struct ExtractResponse: Decodable {
    public private(set) var name: String
    public private(set) var data: Array<Float>
    public private(set) var verdict: Bool
    public private(set) var blocks: Array<ExtractResponse>
}
