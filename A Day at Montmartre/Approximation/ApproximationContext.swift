//
//  ApproximationContext.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 14.01.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import UIKit

class ApproximationContext {

    public private (set) var target: BitmapMagic
    public private (set) var current: BitmapMagic

    public private(set) var targetImage: UIImage
    public private(set) var targetImageScaledToSizeForApproximation: UIImage
    public private(set) var currentStateOfApproximation: UIImage
    public private(set) var currentStateForDisplay: UIImage

    public private(set) var shapes = [GeometricShape]()

    private var mask: ShapeMask

    init?(originalImage: UIImage) {
        targetImage = ApproximationContext.scaledVersion(original: originalImage, scale: 1)
        currentStateForDisplay =
            ApproximationContext.emptyCanvas(width: targetImage.size.width,
                                             height: targetImage.size.height)
        let initialApproximationSize = DynamicSizeSuggestion().suggest(forCurrentQuality: 0.0)
        targetImageScaledToSizeForApproximation =
            ApproximationContext.scaledVersionForBetterPerformance(
                original: targetImage,
                imageSizeUsedDuringApproximation: initialApproximationSize)
        currentStateOfApproximation =
            ApproximationContext.emptyCanvas(width: targetImageScaledToSizeForApproximation.size.width,
                                             height: targetImageScaledToSizeForApproximation.size.height)

        guard let cgTargetScaled = targetImageScaledToSizeForApproximation.cgImage,
            let cgCurrentScaled = currentStateOfApproximation.cgImage
            else { return nil }

        target = BitmapMagic(forImage: cgTargetScaled)
        current = BitmapMagic(forImage: cgCurrentScaled)
        mask = ShapeMask(width: target.width, height: target.height)
    }

    func maskedPixelIndices(shape: GeometricShape) -> [Int] {
        return mask.maskedPixelIndices(shape: shape)
    }

    func append(shape: GeometricShape) {
        shapes.append(shape)
        currentStateOfApproximation = drawShapeOverImage(shape: shape,
                                                         image: currentStateOfApproximation)
        currentStateForDisplay = drawShapeOverImage(shape: shape,
                                                    image: currentStateForDisplay)
        if dynamicSizeShouldChange() {
            rescale(toSize: dynamicSize())
        } else {
            // only refresh the current image's BitmapMagic with the newly painted shape
            if let currentImage = currentStateOfApproximation.cgImage {
                current = BitmapMagic(forImage: currentImage)
            }
        }
    }

    func approximationRatingInPercent() -> Double {
        let targetColourCloud = target.colourCloud()
        let currentColourCloud = current.colourCloud()
        let normalisedRootMeanSquareDeviation =
            currentColourCloud.normalisedRootMeanSquareDeviationFrom(target: targetColourCloud)
        return (1.0 - normalisedRootMeanSquareDeviation) * 100
    }

    func currentSize() -> Int {
        let currentWidth = current.width
        let currentHeight = current.height
        return max(currentWidth, currentHeight)
    }

    private func rescale(toSize size: Int) {

        // rescale the scaled image versions
        targetImageScaledToSizeForApproximation =
            ApproximationContext
                .scaledVersionForBetterPerformance(original: targetImage,
                                                   imageSizeUsedDuringApproximation: size)
        currentStateOfApproximation =
            ApproximationContext
                .emptyCanvas(width: targetImageScaledToSizeForApproximation.size.width,
                             height: targetImageScaledToSizeForApproximation.size.height)

        // redraw all shapes on the rescaled current status
        currentStateOfApproximation = drawShapesOverImage(shapes: shapes, image: currentStateOfApproximation)

        // mask and bitmap magic have to be adjusted to the new scale
        rebuildBitmapMagicAndShapeMask()
    }

    private func rebuildBitmapMagicAndShapeMask() {

        guard let cgTarget = targetImageScaledToSizeForApproximation.cgImage,
            let cgCurrent = currentStateOfApproximation.cgImage
            else { return }

        target = BitmapMagic(forImage: cgTarget)
        current = BitmapMagic(forImage: cgCurrent)
        mask = ShapeMask(width: target.width, height: target.height)
    }

    private func dynamicSize() -> Int {
        let suggestedSize = DynamicSizeSuggestion()
            .suggest(forCurrentQuality: approximationRatingInPercent())
        return max(currentSize(), suggestedSize)
    }

    private func dynamicSizeShouldChange() -> Bool {
        return currentSize() < dynamicSize()
    }

    private func rendererThatFits(image: CGImage) -> UIGraphicsImageRenderer {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        return UIGraphicsImageRenderer(
            size: CGSize(width: image.width,
                         height: image.height),
            format: format)
    }

    private func drawShapeOverImage(shape: GeometricShape,
                                    image: UIImage) -> UIImage {
        return drawShapesOverImage(shapes: [shape], image: image)
    }

    private func drawShapesOverImage(shapes: [GeometricShape],
                                     image: UIImage) -> UIImage {

        guard let safeCGImage = image.cgImage else { return image }

        let renderer = rendererThatFits(image: safeCGImage)
        let newImage = renderer.image { context in
            image.draw(at: CGPoint(x: 0, y: 0))
            for shape in shapes {
                shape.drawInContext(context: context,
                                    usingColour: UIColor(
                                        displayP3Red: CGFloat(shape.colour.red),
                                        green: CGFloat(shape.colour.green),
                                        blue: CGFloat(shape.colour.blue),
                                        alpha: CGFloat(shape.colour.alpha)))
            }
        }
        return newImage
    }

    private class func scaledVersionForBetterPerformance(original: UIImage,
                                                         imageSizeUsedDuringApproximation: Int)
        -> UIImage {
            let safeSize = max(1, imageSizeUsedDuringApproximation)
            return scaledVersion(original: original,
                                 scale: calculateScaleFactorForDownscale(
                                    original: original,
                                    imageSizeUsedDuringApproximation: safeSize))
    }

    private class func scaledVersion(original: UIImage, scale: Double) -> UIImage {
        let width = round(Double(original.size.width) * scale)
        let height = round(Double(original.size.height) * scale)

        let format = UIGraphicsImageRendererFormat()
        format.scale = CGFloat(1)
        format.opaque = false

        let boundingRectangle = CGRect(x: 0, y: 0, width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height),
                                               format: format)
        let scaledDownImage = renderer.image { _ in
            original.draw(in: boundingRectangle)
        }
        return scaledDownImage
    }

    private class func calculateScaleFactorForDownscale(original: UIImage,
                                                        imageSizeUsedDuringApproximation: Int)
        -> Double {
            let maxExtent = Int(max(original.size.width, original.size.height))
            if maxExtent > imageSizeUsedDuringApproximation {
                return Double(imageSizeUsedDuringApproximation) / Double(maxExtent)
            }
            return 1
    }

    private class func emptyCanvas(width: CGFloat, height: CGFloat) -> UIImage {
        return colouredCanvas(width: width, height: height, withColour: UIColor.clear)
    }

    private class func colouredCanvas(width: CGFloat, height: CGFloat, withColour colour: UIColor) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height),
                                               format: format)
        let newImage = renderer.image { context in
            let rect = CGRect(x: 0, y: 0, width: width, height: height)
            context.cgContext.setFillColor(colour.cgColor)
            context.fill(rect)
        }
        return newImage
    }
}
