//
//  UIView+Ext.swift
//  LocationLog
//
//  Created by Quinn on 27/10/2021.
//

import Foundation
import UIKit

extension UIView {
    
    func makeClearHole(rect: CGRect) {
        let maskLayer       = CAShapeLayer()
        maskLayer.fillRule  = CAShapeLayerFillRule.evenOdd
        maskLayer.fillColor = UIColor.black.cgColor
        
        let pathToOverlay   = UIBezierPath(rect: self.bounds)
        pathToOverlay.append(UIBezierPath(rect: rect))
        pathToOverlay.usesEvenOddFillRule = true
        maskLayer.path      = pathToOverlay.cgPath
        
        layer.mask          = maskLayer
    }
}
