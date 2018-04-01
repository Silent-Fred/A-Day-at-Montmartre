//
//  Ellipse.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 28.12.17.
//  Copyright © 2017 Michael Kühweg. All rights reserved.
//

import UIKit

struct Ellipse: GeometricShape {

    static let mutationOptions = 3

    // do not smear across the whole canvas initially
    static let rangeForRandomRadius = 0.1
    // do not use tiny or even completely collapsed shapes
    static let minimumRandomRadius = 0.01

    // define how much mutations can change the shape
    static let rangeForCenterMutation = 0.05
    static let rangeForRadiusMutation = 0.05
    static let rangeForAngleMutation = 15.0

    static func randomShape(frameWidth width: Int, frameHeight height: Int) -> GeometricShape {
        let maxExtent = max(Double(width),
                            Double(height))
        return Ellipse(center: Point(x: drand48() * Double(width) / maxExtent,
                                     y: drand48() * Double(height) / maxExtent),
                       radiusX: drand48() * rangeForRandomRadius + minimumRandomRadius,
                       radiusY: drand48() * rangeForRandomRadius + minimumRandomRadius,
                       angleInDegrees: drand48() * 360)
    }

    var colour: MontmartreColour

    private var center: Point
    private var radiusX: Double
    private var radiusY: Double
    private var angleInDegrees: Double

    init(center: Point,
         radiusX: Double, radiusY: Double,
         angleInDegrees: Double,
         colour: MontmartreColour = MontmartreColour.clear) {
        self.center = center
        self.radiusX = radiusX
        self.radiusY = radiusY
        self.angleInDegrees = angleInDegrees
        self.colour = colour
    }

    func mutated() -> GeometricShape {
        // Mutations do not keep track of where they went before.
        // Mutating a shape back and forth could therefore happen.
        let whichMutation = arc4random_uniform(UInt32(Ellipse.mutationOptions))
        switch whichMutation {
        case 0:
            return mutatedCenter()
        case 1:
            return mutatedRadius()
        default:
            return mutatedAngle()
        }
    }

    func patienceWithFailedMutations() -> Int {
        // several (random) attempts at mutating all variants
        return Ellipse.mutationOptions * 10
    }

    private func randomValueForCenterMutation() -> Double {
        return drand48() * Ellipse.rangeForCenterMutation
    }

    private func randomValueForRadiusMutation() -> Double {
        return drand48() * Ellipse.rangeForRadiusMutation
    }

    private func randomValueForAngleMutation() -> Double {
        return drand48() * Ellipse.rangeForAngleMutation
    }

    func neighbours() -> [GeometricShape] {
        var neighbours = [GeometricShape]()
        neighbours.append(Ellipse(center: center.left(by: randomValueForCenterMutation()),
                                  radiusX: radiusX, radiusY: radiusY,
                                  angleInDegrees: angleInDegrees))
        neighbours.append(Ellipse(center: center.right(by: randomValueForCenterMutation()),
                                  radiusX: radiusX, radiusY: radiusY,
                                  angleInDegrees: angleInDegrees))
        neighbours.append(Ellipse(center: center.up(by: randomValueForCenterMutation()),
                                  radiusX: radiusX, radiusY: radiusY,
                                  angleInDegrees: angleInDegrees))
        neighbours.append(Ellipse(center: center.down(by: randomValueForCenterMutation()),
                                  radiusX: radiusX, radiusY: radiusY,
                                  angleInDegrees: angleInDegrees))
        let thinner = radiusX - randomValueForRadiusMutation()
        neighbours.append(Ellipse(center: center,
                                  radiusX: thinner, radiusY: radiusY,
                                  angleInDegrees: angleInDegrees))
        let thicker = radiusX + randomValueForRadiusMutation()
        neighbours.append(Ellipse(center: center,
                                  radiusX: thicker, radiusY: radiusY,
                                  angleInDegrees: angleInDegrees))
        let flatter = radiusY - randomValueForRadiusMutation()
        neighbours.append(Ellipse(center: center,
                                  radiusX: radiusX, radiusY: flatter,
                                  angleInDegrees: angleInDegrees))
        let higher = radiusY + randomValueForRadiusMutation()
        neighbours.append(Ellipse(center: center,
                                  radiusX: radiusX, radiusY: higher,
                                  angleInDegrees: angleInDegrees))
        let clockwise = angleInDegreesBetween0And360(angle: angleInDegrees - randomValueForAngleMutation())
        neighbours.append(Ellipse(center: center,
                                  radiusX: radiusX, radiusY: radiusY,
                                  angleInDegrees: clockwise))
        let counterClockwise = angleInDegreesBetween0And360(angle: angleInDegrees + randomValueForAngleMutation())
        neighbours.append(Ellipse(center: center,
                                  radiusX: radiusX, radiusY: radiusY,
                                  angleInDegrees: counterClockwise))
        return neighbours
    }

    private func angleInDegreesBetween0And360(angle: Double) -> Double {
        if angle < 0 {
            return 360 - angle
        } else if angle > 360 {
            return angle - 360
        }
        return angle
    }

    private func mutatedCenter() -> GeometricShape {
        return Ellipse(center: center.jiggle(peak: Ellipse.rangeForCenterMutation),
                       radiusX: radiusX, radiusY: radiusY,
                       angleInDegrees: angleInDegrees)
    }

    private func mutatedRadius() -> GeometricShape {
        let mutatedRadiusX = radiusX
            + 2 * randomValueForRadiusMutation()
            - Ellipse.rangeForRadiusMutation
        let mutatedRadiusY = radiusY
            + 2 * randomValueForRadiusMutation()
            - Ellipse.rangeForRadiusMutation
        return Ellipse(center: center,
                       radiusX: mutatedRadiusX, radiusY: mutatedRadiusY,
                       angleInDegrees: angleInDegrees)
    }

    private func mutatedAngle() -> GeometricShape {
        var mutatedAngle = angleInDegrees
            + 2 * randomValueForAngleMutation()
            - Ellipse.rangeForAngleMutation
        if mutatedAngle < 0 {
            mutatedAngle = 360 - mutatedAngle
        } else if mutatedAngle > 360 {
            mutatedAngle -= 360
        }
        return Ellipse(center: center,
                       radiusX: radiusX, radiusY: radiusY,
                       angleInDegrees: mutatedAngle)
    }

    func drawInContext(context: UIGraphicsImageRendererContext,
                       usingColour: UIColor) {

        let factor: Double = max(Double(context.currentImage.size.width),
                                 Double(context.currentImage.size.height))

        let pixelCenterX = round(center.x * factor)
        let pixelCenterY = round(center.y * factor)
        let pixelRadiusX = round(radiusX * factor)
        let pixelRadiusY = round(radiusY * factor)

        let cgContext = context.cgContext
        cgContext.setFillColor(usingColour.cgColor)
        cgContext.setStrokeColor(UIColor.clear.cgColor)
        cgContext.setLineWidth(0)

        cgContext.saveGState()
        // set context origin to the center of the ellipse
        cgContext.translateBy(x: CGFloat(pixelCenterX), y: CGFloat(pixelCenterY))
        // rotate the context
        cgContext.rotate(by: CGFloat(.pi*angleInDegrees/180))
        // add an ellipse with same radii as the original to the translated
        // and rotated context
        let boundingRectangleWidth = 2 * pixelRadiusX
        let boundingRectangleHeight = 2 * pixelRadiusY
        let boundingRectangle = CGRect(x: -boundingRectangleWidth / 2,
                                       y: -boundingRectangleHeight / 2,
                                       width: boundingRectangleWidth,
                                       height: boundingRectangleHeight)
        cgContext.addEllipse(in: boundingRectangle)
        // restore origin and rotation to shift the ellipse in the desired
        // location
        cgContext.restoreGState()

        // finally put colour on the canvas
        cgContext.drawPath(using: .fill)
    }
}
