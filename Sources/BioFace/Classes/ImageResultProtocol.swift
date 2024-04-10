//
//  File.swift
//  
//
//  Created by Simao Coutinho on 21/03/2024.
//

import Foundation
import UIKit

public enum ServiceType: Int {
    case makeRegistration
    case addCard
    case verifyUser
}

protocol ImageResultListener {
    func onImageResult(from: ServiceType, with: UIImage, completion: @escaping BioFaceResponse)
}
