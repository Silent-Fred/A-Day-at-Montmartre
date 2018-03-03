//
//  Approximator.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 02.01.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import UIKit

enum SupportedGeometricShapes {
    case rectangles
    case smallDots
    case lines
    case triangles
    case ellipses
}

class Approximator {

    // maybe make alpha configurable later
    static let layerAlpha = 0.5

    public private (set) var approximationAttempts = 0

    public private (set) var context: ApproximationContext?

    var targetImage: UIImage? {
        return context?.targetImage
    }
    var targetScaledImage: UIImage? {
        return context?.targetImageScaledToSizeForApproximation
    }
    var currentScaledImage: UIImage? {
        return context?.currentStateOfApproximation
    }
    var currentImage: UIImage? {
        return context?.currentStateForDisplay
    }

    var shapeCount: Int {
        if let count = context?.shapes.count {
            return count
        }
        return 0
    }

    private (set) var shapesToUse: SupportedGeometricShapes

    init(imageToApproximate: UIImage, using: SupportedGeometricShapes = .ellipses) {
        context = ApproximationContext(originalImage: imageToApproximate)
        shapesToUse = using
    }

    func refineApproximation() {
        preconditionFailure("This method must be overridden")
    }

    func randomShape() -> GeometricShape {

        guard let current = context?.current else { return emptyShape() }

        switch shapesToUse {
        case .rectangles:
            return Rectangle.randomShape(frameWidth: current.width, frameHeight: current.height)
        case .smallDots:
            return SmallDot.randomShape(frameWidth: current.width, frameHeight: current.height)
        case .lines:
            return Line.randomShape(frameWidth: current.width, frameHeight: current.height)
        case .triangles:
            return Triangle.randomShape(frameWidth: current.width, frameHeight: current.height)
        default:
            return Ellipse.randomShape(frameWidth: current.width, frameHeight: current.height)
        }
    }

    private func emptyShape() -> GeometricShape {
        // the kind of shape actually doesn't matter when it's empty, so we pick our favourite
        return Ellipse(center: Point(x: 0.0, y: 0.0),
                       radiusX: 0.0, radiusY: 0.0,
                       angleInDegrees: 0.0)
    }

    func tintShapeAndCalculateImprovement(shape: inout GeometricShape) -> Double {

        guard let context = context else { return 0.0 }

        // increase number of attempts made so far (statistics / insight)
        approximationAttempts += 1

        let mask = context.maskedPixelIndices(shape: shape)

        let colourCloudTarget = context.target.colourCloud(maskedByPixelIndices: mask)
        let colourCloudCurrent = context.current.colourCloud(maskedByPixelIndices: mask)

        shape.colour = findOverpaintColour(making: colourCloudCurrent,
                                           lookLike: colourCloudTarget)

        let improvement = calculateImprovementInSquareDeviation(overpainting: colourCloudCurrent,
                                                                with: shape.colour,
                                                                approximating: colourCloudTarget)
        return improvement
    }

    private func findOverpaintColour(making current: ColourCloud,
                                     lookLike target: ColourCloud) -> MontmartreColour {
        // alpha is currently a fixed value, could be part of the computation as well
        let alpha = Approximator.layerAlpha

        return current.averageColour().requiredOverpaintToAchieve(
            targetColour: target.averageColour(),
            usingAlpha: alpha)
    }

    private func calculateImprovementInSquareDeviation(overpainting current: ColourCloud,
                                                       with overpaintColour: MontmartreColour,
                                                       approximating target: ColourCloud)
        -> Double {
        let currentDeviation = current.squareDeviationFrom(target: target)
        let overpaintedColourCloud = current.overpainted(withColour: overpaintColour)
        let nextDeviation = overpaintedColourCloud.squareDeviationFrom(target: target)
        return currentDeviation - nextDeviation
    }
}
