//
//  ShapeFactory.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 05.04.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import Foundation

class ShapeFactory {
    static func randomShape(_ shapeStyle: ShapeStyle,
                            screenRatioWidth width: Int,
                            toHeight height: Int) -> GeometricShape {

        switch shapeStyle {
        case .rectangles:
            return Rectangle.randomShape(frameWidth: width, frameHeight: height)
        case .smallDots:
            return SmallDot.randomShape(frameWidth: width, frameHeight: height)
        case .lines:
            return Line.randomShape(frameWidth: width, frameHeight: height)
        case .triangles:
            return Triangle.randomShape(frameWidth: width, frameHeight: height)
        case .quadCurve:
            return QuadCurve.randomShape(frameWidth: width, frameHeight: height)
        default:
            return Ellipse.randomShape(frameWidth: width, frameHeight: height)
        }
    }
}
