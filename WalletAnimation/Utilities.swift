//
//  Utilities.swift
//  WalletAnimation
//
//  Created by Janum Trivedi.
//

import Foundation
import UIKit

/**
 Takes a value in range `(a, b)` and returns that value mapped to another range `(c, d)` using linear interpolation.
 
 For example, `0.5` mapped from range `(0, 1)` to range `(0, 100`) would produce `50`.
 
 Note that the return value is not clipped to the `out` range. For example, `mapRange(2, 0, 1, 0, 100)` would return `200`.
 */
public func mapRange<T: FloatingPoint>(value: T, inMin: T, inMax: T, outMin: T, outMax: T) -> T {
    ((value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin)
}

/**
 The same function as `mapRange(value:inMin:inMax:outMin:outMax:)` but omitting the parameter names for terseness.
 */
public func mapRange<T: FloatingPoint>(_ value: T, _ inMin: T, _ inMax: T, _ outMin: T, _ outMax: T) -> T {
    mapRange(value: value, inMin: inMin, inMax: inMax, outMin: outMin, outMax: outMax)
}

/**
 Returns a value bounded by the provided range.
 - parameter lower: The minimum allowable value (inclusive).
 - parameter upper: The maximum allowable value (inclusive).
 */
public func clip<T: FloatingPoint>(value: T, lower: T, upper: T) -> T {
    min(upper, max(value, lower))
}

/**
 Returns a value bounded by the range `[0, 1]`.
 */
public func clipUnit<T: FloatingPoint>(value: T) -> T {
    clip(value: value, lower: 0, upper: 1)
}

/**
 Source: https://stackoverflow.com/questions/62632213/swift-use-hsl-color-space-instead-of-standard-hsb-hsv
 */
extension UIColor {
    convenience init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat) {
        precondition(0...1 ~= hue &&
                     0...1 ~= saturation &&
                     0...1 ~= lightness &&
                     0...1 ~= alpha, "input range is out of range 0...1")
        
        //From HSL TO HSB ---------
        var newSaturation: CGFloat = 0.0
        
        let brightness = lightness + saturation * min(lightness, 1-lightness)
        
        if brightness == 0 { newSaturation = 0.0 }
        else {
            newSaturation = 2 * (1 - lightness / brightness)
        }
        //---------
        
        self.init(hue: hue, saturation: newSaturation, brightness: brightness, alpha: alpha)
    }
}
