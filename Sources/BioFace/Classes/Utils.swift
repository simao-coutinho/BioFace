//
//  File.swift
//  
//
//  Created by Simao Coutinho on 13/06/2024.
//

import UIKit

@IBDesignable class RotatableView: UILabel {

    @objc @IBInspectable var rotationDegrees: Float = 0 {
        didSet {
            print("Setting angle to \(rotationDegrees)")
            let angle = NSNumber(value: rotationDegrees / 180.0 * Float.pi)
            layer.setValue(angle, forKeyPath: "transform.rotation.z")
        }
    }
}
