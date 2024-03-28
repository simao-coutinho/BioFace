//
//  File.swift
//  
//
//  Created by Simao Coutinho on 14/03/2024.
//

import Foundation

public struct Response: Decodable {
    public private(set) var success: Bool
    public private(set) var data: Data?
}
