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
        return Rectangle(center: Point(x: drand48() * Double(width) / maxExtent,
                                       y: drand48() * Double(height) / maxExtent),
                         width: drand48() * rangeForRandomExtent + minimumRandomExtent,
                         height: drand48() * rangeForRandomExtent + minimumRandomExtent,
                         angleInDegrees: drand48() * 360)
    }

    var colour: MontmartreColour

    private var center: Point
    private var width: Double
    private var height: Double
    private var angleInDegrees: Double

    init(center: Point,
         width: Double, height: Double,
         angleInDegrees: Double,
         colour: MontmartreColour = MontmartreColour.clear) {
        self.center = center
        self.width = width
        self.height = height
        self.angleInDegrees = angleInDegrees
        self.colour = colour
    }

    private func randomValueForCenterMutation() -> Double {
        return drand48() * Rectangle.rangeForCenterMutation
    }

    private func randomValueForExtentMutation() -> Double {
        return drand48() * Rectangle.rangeForExtentMutation
    }

    private func randomValueForAngleMutation() -> Double {
        return drand48() * Rectangle.rangeForAngleMutation
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
        var neighbours = [GeometricShape]()
        neighbours.append(Rectangle(center: center.left(by: randomValueForCenterMutation()),
                                    width: width, height: height,
                                    angleInDegrees: angleInDegrees))
        neighbours.append(Rectangle(center: center.right(by: randomValueForCenterMutation()),
                                    width: width, height: height,
                                    angleInDegrees: angleInDegrees))
        neighbours.append(Rectangle(center: center.up(by: randomValueForCenterMutation()),
                                    width: width, height: height,
                                    angleInDegrees: angleInDegrees))
        neighbours.append(Rectangle(center: center.down(by: randomValueForCenterMutation()),
                                    width: width, height: height,
                                    angleInDegrees: angleInDegrees))
        let thinner = width - randomValueForExtentMutation()
        neighbours.append(Rectangle(center: center,
                                    width: thinner, height: height,
                                    angleInDegrees: angleInDegrees))
        let thicker = width + randomValueForExtentMutation()
        neighbours.append(Rectangle(center: center,
                                    width: thicker, height: height,
                                    angleInDegrees: angleInDegrees))
        let flatter = height - randomValueForExtentMutation()
        neighbours.append(Rectangle(center: center,
                                    width: width, height: flatter,
                                    angleInDegrees: angleInDegrees))
        let higher = height + randomValueForExtentMutation()
        neighbours.append(Rectangle(center: center,
                                    width: width, height: higher,
                                    angleInDegrees: angleInDegrees))
        let clockwise = angleInDegreesBetween0And360(angle: angleInDegrees - randomValueForAngleMutation())
        neighbours.append(Rectangle(center: center,
                                    width: width, height: height,
                                    angleInDegrees: clockwise))
        let counterClockwise = angleInDegreesBetween0And360(angle: angleInDegrees + randomValueForAngleMutation())
        neighbours.append(Rectangle(center: center,
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
        return Rectangle(center: center.jiggle(peak: Rectangle.rangeForCenterMutation),
                         width: width, height: height,
                         angleInDegrees: angleInDegrees)
    }

    private func mutatedExtent() -> GeometricShape {
        let mutatedWidth = width
            + 2 * randomValueForExtentMutation()
            - Rectangle.rangeForExtentMutation
        let mutatedHeight = height
            + 2 * randomValueForExtentMutation()
            - Rectangle.rangeForExtentMutation
        return Rectangle(center: center,
                         width: mutatedWidth, height: mutatedHeight,
                         angleInDegrees: angleInDegrees)
    }

    private func mutatedAngle() -> GeometricShape {
        var mutatedAngle = angleInDegrees
            + 2 * randomValueForAngleMutation()
            - Rectangle.rangeForAngleMutation
        if mutatedAngle < 0 {
            mutatedAngle = 360 - mutatedAngle
        } else if mutatedAngle > 360 {
            mutatedAngle -= 360
        }
        return Rectangle(center: center,
                         width: width, height: height,
                         angleInDegrees: mutatedAngle)

    }

    func patienceWithFailedMutations() -> Int {
        return Rectangle.mutationOptions * 3
    }

    func drawInContext(context: UIGraphicsImageRendererContext, usingColour: UIColor) {
        let factor: Double = max(Double(context.currentImage.size.width),
                                 Double(context.currentImage.size.height))

        let pixelCenterX = round(center.x * factor)
        let pixelCenterY = round(center.y * factor)
        let pixelWidth = round(width * factor)
        let pixelHeight = round(height * factor)

        let cgContext = context.cgContext
        cgContext.setFillColor(usingColour.cgColor)
        cgContext.setStrokeColor(UIColor.clear.cgColor)
        cgContext.setLineWidth(0)

        cgContext.saveGState()
        // set context origin to the center of the rectangle
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
