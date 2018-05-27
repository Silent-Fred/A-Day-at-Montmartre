//
//  QuadCurve.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 19.05.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import UIKit

struct QuadCurve: GeometricShape {

    private static let strokeInPoints = 3.0
    private static let rangeForPointMutation = 0.05

    static func randomShape(frameWidth width: Int, frameHeight height: Int) -> GeometricShape {
        let maxExtent = max(Double(width), Double(height))
        return QuadCurve(moveTo: Point(x: drand48() * Double(width) / maxExtent,
                                       y: drand48() * Double(height) / maxExtent),
                         lineTo: Point(x: drand48() * Double(width) / maxExtent,
                                       y: drand48() * Double(height) / maxExtent),
                         control: Point(x: drand48() * Double(width) / maxExtent,
                                        y: drand48() * Double(height) / maxExtent))
    }

    var colour: MontmartreColour

    private let moveTo: Point
    private let lineTo: Point
    private let control: Point

    init(moveTo: Point,
         lineTo: Point,
         control: Point,
         colour: MontmartreColour = MontmartreColour.clear) {
        self.moveTo = moveTo
        self.lineTo = lineTo
        self.control = control
        self.colour = colour
    }

    private func randomValueForPointMutation() -> Double {
        return drand48() * QuadCurve.rangeForPointMutation
    }

    func neighbours() -> [GeometricShape] {
        var neighbours = [GeometricShape]()

        neighbours.append(QuadCurve(moveTo: moveTo.left(by: randomValueForPointMutation()),
                                    lineTo: lineTo,
                                    control: control))
        neighbours.append(QuadCurve(moveTo: moveTo.right(by: randomValueForPointMutation()),
                                    lineTo: lineTo,
                                    control: control))
        neighbours.append(QuadCurve(moveTo: moveTo.up(by: randomValueForPointMutation()),
                                    lineTo: lineTo,
                                    control: control))
        neighbours.append(QuadCurve(moveTo: moveTo.down(by: randomValueForPointMutation()),
                                    lineTo: lineTo,
                                    control: control))

        neighbours.append(QuadCurve(moveTo: moveTo,
                                    lineTo: lineTo.left(by: randomValueForPointMutation()),
                                    control: control))
        neighbours.append(QuadCurve(moveTo: moveTo,
                                    lineTo: lineTo.right(by: randomValueForPointMutation()),
                                    control: control))
        neighbours.append(QuadCurve(moveTo: moveTo,
                                    lineTo: lineTo.up(by: randomValueForPointMutation()),
                                    control: control))
        neighbours.append(QuadCurve(moveTo: moveTo,
                                    lineTo: lineTo.down(by: randomValueForPointMutation()),
                                    control: control))

        neighbours.append(QuadCurve(moveTo: moveTo,
                                    lineTo: lineTo,
                                    control: control.left(by: randomValueForPointMutation())))
        neighbours.append(QuadCurve(moveTo: moveTo,
                                    lineTo: lineTo,
                                    control: control.right(by: randomValueForPointMutation())))
        neighbours.append(QuadCurve(moveTo: moveTo,
                                    lineTo: lineTo,
                                    control: control.up(by: randomValueForPointMutation())))
        neighbours.append(QuadCurve(moveTo: moveTo,
                                    lineTo: lineTo,
                                    control: control.down(by: randomValueForPointMutation())))

        return neighbours
    }

    func mutated() -> GeometricShape {
        var points = [moveTo, lineTo, control]
        let whichPoint = Int(arc4random_uniform(UInt32(points.count)))
        points[whichPoint] = points[whichPoint].jiggle(peak: QuadCurve.rangeForPointMutation)
        return QuadCurve(moveTo: points[0], lineTo: points[1], control: points[2])
    }

    func patienceWithFailedMutations() -> Int {
        return 3 * 10
    }

    func drawInContext(context: UIGraphicsImageRendererContext, usingColour: UIColor) {
        let factor: Double = max(Double(context.currentImage.size.width),
                                 Double(context.currentImage.size.height))

        let pixelMoveToX = round(moveTo.x * factor)
        let pixelMoveToY = round(moveTo.y * factor)
        let pixelLineToX = round(lineTo.x * factor)
        let pixelLineToY = round(lineTo.y * factor)
        let pixelControlX = round(control.x * factor)
        let pixelControlY = round(control.y * factor)
        let pixelStroke = round(QuadCurve.strokeInPoints * factor)
            .clamp(between: 1, and: QuadCurve.strokeInPoints)

        let cgContext = context.cgContext

        cgContext.setStrokeColor(usingColour.cgColor)
        cgContext.setLineWidth(CGFloat(pixelStroke))

        cgContext.move(to: CGPoint(x: pixelMoveToX, y: pixelMoveToY))
        cgContext.addQuadCurve(to: CGPoint(x: pixelLineToX, y: pixelLineToY),
                               control: CGPoint(x: pixelControlX, y: pixelControlY))

        cgContext.drawPath(using: .stroke)
    }
}
