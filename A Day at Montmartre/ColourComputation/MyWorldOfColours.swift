//
//  MyWorldOfColours.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 28.12.17.
//  Copyright © 2017 Michael Kühweg. All rights reserved.
//

import Foundation

class ColourAverager {

    static let assumedBackgroundColour = MontmartreColour.white

    private var cumulatedRed = 0.0
    private var cumulatedGreen = 0.0
    private var cumulatedBlue = 0.0
    private var count = 0

    func addDot(withColour colour: MontmartreColour) {
        // mixing the average colour happens against an assumed white background
        // (therefore we'll always use an alpha value of 1.0 for the average colour)
        let opaque = colour.opaque(againstBackgroundColour: MontmartreColour.white)
        cumulatedRed += opaque.red * opaque.red
        cumulatedGreen += opaque.green * opaque.green
        cumulatedBlue += opaque.blue * opaque.blue
        count += 1
    }

    func average() -> MontmartreColour {

        guard count > 0 else { return MontmartreColour.clear }

        let countDouble = Double(count)
        let red = (cumulatedRed / countDouble).squareRoot()
        let green = (cumulatedGreen / countDouble).squareRoot()
        let blue = (cumulatedBlue / countDouble).squareRoot()
        // average colour is calculated as an opaque colour
        let alpha = 1.0
        return MontmartreColour(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// A ColourCloud is an ordered collection of colours of single pixels.
// Colour values are kept in the order that the pixels were added to the cloud.
// Two ColourClouds can therefore be compared pixel by pixel if and
// only if they were both built in the same order of pixels.
class ColourCloud {

    public private (set) var colourCloud = [MontmartreColour]()
    private var cachedAverageColour: MontmartreColour?

    public var count: Int { return colourCloud.count }

    func appendPoint(inColour colour: MontmartreColour) {
        colourCloud.append(colour)
        cachedAverageColour = nil
    }

    func colourOfPoint(withIndex index: Int) -> MontmartreColour {

        guard index >= 0 && index < colourCloud.count else { return MontmartreColour.clear }

        return colourCloud[index]
    }

    func averageColour() -> MontmartreColour {
        if let averageColour = cachedAverageColour {
            return averageColour
        }
        cachedAverageColour = calculateAverageColour()
        return cachedAverageColour!
    }

    func squareDeviationFrom(target: ColourCloud) -> Double {

        // no fast and reliable detection whether clouds are actually the same
        // sequence of points, so just check boundaries because they are relevant
        // for index counts anyway
        guard count == target.count else { return 0.0 }

        var sumSquareError: Double = 0
        for index in 0..<colourCloud.count {
            let distance = colourOfPoint(withIndex: index).distance(to: target.colourOfPoint(withIndex: index))
            sumSquareError += distance * distance
        }
        return sumSquareError
    }

    func meanSquareDeviationFrom(target: ColourCloud) -> Double {

        // avoid division by zero... if there is no colour, any other
        // colour can just as well be assumed to be "the right one"
        guard count != 0 else { return 0 }

        return squareDeviationFrom(target: target) / Double(count)
    }

    func normalisedRootMeanSquareDeviationFrom(target: ColourCloud) -> Double {
        let rootMeanSquareDeviation = (meanSquareDeviationFrom(target: target)).squareRoot()
        let maxDistance = MontmartreColour.white.distance(to: MontmartreColour.black)
        return rootMeanSquareDeviation / maxDistance
    }

    func overpainted(withColour colour: MontmartreColour) -> ColourCloud {
        let overpainted = ColourCloud()
        for pointColour in colourCloud {
            overpainted.appendPoint(inColour: pointColour.overpainted(with: colour))
        }
        return overpainted
    }

    private func calculateAverageColour() -> MontmartreColour {
        let averager = ColourAverager()
        for colour in colourCloud {
            averager.addDot(withColour: colour)
        }
        return averager.average()
    }
}
