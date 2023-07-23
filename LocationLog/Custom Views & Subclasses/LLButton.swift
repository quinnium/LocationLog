//
//  LLButton.swift
//  LocationLog
//
//  Created by Quinn on 17/09/2021.
//

import UIKit
import Foundation

class LLButton: UIButton {

    var isPressed = false
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    
    convenience init(title: String) {
        self.init()
        setTitle(title, for: .normal)
    }
    
    
    func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        setTitleColor(Colors.llPink, for: .normal)

        layer.cornerRadius  = 5
        layer.borderWidth   = 1
        layer.borderColor   = Colors.llPink.cgColor
        
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius  = 3
        layer.shadowOffset  = CGSize(width: 0, height: 2)
        layer.shadowPath    = CGPath(rect: self.bounds, transform: .none)
        
        self.applyGradientBackground()
    }
    
    
    func removeExistingGradientLayers() {
        // Remove any existing gradient layers
        if layer.sublayers != nil {
            for layer in layer.sublayers! {
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
    
    
    func applyGradientBackground() {
        let gradientLayer           = Gradients.buttonGradientNormal()
        gradientLayer.frame         = bounds
        gradientLayer.cornerRadius  = self.layer.cornerRadius
        
        removeExistingGradientLayers()
        layer.insertSublayer(gradientLayer, at: 0)
        
        // Adjust to re-add imageView
        guard let imageView         = imageView else { return }
        imageView.tintColor         = Colors.llPink
        addSubview(imageView)
 
        // Adjust font colour
        setTitleColor(Colors.llPink, for: .normal)
        tintColor = Colors.llPink
    }
    
    
    func applyInverseGradientBackground() {
        let gradientLayer           = Gradients.buttonGradientInverse()
        gradientLayer.frame         = bounds
        gradientLayer.cornerRadius  = self.layer.cornerRadius

        removeExistingGradientLayers()
        layer.insertSublayer(gradientLayer, at: 0)

        // Adjust to re-add imageView
        guard let imageView         = imageView else { return }
        imageView.tintColor         = UIColor.white
        addSubview(imageView)
        
        // Adjust font colour
        setTitleColor(.white, for: .normal)
        tintColor = .white
    }
    
    
    func togglePressed() {
        if isPressed == false {
            applyInverseGradientBackground()
        } else {
            applyGradientBackground()
        }
        isPressed.toggle()
    }
    
    
    func turnOn() {
        setTitleColor(Colors.llPink, for: .normal)
        layer.borderColor   = Colors.llPink.cgColor
        isEnabled           = true
    }
    
    
    func turnOff() {
        setTitleColor(.systemGray, for: .normal)
        layer.borderColor   = UIColor.systemGray.cgColor
        isEnabled           = false
    }
}
