//
//  Triangle.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 18.02.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import UIKit

class Triangle: GeometricShape {
    
    static let mutationOptions = 3

    private static let rangeForPointMutation = 0.1

    static func randomShape(frameWidth width: Int, frameHeight height: Int) -> GeometricShape {
        let maxExtent = max(Double(width), Double(height))
        let pointA = Point(x: drand48() * Double(width) / maxExtent,
                           y: drand48() * Double(height) / maxExtent)
        let pointB = Point(x: drand48() * Double(width) / maxExtent,
                           y: drand48() * Double(height) / maxExtent)
        let pointC = Point(x: drand48() * Double(width) / maxExtent,
                           y: drand48() * Double(height) / maxExtent)
        return Triangle(pointA: pointA, pointB: pointB, pointC: pointC)
    }
    
    var colour: MontmartreColour
    
    public private (set) var pointA: Point
    public private (set) var pointB: Point
    public private (set) var pointC: Point

    init(pointA: Point,
         pointB: Point,
         pointC: Point,
         colour: MontmartreColour = MontmartreColour.clear) {
        self.pointA = pointA
        self.pointB = pointB
        self.pointC = pointC
        self.colour = colour
    }

    private func randomValueForPointMutation() -> Double {
        return drand48() * Triangle.rangeForPointMutation
    }

    func neighbours() -> [GeometricShape] {
        var neighbours = [GeometricShape]()

        neighbours.append(Triangle(pointA: pointA.left(by: randomValueForPointMutation()),
                                   pointB: pointB,
                                   pointC: pointC))
        neighbours.append(Triangle(pointA: pointA.right(by: randomValueForPointMutation()),
                                   pointB: pointB,
                                   pointC: pointC))
        neighbours.append(Triangle(pointA: pointA.up(by: randomValueForPointMutation()),
                                   pointB: pointB,
                                   pointC: pointC))
        neighbours.append(Triangle(pointA: pointA.down(by: randomValueForPointMutation()),
                                   pointB: pointB,
                                   pointC: pointC))

        neighbours.append(Triangle(pointA: pointA,
                                   pointB: pointB.left(by: randomValueForPointMutation()),
                                   pointC: pointC))
        neighbours.append(Triangle(pointA: pointA,
                                   pointB: pointB.right(by: randomValueForPointMutation()),
                                   pointC: pointC))
        neighbours.append(Triangle(pointA: pointA,
                                   pointB: pointB.up(by: randomValueForPointMutation()),
                                   pointC: pointC))
        neighbours.append(Triangle(pointA: pointA,
                                   pointB: pointB.down(by: randomValueForPointMutation()),
                                   pointC: pointC))

        neighbours.append(Triangle(pointA: pointA,
                                   pointB: pointB,
                                   pointC: pointC.left(by: randomValueForPointMutation())))
        neighbours.append(Triangle(pointA: pointA,
                                   pointB: pointB,
                                   pointC: pointC.right(by: randomValueForPointMutation())))
        neighbours.append(Triangle(pointA: pointA,
                                   pointB: pointB,
                                   pointC: pointC.up(by: randomValueForPointMutation())))
        neighbours.append(Triangle(pointA: pointA,
                                   pointB: pointB,
                                   pointC: pointC.down(by: randomValueForPointMutation())))

        return neighbours
    }
    
    func mutated() -> GeometricShape {
        let whichPoint = arc4random_uniform(UInt32(Triangle.mutationOptions))
        switch whichPoint {
        case 0:
            return Triangle(pointA: pointA.jiggle(peak: Triangle.rangeForPointMutation),
                            pointB: pointB,
                            pointC: pointC)
        case 1:
            return Triangle(pointA: pointA,
                            pointB: pointB.jiggle(peak: Triangle.rangeForPointMutation),
                            pointC: pointC)
        default:
            return Triangle(pointA: pointA,
                            pointB: pointB,
                            pointC: pointC.jiggle(peak: Triangle.rangeForPointMutation))
        }
    }
    
    func patienceWithFailedMutations() -> Int {
        // several (random) attempts at mutating all variants
        return Triangle.mutationOptions * 10
    }
    
    func drawInContext(context: UIGraphicsImageRendererContext) {
        drawInContext(context: context, usingColour: colour.uiColor())
    }
    
    func drawInContext(context: UIGraphicsImageRendererContext, usingColour: UIColor) {
        let factor: Double = max(Double(context.currentImage.size.width),
                                 Double(context.currentImage.size.height))

        let pixelPointAX = round(pointA.x * factor)
        let pixelPointAY = round(pointA.y * factor)
        let pixelPointBX = round(pointB.x * factor)
        let pixelPointBY = round(pointB.y * factor)
        let pixelPointCX = round(pointC.x * factor)
        let pixelPointCY = round(pointC.y * factor)

        let cgContext = context.cgContext

        cgContext.setStrokeColor(usingColour.cgColor)
        cgContext.setFillColor(usingColour.cgColor)
        cgContext.setLineWidth(CGFloat(1))

        cgContext.move(to: CGPoint(x: pixelPointAX, y: pixelPointAY))
        cgContext.addLine(to: CGPoint(x: pixelPointBX, y: pixelPointBY))
        cgContext.addLine(to: CGPoint(x: pixelPointCX, y: pixelPointCY))

        cgContext.drawPath(using: .fillStroke)
    }
}
