//
//  Ellipse.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 28.12.17.
//  Copyright © 2017 Michael Kühweg. All rights reserved.
//

import UIKit

class Ellipse: GeometricShape {

    static let mutationOptions = 3

    // TODO these are mainly relevant for the basic genetic algorithm, could
    // therefore need some restructuring later (basic shapes, hillclimb shapes,
    // something like that)

    // do not smear across the whole canvas initially
//    static let rangeForRandomRadius = 0.0625
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
        return Ellipse(centerX: drand48() * Double(width) / maxExtent,
                       centerY: drand48() * Double(height) / maxExtent,
                       radiusX: drand48() * rangeForRandomRadius + minimumRandomRadius,
                       radiusY: drand48() * rangeForRandomRadius + minimumRandomRadius,
                       angleInDegrees: drand48() * 360)
    }

    // TODO go back to fully private properties, once SVG export is
    // implemented.
    public private (set) var centerX: Double
    public private (set) var centerY: Double
    public private (set) var radiusX: Double
    public private (set) var radiusY: Double
    public private (set) var angleInDegrees: Double
    
    public var colour: MontmartreColour
    
    init(centerX: Double, centerY: Double,
         radiusX: Double, radiusY: Double,
         angleInDegrees: Double,
         colour: MontmartreColour = MontmartreColour.clear) {
        self.centerX = centerX
        self.centerY = centerY
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

    func neighbours() -> [GeometricShape] {
        let left = centerX - drand48() * Ellipse.rangeForCenterMutation
        let right = centerX + drand48() * Ellipse.rangeForCenterMutation
        let up = centerY - drand48() * Ellipse.rangeForCenterMutation
        let down = centerY + drand48() * Ellipse.rangeForCenterMutation
        let thinner = radiusX - drand48() * Ellipse.rangeForRandomRadius
        let thicker = radiusX + drand48() * Ellipse.rangeForRandomRadius
        let flatter = radiusY - drand48() * Ellipse.rangeForRandomRadius
        let higher = radiusY + drand48() * Ellipse.rangeForRandomRadius
        let clockwise = angleInDegreesBetween0And360(angle: angleInDegrees - drand48() * Ellipse.rangeForAngleMutation)
        let counterClockwise = angleInDegreesBetween0And360(angle: angleInDegrees + drand48() * Ellipse.rangeForAngleMutation)
        var neighbours = [GeometricShape]()
        neighbours.append(Ellipse(centerX: left, centerY: centerY,
                                  radiusX: radiusX, radiusY: radiusY,
                                  angleInDegrees: angleInDegrees))
        neighbours.append(Ellipse(centerX: right, centerY: centerY,
                                  radiusX: radiusX, radiusY: radiusY,
                                  angleInDegrees: angleInDegrees))
        neighbours.append(Ellipse(centerX: centerX, centerY: up,
                                  radiusX: radiusX, radiusY: radiusY,
                                  angleInDegrees: angleInDegrees))
        neighbours.append(Ellipse(centerX: centerX, centerY: down,
                                  radiusX: radiusX, radiusY: radiusY,
                                  angleInDegrees: angleInDegrees))
        neighbours.append(Ellipse(centerX: centerX, centerY: centerY,
                                  radiusX: thinner, radiusY: radiusY,
                                  angleInDegrees: angleInDegrees))
        neighbours.append(Ellipse(centerX: centerX, centerY: centerY,
                                  radiusX: thicker, radiusY: radiusY,
                                  angleInDegrees: angleInDegrees))
        neighbours.append(Ellipse(centerX: centerX, centerY: centerY,
                                  radiusX: radiusX, radiusY: flatter,
                                  angleInDegrees: angleInDegrees))
        neighbours.append(Ellipse(centerX: centerX, centerY: centerY,
                                  radiusX: radiusX, radiusY: higher,
                                  angleInDegrees: angleInDegrees))
        neighbours.append(Ellipse(centerX: centerX, centerY: centerY,
                                  radiusX: radiusX, radiusY: radiusY,
                                  angleInDegrees: clockwise))
        neighbours.append(Ellipse(centerX: centerX, centerY: centerY,
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
        // move the center around
        let mutatedCenterX = centerX
            + drand48() * Ellipse.rangeForCenterMutation
            - Ellipse.rangeForCenterMutation / 2
        let mutatedCenterY = centerY
            + drand48() * Ellipse.rangeForCenterMutation
            - Ellipse.rangeForCenterMutation / 2
        return Ellipse(centerX: mutatedCenterX, centerY: mutatedCenterY,
                       radiusX: radiusX, radiusY: radiusY,
                       angleInDegrees: angleInDegrees)
    }

    private func mutatedRadius() -> GeometricShape {
        let mutatedRadiusX = radiusX
            + drand48() * Ellipse.rangeForRadiusMutation
            - Ellipse.rangeForRadiusMutation / 2
        let mutatedRadiusY = radiusY
            + drand48() * Ellipse.rangeForRadiusMutation
            - Ellipse.rangeForRadiusMutation / 2
        return Ellipse(centerX: centerX, centerY: centerY,
                       radiusX: mutatedRadiusX, radiusY: mutatedRadiusY,
                       angleInDegrees: angleInDegrees)
    }

    private func mutatedAngle() -> GeometricShape {
        var mutatedAngle = angleInDegrees
            + drand48() * Ellipse.rangeForAngleMutation
            - Ellipse.rangeForAngleMutation / 2
        if mutatedAngle < 0 {
            mutatedAngle = 360 - mutatedAngle
        } else if mutatedAngle > 360 {
            mutatedAngle = mutatedAngle - 360
        }
        return Ellipse(centerX: centerX, centerY: centerY,
                       radiusX: radiusX, radiusY: radiusY,
                       angleInDegrees: mutatedAngle)
    }

    func drawInContext(context: UIGraphicsImageRendererContext,
                       usingColour: UIColor) {

        let factor: Double = max(Double(context.currentImage.size.width),
                                 Double(context.currentImage.size.height))
        
        let pixelCenterX = round(centerX * factor)
        let pixelCenterY = round(centerY * factor)
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
