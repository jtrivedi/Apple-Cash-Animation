//
//  CardView.swift
//  WalletAnimation
//
//  Created by Janum Trivedi.
//

import Foundation
import UIKit

struct ColorCacheKey: Hashable {
    let hue: CGFloat
    let saturation: CGFloat
    let lightness: CGFloat
}

class CardView: UIView {
    
    private var dotViews: [DotView] = []
    private var colorCache: [ColorCacheKey : UIColor] = [:]
    
    private let nameLabel = UILabel()
    private let balanceLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        setupSubviews()
    }
    
    /**
     We pick the focal point to start at the bottom-center point of the card, but it could be moved to wherever.
     */
    lazy var originFocalPoint: CGPoint = {
        CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height)
    }()
    
    /**
     This is the most interesting part of the project. We iterate through each dot on the card, calculate its distance from
     the focal point, and turn that distance into a color.
     
     Then, as the device moves around, the accelerometer moves the focal point around and calls `updateColors` again,
     which creates the moving gradient effect.
     */
    func updateColors(withFocalPoint focalPoint: CGPoint) {
        // We don't want CA's implicit animations, so create a new transaction and disable them.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // The dots closest to the focal point will have a hue of 0.2,
        // and the dots furthest will have a hue of 0.8.
        let minHue = 0.2
        let maxHue = 0.8
        
        // Dots that are >= 380pts from the focal point will have the max hue.
        let radiusForMinimumHue = 0.0
        let radiusForMaximumHue = 380.0
        
        var saturation = 0.6
        let lightness = 0.7
        
        // When a dot is sufficiently far from the focal point, start turning down its saturation, too.
        let distanceToBeginDesaturation = 400.0
        let distanceToEndDesaturation = 700.0
        
        for dot in dotViews {
            // The focal point starts at the bottom-center of the card, and moves around as the device does.
            let xDist = abs(dot.center.x - focalPoint.x)
            let yDist = abs(dot.center.y - focalPoint.y)
            let distanceFromFocalPoint = hypot(xDist, yDist)
            
            // Each dot is /itself/ a gradient, so calculate two slightly different colors for the dot.
            var startHue = mapRange(distanceFromFocalPoint - 30, radiusForMinimumHue, radiusForMaximumHue, minHue, maxHue)
            var endHue = mapRange(distanceFromFocalPoint, radiusForMinimumHue, radiusForMaximumHue, minHue, maxHue)
            
            // The dot is pretty far, so start ramping its saturation down to 0.
            // This "grays out" the dot.
            if distanceFromFocalPoint >= distanceToBeginDesaturation {
                saturation = mapRange(distanceFromFocalPoint, distanceToBeginDesaturation, distanceToEndDesaturation, 0.6, 0)
            }
            
            // Hue, saturation, and lightness all need to be constrained within [0, 1].
            startHue = clipUnit(value: startHue)
            endHue = clipUnit(value: endHue)
            saturation = clipUnit(value: saturation)
            
            // Round the values to two decimal points so we can cache them.
            let startHueRounded   = Double(round(100 * startHue)   / 100)
            let endHueRounded     = Double(round(100 * endHue)     / 100)
            let saturationRounded = Double(round(100 * saturation) / 100)
            
            // Creating a ton of `UIColor` objects isn't cheap, so we cache them locally.
            let startColorKey = ColorCacheKey(hue: startHueRounded, saturation: saturationRounded, lightness: lightness)
            let endColorKey = ColorCacheKey(hue: endHueRounded, saturation: saturationRounded, lightness: lightness)
            
            // These are the start and end colors for the dot's internal gradient.
            var startColor = colorCache[startColorKey]
            var endColor = colorCache[endColorKey]
            
            if startColor == nil {
                startColor = UIColor(hue: startHueRounded, saturation: saturationRounded, lightness: lightness, alpha: 1)
                colorCache[startColorKey] = startColor
            }
            
            if endColor == nil {
                endColor = UIColor(hue: endHue, saturation: saturationRounded, lightness: lightness, alpha: 1)
                colorCache[endColorKey] = endColor
            }
            
            // We finally have our two gradient colors for a particular dot, now update the dot with the colors!
            dot.gradient.colors = [startColor!, endColor!].map { $0.cgColor }
        }
        
        // Remember to commit the transaction we opened!
        CATransaction.commit()
    }
    
    /**
     This method handles laying out the dots in those nice, circular arcs. It's independent from how the gradient itself works.
     
     The general idea is that starting from the focal point, we start moving out in concentric circles, adding dots at various points on the arc.
     */
    func setupDots() {
        let rows = 6
        
        for i in 0...rows {
            // Calculating how far a row is from the center row lets us scale down dots that are farther out.
            let centerRow = Int(rows / 2)
            let distanceFromCenterRow = CGFloat(abs(i - centerRow))
            
            let baseSize = 13.0
            let scale = mapRange(distanceFromCenterRow, 0, CGFloat(rows), 1.0, 0.1)
            let size = baseSize * scale
            
            // Rows farther out are smaller, so scale down the radius a tiny bit.
            let radiusAdjustment = mapRange(CGFloat(i), 0, CGFloat(rows), 26, 22)
            let radius = 40.0 + CGFloat(i) * radiusAdjustment
            
            // [0, 2*pi] is a full circle.
            let startAngle = 0.0
            let endAngle = 2 * Double.pi
            
            // Pick some angle interval that feels right.
            let angleInterval = Double.pi / (6.0 * (CGFloat(i + 1)))
            
            let angles = stride(from: startAngle, to: endAngle, by: angleInterval)
            for angle in angles {
                /**
                 Formula for points on a circle, given a radius `r` and angle `θ`:
                 ```
                     x = r * sin(θ)
                     y = r * cos(θ)
                 ```
                 */
                let x = radius * sin(angle) + originFocalPoint.x
                let y = radius * cos(angle) + originFocalPoint.y
                
                let dot = DotView()
                dot.bounds.size = CGSize(width: size, height: size)

                // Apply a rotation transform so the arrows on the dots all face outward.
                let rotationAngle = (-angle + .pi)
                let rotationTransform = CGAffineTransform(rotationAngle: rotationAngle)
                
                // Position the dot on the card.
                dot.transform = rotationTransform
                dot.center = CGPoint(x: x, y: y)
                
                // Perf: if the dot is fully out of the bounds of the card, don't bother adding it.
                if dot.frame.intersects(bounds) {
                    addSubview(dot)
                    dotViews.append(dot)
                }
            }
        }
        
        updateColors(withFocalPoint: originFocalPoint)
    }
    
    // MARK: - Basic Setup
    
    func setupSubviews() {
        backgroundColor = .black
        layer.cornerCurve = .continuous
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        addSubview(nameLabel)
        addSubview(balanceLabel)
        
        nameLabel.text = "Cash"
        balanceLabel.text = "$40"
        
        nameLabel.textAlignment = .left
        balanceLabel.textAlignment = .right
        
        [nameLabel, balanceLabel].forEach {
            $0.textColor = .white
            $0.font = .boldSystemFont(ofSize: 20)
        }
        
        bringSubviewToFront(balanceLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let horizontalPadding = 15.0
        let height = 50.0
        nameLabel.frame = CGRect(x: horizontalPadding, y: 0, width: bounds.size.width, height: height)
        balanceLabel.frame = CGRect(x: 0, y: 0, width: bounds.size.width - horizontalPadding, height: height)
    }
}
