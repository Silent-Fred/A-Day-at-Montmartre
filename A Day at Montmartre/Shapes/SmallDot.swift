//
//  SmallDot.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 16.02.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import UIKit

class SmallDot: GeometricShape {

    static let mutationOptions = 2

    private static let minimumRadius = 0.01
    private static let maximumRadius = 0.05

    private static let rangeForCenterMutation = 0.05
    private static let rangeForRadiusMutation = 0.05

    static func randomShape(frameWidth width: Int, frameHeight height: Int) -> GeometricShape {
        let maxExtent = max(Double(width),
                            Double(height))
        return SmallDot(center: Point(x: drand48() * Double(width) / maxExtent,
                                      y: drand48() * Double(height) / maxExtent),
                        radius: drand48() * (maximumRadius - minimumRadius) + minimumRadius)
    }

    var colour: MontmartreColour

    private var center: Point
    private var radius: Double

    init(center: Point, radius: Double,
         colour: MontmartreColour = MontmartreColour.clear) {
        self.center = center
        self.radius = radius.clamp(between: SmallDot.minimumRadius, and: SmallDot.maximumRadius)
        self.colour = colour
    }

    private func randomValueForCenterMutation() -> Double {
        return drand48() * SmallDot.rangeForCenterMutation
    }

    private func randomValueForRadiusMutation() -> Double {
        return drand48() * SmallDot.rangeForRadiusMutation
    }

    func neighbours() -> [GeometricShape] {
        var neighbours = [GeometricShape]()
        neighbours.append(SmallDot(center: center.left(by: randomValueForCenterMutation()),
                                   radius: radius))
        neighbours.append(SmallDot(center: center.right(by: randomValueForCenterMutation()),
                                   radius: radius))
        neighbours.append(SmallDot(center: center.up(by: randomValueForCenterMutation()),
                                   radius: radius))
        neighbours.append(SmallDot(center: center.down(by: randomValueForCenterMutation()),
                                   radius: radius))
        let smaller =
            (radius - randomValueForRadiusMutation()).clamp(between: SmallDot.minimumRadius,
                                                            and: SmallDot.maximumRadius)
        neighbours.append(SmallDot(center: center, radius: smaller))
        let bigger =
            (radius + randomValueForRadiusMutation()).clamp(between: SmallDot.minimumRadius,
                                                            and: SmallDot.maximumRadius)
        neighbours.append(SmallDot(center: center, radius: bigger))
        return neighbours
    }

    func mutated() -> GeometricShape {
        let whichMutation = arc4random_uniform(UInt32(SmallDot.mutationOptions))
        switch whichMutation {
        case 0:
            return mutatedCenter()
        default:
            return mutatedRadius()
        }
    }

    private func mutatedCenter() -> GeometricShape {
        // move the center around
        return SmallDot(center: center.jiggle(peak: SmallDot.rangeForCenterMutation),
                        radius: radius)
    }

    private func mutatedRadius() -> GeometricShape {
        let mutatedRadius: Double = radius
            + 2 * randomValueForRadiusMutation()
            - SmallDot.rangeForRadiusMutation
        return SmallDot(center: center,
                        radius: mutatedRadius.clamp(between: SmallDot.minimumRadius,
                                                    and: SmallDot.maximumRadius))
    }

    func patienceWithFailedMutations() -> Int {
        // several (random) attempts at mutating all variants
        return Ellipse.mutationOptions * 10
    }

    func drawInContext(context: UIGraphicsImageRendererContext, usingColour: UIColor) {
        let factor: Double = max(Double(context.currentImage.size.width),
                                 Double(context.currentImage.size.height))

        let pixelCenterX = round(center.x * factor)
        let pixelCenterY = round(center.y * factor)
        let pixelRadius = round(radius * factor)

        let cgContext = context.cgContext
        cgContext.setFillColor(usingColour.cgColor)
        cgContext.setStrokeColor(UIColor.clear.cgColor)
        cgContext.setLineWidth(0)

        let boundingRectangleWidth = 2 * pixelRadius
        let boundingRectangleHeight = 2 * pixelRadius
        let boundingRectangle = CGRect(x: pixelCenterX - boundingRectangleWidth / 2,
                                       y: pixelCenterY - boundingRectangleHeight / 2,
                                       width: boundingRectangleWidth,
                                       height: boundingRectangleHeight)
        cgContext.addEllipse(in: boundingRectangle)

        cgContext.drawPath(using: .fill)
    }
}
