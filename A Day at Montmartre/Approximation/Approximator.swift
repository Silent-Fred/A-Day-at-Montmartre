//
//  Approximator.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 02.01.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import UIKit

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

    private (set) var shapesToUse: ShapeStyle

    init(imageToApproximate: UIImage, using: ShapeStyle = .ellipses) {
        context = ApproximationContext(originalImage: imageToApproximate)
        shapesToUse = using
    }

    func refineApproximation() {
        preconditionFailure("This method must be overridden")
    }

    func randomShape() -> GeometricShape {

        guard let current = context?.current else { return emptyShape() }

        return ShapeFactory.randomShape(shapesToUse,
                                        screenRatioWidth: current.width,
                                        toHeight: current.height)
    }

    func approximationRatingInPercent() -> Double {
        guard let rating = context?.approximationRatingInPercent() else { return 0.0 }
        return rating
    }

    func detailLevel() -> Int {
        guard let detail = context?.currentSize() else { return 0 }
        return detail
    }

    private func emptyShape() -> GeometricShape {
        // the kind of shape actually doesn't matter when it's empty, so we pick our favourite
        return Ellipse(center: Point(x: 0.0, y: 0.0),
                       radiusX: 0.0, radiusY: 0.0,
                       angleInDegrees: 0.0)
    }

    func calculateImprovement(shape: GeometricShape)
        -> (shape: GeometricShape, improvement: Double) {

        guard let context = context else { return (shape, 0.0) }

        // increase number of attempts made so far (statistics / insight)
        approximationAttempts += 1

        let mask = context.maskedPixelIndices(shape: shape)

        let colourCloudTarget = context.target.colourCloud(maskedByPixelIndices: mask)
        let colourCloudCurrent = context.current.colourCloud(maskedByPixelIndices: mask)

        let overpaint = findOverpaintColour(making: colourCloudCurrent,
                                            lookLike: colourCloudTarget)
        let improvement = calculateImprovementInDeviation(overpainting: colourCloudCurrent,
                                                                with: overpaint,
                                                                approximating: colourCloudTarget)
        var colouredShape = shape
        colouredShape.colour = overpaint
        return (colouredShape, improvement)
    }

    private func findOverpaintColour(making current: ColourCloud,
                                     lookLike target: ColourCloud) -> MontmartreColour {
        // alpha is currently a fixed value, could be part of the computation as well
        let alpha = Approximator.layerAlpha

        return current.averageColour().requiredOverpaintToAchieve(
            targetColour: target.averageColour(),
            usingAlpha: alpha)
    }

    private func calculateImprovementInDeviation(overpainting current: ColourCloud,
                                                 with overpaintColour: MontmartreColour,
                                                 approximating target: ColourCloud)
        -> Double {
        let overpaintedColourCloud = current.overpainted(withColour: overpaintColour)
        let currentDeviation = current.deviationFrom(target: target)
        let nextDeviation = overpaintedColourCloud.deviationFrom(target: target)
        return currentDeviation - nextDeviation
    }
}
