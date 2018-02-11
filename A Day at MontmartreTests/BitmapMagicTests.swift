//
//  BitmapMagicTests.swift
//  A Day at MontmartreTests
//
//  Created by Michael Kühweg on 14.01.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import XCTest
@testable import A_Day_at_Montmartre

class BitmapMagicTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testResultingColourOnTransparentBackground() {
        let transparentBlue = MontmartreColour(red: 0, green: 0, blue: 1, alpha: 0.5)
        let transparent = TestImageProvider.colourQuadrantsOnTransparentBackground(
            edgeLength: 256,
            coloursInQuadrants: [transparentBlue,
                                 transparentBlue,
                                 transparentBlue,
                                 transparentBlue])
        let approximationContext = ApproximationContext(originalImage: transparent)
        let targetImage = approximationContext?.targetImage
        let cloud =
            BitmapMagic(forImage: (targetImage?.cgImage)!).colourCloud(maskedByPixelIndices: [0])
        let colour = cloud.colourOfPoint(withIndex: 0)
        XCTAssertEqual(colour.red, 0.0, accuracy: 0.01)
        XCTAssertEqual(colour.green, 0.0, accuracy: 0.01)
        XCTAssertEqual(colour.blue, 1.0, accuracy: 0.01)
        XCTAssertEqual(colour.alpha, 0.5, accuracy: 0.01)
    }
    
    func testResultingColourOnWhiteBackground() {
        let transparentBlue = MontmartreColour(red: 0, green: 0, blue: 1, alpha: 0.5)
        let transparent = TestImageProvider.colourQuadrants(
            edgeLength: 256,
            backgroundColour: MontmartreColour.white,
            coloursInQuadrants: [transparentBlue,
                                 transparentBlue,
                                 transparentBlue,
                                 transparentBlue])
        let approximationContext = ApproximationContext(originalImage: transparent)
        let targetImage = approximationContext?.targetImage
        let cloud =
            BitmapMagic(forImage: (targetImage?.cgImage)!).colourCloud(maskedByPixelIndices: [0])
        let colour = cloud.colourOfPoint(withIndex: 0)
        XCTAssertEqual(colour.red, 0.5, accuracy: 0.01)
        XCTAssertEqual(colour.green, 0.5, accuracy: 0.01)
        XCTAssertEqual(colour.blue, 1.0, accuracy: 0.01)
        XCTAssertEqual(colour.alpha, 1.0, accuracy: 0.01)
    }
    
    func testColourFromSingleLayerOpaque() {
        let image = TestImageProvider.colourQuadrantsOnTransparentBackground(
            edgeLength: 256,
            coloursInQuadrants: [MontmartreColour.blue,
                                 MontmartreColour.blue,
                                 MontmartreColour.blue,
                                 MontmartreColour.blue])
        let approximationContext = ApproximationContext(originalImage: image)
        let targetImage = approximationContext?.targetImage
        let colourCloud =
            BitmapMagic(forImage: (targetImage?.cgImage)!).colourCloud(maskedByPixelIndices: [0])
        let colour = colourCloud.colourOfPoint(withIndex: 0)

        XCTAssertEqual(colour.red, 0.0, accuracy: 0.01)
        XCTAssertEqual(colour.green, 0.0, accuracy: 0.01)
        XCTAssertEqual(colour.blue, 1.0, accuracy: 0.01)
        XCTAssertEqual(colour.alpha, 1.0, accuracy: 0.01)
    }

    func testColourFromDoubleLayer() {
        let transparentBlue = MontmartreColour(red: 0, green: 0, blue: 1, alpha: 0.5)
        let image = TestImageProvider.colourQuadrantsOnTransparentBackground(
            edgeLength: 256,
            coloursInQuadrants: [transparentBlue,
                                 transparentBlue,
                                 transparentBlue,
                                 transparentBlue,
                                 transparentBlue,
                                 transparentBlue,
                                 transparentBlue,
                                 transparentBlue])
        let approximationContext = ApproximationContext(originalImage: image)
        let targetImage = approximationContext?.targetImage
        let colourCloud =
            BitmapMagic(forImage: (targetImage?.cgImage)!).colourCloud(maskedByPixelIndices: [0])
        let colour = colourCloud.colourOfPoint(withIndex: 0)
        
        XCTAssertEqual(colour.red, 0.0, accuracy: 0.01)
        XCTAssertEqual(colour.green, 0.0, accuracy: 0.01)
        XCTAssertEqual(colour.blue, 1.0, accuracy: 0.01)
        XCTAssertEqual(colour.alpha, 0.75, accuracy: 0.01)
    }
    
    func testAverageColour() {
        let image = TestImageProvider.colourQuadrantsOnTransparentBackground(
            edgeLength: 256,
            coloursInQuadrants: [MontmartreColour.blue,
                                 MontmartreColour.white,
                                 MontmartreColour.blue,
                                 MontmartreColour.white])
        let approximationContext = ApproximationContext(originalImage: image)
        let targetImage = approximationContext?.targetImage
        let mask = ShapeMask(width: (targetImage?.cgImage?.width)!,
                             height: (targetImage?.cgImage?.height)!)
        let unmasked = mask.unmaskedPixelIndices()
        let colourCloud =
            BitmapMagic(forImage: (targetImage?.cgImage)!
                ).colourCloud(maskedByPixelIndices: unmasked)
        let average = colourCloud.averageColour()
        
        XCTAssertEqual(average.red, 0.7, accuracy: 0.01)
        XCTAssertEqual(average.green, 0.7, accuracy: 0.01)
        XCTAssertEqual(average.blue, 1.0, accuracy: 0.01)
        XCTAssertEqual(average.alpha, 1.0, accuracy: 0.01)
    }
    
    private func colourCloudsForDeviationTests(_ shape: GeometricShape)
        -> (blueStriped: ColourCloud, plainWhite: ColourCloud) {
            let edgeLength = 256.0
            let target = TestImageProvider.colourQuadrants(edgeLength: Int(edgeLength),
                                                           backgroundColour: MontmartreColour.white,
                                                           coloursInQuadrants: [MontmartreColour.blue,
                                                                                MontmartreColour.blue])
            let white = TestImageProvider.colourQuadrants(edgeLength: Int(edgeLength),
                                                          backgroundColour: MontmartreColour.white,
                                                          coloursInQuadrants: [])
            
            let targetBitmap = BitmapMagic(forImage: target.cgImage!)
            let whiteBitmap = BitmapMagic(forImage: white.cgImage!)
            
            let mask = ShapeMask(width: Int(edgeLength), height: Int(edgeLength))
            let indices = mask.maskedPixelIndices(shape: shape)
            
            let targetColourCloud = targetBitmap.colourCloud(maskedByPixelIndices: indices)
            let whiteColourCloud = whiteBitmap.colourCloud(maskedByPixelIndices: indices)
            
            return (targetColourCloud, whiteColourCloud)
    }
    
    func testMeanSquareDeviationBasedOnShape() {
        let shapeInTheBlue = Ellipse(centerX: 0.5,
                                     centerY: 0.25,
                                     radiusX: 0.24,
                                     radiusY: 0.12,
                                     angleInDegrees: 0.0)
        let shapeInTheWhite = Ellipse(centerX: 0.5,
                                      centerY: 0.75,
                                      radiusX: 0.24,
                                      radiusY: 0.12,
                                      angleInDegrees: 0.0)
        let shapeAcrossColourBorder = Ellipse(centerX: 0.5,
                                              centerY: 0.5,
                                              radiusX: 0.25,
                                              radiusY: 0.25,
                                              angleInDegrees: 0.0)
        
        let whiteClouds = colourCloudsForDeviationTests(shapeInTheWhite)
        XCTAssertEqual(whiteClouds.blueStriped.meanSquareDeviationFrom(target: whiteClouds.plainWhite),
                       0.0,
                       accuracy: 0.0001)
        let blueClouds = colourCloudsForDeviationTests(shapeInTheBlue)
        XCTAssertEqual(blueClouds.blueStriped.meanSquareDeviationFrom(target: blueClouds.plainWhite),
                       2.0,
                       accuracy: 0.0001)
        let crossCloudsSmall = colourCloudsForDeviationTests(shapeAcrossColourBorder)
        XCTAssertEqual(crossCloudsSmall.blueStriped.meanSquareDeviationFrom(target: crossCloudsSmall.plainWhite),
                       1.0,
                       accuracy: 0.0001)
    }
    
}
