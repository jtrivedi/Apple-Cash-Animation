//
//  PlaceholderView.swift
//  WalletAnimation
//
//  Created by Janum Trivedi.
//

import Foundation
import UIKit

/**
 This just creates some random placeholder views that look nice.
 */
class PlaceholderView: UIView {
    
    init() {
        super.init(frame: .zero)
        
        var yOffset: CGFloat = 50.0
        for i in 0...14 {
            let width = CGFloat(Int.random(in: 40...300))
            let rect = UIView(frame: CGRect(x: 30.0, y: yOffset, width: width, height: 20))
            
            rect.backgroundColor = UIColor(red: 0.82, green: 0.82, blue: 0.86, alpha: 1.0)

            rect.layer.cornerRadius = 8
            rect.layer.cornerCurve = .continuous
            
            let sectionBreak = (i + 1) % 3 == 0 ? 40.0 : 0.0
            
            addSubview(rect)
            yOffset += (rect.bounds.size.height * 1.5 + sectionBreak)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
