//
//  Rectangle.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 27.01.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import UIKit

class Rectangle: GeometricShape {

    static let mutationOptions = 3

    // do not smear across the whole canvas initially
    static let rangeForRandomExtent = 0.16
    // do not use tiny or even completely collapsed shapes
    static let minimumRandomExtent = 0.01

    // define how much mutations can change the shape
    static let rangeForCenterMutation = 0.05
    static let rangeForExtentMutation = 0.05
    static let rangeForAngleMutation = 15.0

    static func randomShape(frameWidth width: Int, frameHeight height: Int) -> GeometricShape {
        let maxExtent = max(Double(width), Double(height))
        return Rectangle(centerX: drand48() * Double(width) / maxExtent,
                         centerY: drand48() * Double(height) / maxExtent,
                         width: drand48() * rangeForRandomExtent + minimumRandomExtent,
                         height: drand48() * rangeForRandomExtent + minimumRandomExtent,
                         angleInDegrees: drand48() * 360)
    }

    public private (set) var centerX: Double
    public private (set) var centerY: Double
    public private (set) var width: Double
    public private (set) var height: Double
    public private (set) var angleInDegrees: Double

    var colour: MontmartreColour

    init(centerX: Double, centerY: Double,
         width: Double, height: Double,
         angleInDegrees: Double,
         colour: MontmartreColour = MontmartreColour.clear) {
        self.centerX = centerX
        self.centerY = centerY
        self.width = width
        self.height = height
        self.angleInDegrees = angleInDegrees
        self.colour = colour
    }

    func mutated() -> GeometricShape {
        let whichMutation = arc4random_uniform(UInt32(Rectangle.mutationOptions))
        switch whichMutation {
        case 0:
            return mutatedCenter()
        case 1:
            return mutatedExtent()
        default:
            return mutatedAngle()
        }
    }

    func neighbours() -> [GeometricShape] {
        let left = centerX - drand48() * Rectangle.rangeForCenterMutation
        let right = centerX + drand48() * Rectangle.rangeForCenterMutation
        let up = centerY - drand48() * Rectangle.rangeForCenterMutation
        let down = centerY + drand48() * Rectangle.rangeForCenterMutation
        let thinner = width - drand48() * Rectangle.rangeForRandomExtent
        let thicker = width + drand48() * Rectangle.rangeForRandomExtent
        let flatter = height - drand48() * Rectangle.rangeForRandomExtent
        let higher = height + drand48() * Rectangle.rangeForRandomExtent
        let clockwise = angleInDegreesBetween0And360(angle: angleInDegrees - drand48() * Rectangle.rangeForAngleMutation)
        let counterClockwise = angleInDegreesBetween0And360(angle: angleInDegrees + drand48() * Rectangle.rangeForAngleMutation)
        var neighbours = [GeometricShape]()
        neighbours.append(Rectangle(centerX: left, centerY: centerY,
                                    width: width, height: height,
                                    angleInDegrees: angleInDegrees))
        neighbours.append(Rectangle(centerX: right, centerY: centerY,
                                    width: width, height: height,
                                    angleInDegrees: angleInDegrees))
        neighbours.append(Rectangle(centerX: centerX, centerY: up,
                                    width: width, height: height,
                                    angleInDegrees: angleInDegrees))
        neighbours.append(Rectangle(centerX: centerX, centerY: down,
                                    width: width, height: height,
                                    angleInDegrees: angleInDegrees))
        neighbours.append(Rectangle(centerX: centerX, centerY: centerY,
                                    width: thinner, height: height,
                                    angleInDegrees: angleInDegrees))
        neighbours.append(Rectangle(centerX: centerX, centerY: centerY,
                                    width: thicker, height: height,
                                    angleInDegrees: angleInDegrees))
        neighbours.append(Rectangle(centerX: centerX, centerY: centerY,
                                    width: width, height: flatter,
                                    angleInDegrees: angleInDegrees))
        neighbours.append(Rectangle(centerX: centerX, centerY: centerY,
                                    width: width, height: higher,
                                    angleInDegrees: angleInDegrees))
        neighbours.append(Rectangle(centerX: centerX, centerY: centerY,
                                    width: width, height: height,
                                    angleInDegrees: clockwise))
        neighbours.append(Rectangle(centerX: centerX, centerY: centerY,
                                    width: width, height: height,
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
            + drand48() * Rectangle.rangeForCenterMutation
            - Rectangle.rangeForCenterMutation / 2
        let mutatedCenterY = centerY
            + drand48() * Ellipse.rangeForCenterMutation
            - Rectangle.rangeForCenterMutation / 2
        return Rectangle(centerX: mutatedCenterX, centerY: mutatedCenterY,
                         width: width, height: height,
                         angleInDegrees: angleInDegrees)
    }

    private func mutatedExtent() -> GeometricShape {
        let mutatedWidth = width
            + drand48() * Rectangle.rangeForExtentMutation
            - Rectangle.rangeForExtentMutation / 2
        let mutatedHeight = height
            + drand48() * Rectangle.rangeForExtentMutation
            - Rectangle.rangeForExtentMutation / 2
        return Rectangle(centerX: centerX, centerY: centerY,
                         width: mutatedWidth, height: mutatedHeight,
                         angleInDegrees: angleInDegrees)
    }

    private func mutatedAngle() -> GeometricShape {
        var mutatedAngle = angleInDegrees
            + drand48() * Rectangle.rangeForAngleMutation
            - Rectangle.rangeForAngleMutation / 2
        if mutatedAngle < 0 {
            mutatedAngle = 360 - mutatedAngle
        } else if mutatedAngle > 360 {
            mutatedAngle = mutatedAngle - 360
        }
        return Rectangle(centerX: centerX, centerY: centerY,
                         width: width, height: height,
                         angleInDegrees: mutatedAngle)
    }

    func patienceWithFailedMutations() -> Int {
        return Rectangle.mutationOptions * 3
    }

    func drawInContext(context: UIGraphicsImageRendererContext, usingColour: UIColor) {
        let factor: Double = max(Double(context.currentImage.size.width),
                                 Double(context.currentImage.size.height))

        let pixelCenterX = round(centerX * factor)
        let pixelCenterY = round(centerY * factor)
        let pixelWidth = round(width * factor)
        let pixelHeight = round(height * factor)

        let cgContext = context.cgContext
        cgContext.setFillColor(usingColour.cgColor)
        cgContext.setStrokeColor(UIColor.clear.cgColor)
        cgContext.setLineWidth(0)

        cgContext.saveGState()
        // set context origin to the center of the ellipse
        cgContext.translateBy(x: CGFloat(pixelCenterX), y: CGFloat(pixelCenterY))
        // rotate the context
        cgContext.rotate(by: CGFloat(.pi*angleInDegrees/180))
        // add a rectangle
        let rectangle = CGRect(x: -pixelWidth / 2,
                               y: -pixelHeight / 2,
                               width: pixelWidth,
                               height: pixelHeight)
        cgContext.addRect(rectangle)
        // restore origin and rotation to shift the shape in the desired
        // location
        cgContext.restoreGState()

        // finally put colour on the canvas
        cgContext.drawPath(using: .fill)
    }
}
