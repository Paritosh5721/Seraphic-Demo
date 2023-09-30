//
//  ExtensionUIView.swift
//  Seraphic_Demo
//
//  Created by Paritosh on 30/09/23.
//

import Foundation
import UIKit

extension UIView {
    func addShadow(color: UIColor, opacity: Float, offset: CGSize, radius: CGFloat) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
}
