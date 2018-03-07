//
//  ShapeMaskTests.swift
//  A Day at MontmartreTests
//
//  Created by Michael Kühweg on 27.01.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import XCTest
@testable import A_Day_at_Montmartre

class ShapeMaskTests: XCTestCase {

    func testMaskWithShape() {
        let edgeLength = 256.0
        let radius = 0.5
        let pixelRadiusUpperBound = edgeLength * radius + 1
        let pixelRadiusLowerBound = edgeLength * radius - 1
        let shape = Ellipse(center: Point(x: 0.5, y: 0.5),
                            radiusX: radius,
                            radiusY: radius,
                            angleInDegrees: 0.0)
        let mask = ShapeMask(width: Int(edgeLength), height: Int(edgeLength))
        let indices = mask.maskedPixelIndices(shape: shape)
        let upperBound = Double.pi * pixelRadiusUpperBound * pixelRadiusUpperBound
        let lowerBound = Double.pi * pixelRadiusLowerBound * pixelRadiusLowerBound
        XCTAssertTrue(Double(indices.count) > lowerBound)
        XCTAssertTrue(Double(indices.count) < upperBound)
    }

    func testMaskWithShapeIsClearedBetweenShapes() {
        let edgeLength = 256.0
        let mask = ShapeMask(width: Int(edgeLength), height: Int(edgeLength))
        let radius = 0.25
        let shapeTopLeft = Ellipse(center: Point(x: 0.25, y: 0.25),
                            radiusX: radius,
                            radiusY: radius,
                            angleInDegrees: 0.0)
        let countIndicesTopLeft = mask.maskedPixelIndices(shape: shapeTopLeft).count
        let shapeBottomRight = Ellipse(center: Point(x: 0.75, y: 0.75),
                                   radiusX: radius,
                                   radiusY: radius,
                                   angleInDegrees: 0.0)
        let countIndicesBottomRight = mask.maskedPixelIndices(shape: shapeBottomRight).count
        // antialiasing and recalculation of normalized to real coordinates might lead to
        // slightly different results depending on edge lengths, therefore no exact
        // matching but regarding a certain range
        let pixelRadiusUpperBound = edgeLength * radius + 1
        let pixelRadiusLowerBound = edgeLength * radius - 1
        let upperBound = Double.pi * pixelRadiusUpperBound * pixelRadiusUpperBound
        let lowerBound = Double.pi * pixelRadiusLowerBound * pixelRadiusLowerBound
        XCTAssertEqual(Double(countIndicesTopLeft),
                       Double(countIndicesBottomRight),
                       accuracy: Double.pi * (upperBound - lowerBound))
    }
}
