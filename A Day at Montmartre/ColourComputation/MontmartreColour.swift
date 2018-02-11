//
//  MontmartreColour.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 18.01.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import UIKit
// An abstract representation of colours used for averaging and mixing.
// The abstraction is meant to be able to move from the initial RGBA
// representation to maybe L*a*b or something else in the future.
// Values are in plain colour and alpha. Convert to or from premultiplied
// alpha as necessary.
struct MontmartreColour: Equatable {

    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    static let black = MontmartreColour(red: 0, green: 0, blue: 0, alpha: 1)
    static let white = MontmartreColour(red: 1, green: 1, blue: 1, alpha: 1)
    static let clear = MontmartreColour(red: 0, green: 0, blue: 0, alpha: 0)

    static let red = MontmartreColour(red: 1, green: 0, blue: 0, alpha: 1)
    static let green = MontmartreColour(red: 0, green: 1, blue: 0, alpha: 1)
    static let blue = MontmartreColour(red: 0, green: 0, blue: 1, alpha: 1)

    init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red.clamp(between: 0, and: 1)
        self.green = green.clamp(between: 0, and: 1)
        self.blue = blue.clamp(between: 0, and: 1)
        self.alpha = alpha.clamp(between: 0, and: 1)
    }

    init(premultipliedRed: Double, green: Double, blue: Double, alpha: Double) {
        if alpha != 0 {
            self.red = (premultipliedRed / alpha).clamp(between: 0, and: 1)
            self.green = (green / alpha).clamp(between: 0, and: 1)
            self.blue = (blue / alpha).clamp(between: 0, and: 1)
            self.alpha = alpha
        } else {
            self.red = 1
            self.green = 1
            self.blue = 1
            self.alpha = 0
        }
    }

    func usingPremultipliedAlpha() -> MontmartreColour {
        return MontmartreColour(red: alpha * red,
                                green: alpha * green,
                                blue: alpha * blue,
                                alpha: alpha)
    }

    func distance(to other: MontmartreColour) -> Double {
        let opaqueSelf = opaque(againstBackgroundColour: MontmartreColour.white)
        let opaqueOther = other.opaque(againstBackgroundColour: MontmartreColour.white)
        let deltaRed = opaqueSelf.red - opaqueOther.red
        let deltaGreen = opaqueSelf.green - opaqueOther.green
        let deltaBlue = opaqueSelf.blue - opaqueOther.blue
        return sqrt(deltaRed * deltaRed + deltaGreen * deltaGreen + deltaBlue * deltaBlue)
    }

    func overpainted(with: MontmartreColour) -> MontmartreColour {
        // Porter-Duff :-)
        let mixedAlpha = with.alpha + (1 - with.alpha) * self.alpha

        guard mixedAlpha != 0.0 else { return self }

        return MontmartreColour(
            red: with.alpha * with.red + (1.0 - with.alpha) * self.red,
            green: with.alpha * with.green + (1.0 - with.alpha) * self.green,
            blue: with.alpha * with.blue + (1.0 - with.alpha) * self.blue,
            alpha: mixedAlpha)
    }

    func opaque(againstBackgroundColour background: MontmartreColour) -> MontmartreColour {
        return MontmartreColour(
            red: alpha * red + (1.0 - alpha) * background.red,
            green: alpha * green + (1.0 - alpha) * background.green,
            blue: alpha * blue + (1.0 - alpha) * background.blue,
            alpha: 1.0)
    }

    func requiredOverpaintToAchieve(targetColour: MontmartreColour,
                                           usingAlpha: Double) -> MontmartreColour {

        guard usingAlpha != 0 else { return MontmartreColour.clear }

        return MontmartreColour(
            red: (targetColour.alpha * targetColour.red
                - ((1 - usingAlpha) * alpha * red))
                / usingAlpha,
            green: (targetColour.alpha * targetColour.green
                - ((1 - usingAlpha) * alpha * green))
                / usingAlpha,
            blue: (targetColour.alpha * targetColour.blue
                - ((1 - usingAlpha) * alpha * blue))
                / usingAlpha,
            alpha: usingAlpha)
    }

    func maximumDistance() -> Double {
        return max(distance(to: MontmartreColour.white), distance(to: MontmartreColour.black))
    }

    // MARK: delegates
    static func ==(lhs: MontmartreColour, rhs: MontmartreColour) -> Bool {
        return lhs.red == rhs.red
            && lhs.green == rhs.green
            && lhs.blue == rhs.blue
            && lhs.alpha == rhs.alpha
    }
}

