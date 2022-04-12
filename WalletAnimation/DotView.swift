//
//  DotView.swift
//  WalletAnimation
//
//  Created by Janum Trivedi.
//

import Foundation
import UIKit

/**
 Nothing too interesting here. This is just a circular view with a label and a linear gradient.
 */
class DotView: UIView {
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "↑"
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var gradient: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .axial
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(gradientLayer)
        return gradientLayer
    }()
    
    init() {
        super.init(frame: .zero)
        layer.addSublayer(gradient)
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradient.frame = bounds
        label.frame = bounds
        
        layer.masksToBounds = true
        layer.cornerRadius = bounds.size.width / 2.0
    }
}
