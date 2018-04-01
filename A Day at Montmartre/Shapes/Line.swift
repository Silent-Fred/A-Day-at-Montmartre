//
//  Line.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 17.02.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import UIKit

struct Line: GeometricShape {

    static let mutationOptions = 3

    private static let minimumStroke = 0.01
    private static let maximumStroke = 0.03

    private static let rangeForPointMutation = 0.1
    private static let rangeForStrokeMutation = 0.005

    static func randomShape(frameWidth width: Int, frameHeight height: Int) -> GeometricShape {
        let maxExtent = max(Double(width), Double(height))
        return Line(moveTo: Point(x: drand48() * Double(width) / maxExtent,
                                  y: drand48() * Double(height) / maxExtent),
                    lineTo: Point(x: drand48() * Double(width) / maxExtent,
                                  y: drand48() * Double(height) / maxExtent),
                    stroke: drand48() * (maximumStroke - minimumStroke) + minimumStroke)
    }

    var colour: MontmartreColour

    private var moveTo: Point
    private var lineTo: Point
    private var stroke: Double

    init(moveTo: Point,
         lineTo: Point,
         stroke: Double,
         colour: MontmartreColour = MontmartreColour.clear) {
        self.moveTo = moveTo
        self.lineTo = lineTo
        self.stroke = stroke.clamp(between: Line.minimumStroke, and: Line.maximumStroke)
        self.colour = colour
    }

    private func randomValueForPointMutation() -> Double {
        return drand48() * Line.rangeForPointMutation
    }

    private func randomValueForStrokeMutation() -> Double {
        return drand48() * Ellipse.rangeForCenterMutation
    }

    func neighbours() -> [GeometricShape] {
        var neighbours = [GeometricShape]()

        neighbours.append(Line(moveTo: moveTo.left(by: randomValueForPointMutation()),
                               lineTo: lineTo,
                               stroke: stroke))
        neighbours.append(Line(moveTo: moveTo.right(by: randomValueForPointMutation()),
                               lineTo: lineTo,
                               stroke: stroke))
        neighbours.append(Line(moveTo: moveTo.up(by: randomValueForPointMutation()),
                               lineTo: lineTo,
                               stroke: stroke))
        neighbours.append(Line(moveTo: moveTo.down(by: randomValueForPointMutation()),
                               lineTo: lineTo,
                               stroke: stroke))

        neighbours.append(Line(moveTo: moveTo,
                               lineTo: lineTo.left(by: randomValueForPointMutation()),
                               stroke: stroke))
        neighbours.append(Line(moveTo: moveTo,
                               lineTo: lineTo.right(by: randomValueForPointMutation()),
                               stroke: stroke))
        neighbours.append(Line(moveTo: moveTo,
                               lineTo: lineTo.up(by: randomValueForPointMutation()),
                               stroke: stroke))
        neighbours.append(Line(moveTo: moveTo,
                               lineTo: lineTo.down(by: randomValueForPointMutation()),
                               stroke: stroke))

        let thinner =
            (stroke - randomValueForStrokeMutation()).clamp(between: Line.minimumStroke,
                                                            and: Line.maximumStroke)
        neighbours.append(Line(moveTo: moveTo, lineTo: lineTo,
                               stroke: thinner))
        let thicker =
            (stroke + randomValueForStrokeMutation()).clamp(between: Line.minimumStroke,
                                                            and: Line.maximumStroke)
        neighbours.append(Line(moveTo: moveTo, lineTo: lineTo,
                               stroke: thicker))

        return neighbours
    }

    func mutated() -> GeometricShape {
        let whichMutation = arc4random_uniform(UInt32(SmallDot.mutationOptions))
        switch whichMutation {
        case 0:
            return mutatedMoveTo()
        case 0:
            return mutatedLineTo()
        default:
            return mutatedStroke()
        }

    }

    private func mutatedMoveTo() -> GeometricShape {
        return Line(moveTo: moveTo.jiggle(peak: Line.rangeForPointMutation),
                    lineTo: lineTo,
                    stroke: stroke)
    }

    private func mutatedLineTo() -> GeometricShape {
        return Line(moveTo: moveTo,
                    lineTo: lineTo.jiggle(peak: Line.rangeForPointMutation),
                    stroke: stroke)
    }

    private func mutatedStroke() -> GeometricShape {
        let mutatedStroke = stroke
            + 2 * drand48() * Line.rangeForStrokeMutation
            - Line.rangeForStrokeMutation
        return Line(moveTo: moveTo,
                    lineTo: lineTo,
                    stroke: mutatedStroke.clamp(between: Line.minimumStroke, and: Line.maximumStroke))
    }

    func patienceWithFailedMutations() -> Int {
        return Line.mutationOptions * 10
    }

    func drawInContext(context: UIGraphicsImageRendererContext, usingColour: UIColor) {
        let factor: Double = max(Double(context.currentImage.size.width),
                                 Double(context.currentImage.size.height))

        let pixelMoveToX = round(moveTo.x * factor)
        let pixelMoveToY = round(moveTo.y * factor)
        let pixelLineToX = round(lineTo.x * factor)
        let pixelLineToY = round(lineTo.y * factor)
        let pixelStroke = round(stroke * factor).clamp(between: 1, and: Line.maximumStroke * factor)

        let cgContext = context.cgContext

        cgContext.setStrokeColor(usingColour.cgColor)
        cgContext.setLineWidth(CGFloat(pixelStroke))

        cgContext.move(to: CGPoint(x: pixelMoveToX, y: pixelMoveToY))
        cgContext.addLine(to: CGPoint(x: pixelLineToX, y: pixelLineToY))

        cgContext.drawPath(using: .stroke)
    }
}
