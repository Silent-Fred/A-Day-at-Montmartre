//
//  ApproximationTests.swift
//  A Day at MontmartreTests
//
//  Created by Michael Kühweg on 21.01.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import XCTest
@testable import A_Day_at_Montmartre

class ApproximationTests: XCTestCase {

    func testSquareDeviation() {
        let colourCloudBlue = ColourCloud()
        colourCloudBlue.appendPoint(inColour: MontmartreColour.blue)
        let colourCloudWhite = ColourCloud()
        colourCloudWhite.appendPoint(inColour: MontmartreColour.white)
        XCTAssertEqual(colourCloudBlue.deviationFrom(target: colourCloudBlue), 0)
        XCTAssertEqual(colourCloudBlue.deviationFrom(target: colourCloudWhite),
                       colourCloudWhite.deviationFrom(target: colourCloudBlue))
        XCTAssertEqual(colourCloudBlue.deviationFrom(target: colourCloudWhite),
                       2.0,
                       accuracy: 0.1)
        colourCloudBlue.appendPoint(inColour: MontmartreColour.blue)
        colourCloudWhite.appendPoint(inColour: MontmartreColour.white)
        XCTAssertEqual(colourCloudBlue.deviationFrom(target: colourCloudWhite),
                       4.0,
                       accuracy: 0.1)
    }

    func testMeanSquareDeviation() {
        let colourCloudBlue = ColourCloud()
        colourCloudBlue.appendPoint(inColour: MontmartreColour.blue)
        let colourCloudWhite = ColourCloud()
        colourCloudWhite.appendPoint(inColour: MontmartreColour.white)
        XCTAssertEqual(colourCloudBlue.meanDeviationFrom(target: colourCloudBlue), 0)
        XCTAssertEqual(colourCloudBlue.meanDeviationFrom(target: colourCloudWhite),
                       colourCloudWhite.meanDeviationFrom(target: colourCloudBlue))
        XCTAssertEqual(colourCloudBlue.meanDeviationFrom(target: colourCloudWhite),
                       2.0,
                       accuracy: 0.1)
        colourCloudBlue.appendPoint(inColour: MontmartreColour.blue)
        colourCloudWhite.appendPoint(inColour: MontmartreColour.white)
        XCTAssertEqual(colourCloudBlue.meanDeviationFrom(target: colourCloudWhite),
                       2.0,
                       accuracy: 0.1)
    }

    func testSquareDifferenceInImage() {
        let edgeLength = 256.0
        let white = TestImageProvider.colourQuadrants(edgeLength: Int(edgeLength),
                                                      backgroundColour: MontmartreColour.white,
                                                      coloursInQuadrants: [])
        let blue = TestImageProvider.colourQuadrants(edgeLength: Int(edgeLength),
                                                      backgroundColour: MontmartreColour.blue,
                                                      coloursInQuadrants: [])
        let bitmapWhite = BitmapMagic(forImage: white.cgImage!)
        let bitmapBlue = BitmapMagic(forImage: blue.cgImage!)

        let mask = ShapeMask(width: Int(edgeLength), height: Int(edgeLength))

        let shapeInTheBlue = Ellipse(center: Point(x: 0.25, y: 0.25),
                                     radiusX: 0.25, radiusY: 0.25, angleInDegrees: 0.0)

        let blueCloud = bitmapBlue.colourCloud(maskedByPixelIndices: mask.maskedPixelIndices(shape: shapeInTheBlue))
        let whiteCloud = bitmapWhite.colourCloud(maskedByPixelIndices: mask.maskedPixelIndices(shape: shapeInTheBlue))
        let distance = MontmartreColour.blue.distance(to: MontmartreColour.white)
        XCTAssertEqual(blueCloud.deviationFrom(target: whiteCloud),
                       Double(blueCloud.count) * distance * distance,
                       accuracy: 0.001)
        let overpaintedBlueCloud = whiteCloud.overpainted(withColour: MontmartreColour.blue)
        XCTAssertEqual(blueCloud.deviationFrom(target: overpaintedBlueCloud),
                       0,
                       accuracy: 0.1)
    }
}
