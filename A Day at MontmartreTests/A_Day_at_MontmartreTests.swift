//
//  A_Day_at_MontmartreTests.swift
//  A Day at MontmartreTests
//
//  Created by Michael Kühweg on 27.12.17.
//  Copyright © 2017 Michael Kühweg. All rights reserved.
//

import XCTest
@testable import A_Day_at_Montmartre

class A_Day_at_MontmartreTests: XCTestCase {
    
    func testColourAverageInColourCloud() {
        let colourCloud = ColourCloud()
        colourCloud.appendPoint(inColour: MontmartreColour.white)
        colourCloud.appendPoint(inColour: MontmartreColour.white)
        XCTAssertEqual(colourCloud.averageColour().red, 1, accuracy: 0.01)
        XCTAssertEqual(colourCloud.averageColour().green, 1, accuracy: 0.01)
        XCTAssertEqual(colourCloud.averageColour().blue, 1, accuracy: 0.01)
        colourCloud.appendPoint(inColour: MontmartreColour.black)
        colourCloud.appendPoint(inColour: MontmartreColour.black)
        XCTAssertEqual(colourCloud.averageColour().red, 0.7, accuracy: 0.01)
        XCTAssertEqual(colourCloud.averageColour().green, 0.7, accuracy: 0.01)
        XCTAssertEqual(colourCloud.averageColour().blue, 0.7, accuracy: 0.01)
    }
    
    func testClamp() {
        XCTAssertEqual(0.5, 0.5.clamp(between: 0, and: 1))
        XCTAssertEqual(0.7, 0.5.clamp(between: 0.7, and: 1))
        XCTAssertEqual(0.3, 0.5.clamp(between: 0.1, and: 0.3))
    }

    func testPremultipliedAlphaBackAndForth() {
        let transparentBlue = MontmartreColour(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
        let premultiplied = transparentBlue.usingPremultipliedAlpha()
        let fromPremultiplied = MontmartreColour(premultipliedRed: premultiplied.red,
                                                 green: premultiplied.green,
                                                 blue: premultiplied.blue,
                                                 alpha: premultiplied.alpha)
        XCTAssertEqual(transparentBlue.red, fromPremultiplied.red, accuracy: 0.001)
        XCTAssertEqual(transparentBlue.green, fromPremultiplied.green, accuracy: 0.001)
        XCTAssertEqual(transparentBlue.blue, fromPremultiplied.blue, accuracy: 0.001)
        XCTAssertEqual(transparentBlue.alpha, fromPremultiplied.alpha, accuracy: 0.001)
    }

    func testOverpaint() {
        XCTAssertEqual(MontmartreColour.white.overpainted(with: MontmartreColour.blue).red, 0)
        XCTAssertEqual(MontmartreColour.white.overpainted(with: MontmartreColour.blue).green, 0)
        XCTAssertEqual(MontmartreColour.white.overpainted(with: MontmartreColour.blue).blue, 1)

        let transparentBlue = MontmartreColour(red: 0, green: 0, blue: 1, alpha: 0.5)
        XCTAssertEqual(MontmartreColour.white.overpainted(with: transparentBlue).red, 0.5)
        XCTAssertEqual(MontmartreColour.white.overpainted(with: transparentBlue).green, 0.5)
        XCTAssertEqual(MontmartreColour.white.overpainted(with: transparentBlue).blue, 1.0)
        XCTAssertEqual(MontmartreColour.white.overpainted(with: transparentBlue).alpha, 1.0)
    }

    func testRequiredOverpaint() {
        let targetColour = MontmartreColour(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0)
        let requiredOverpaint = MontmartreColour.white.requiredOverpaintToAchieve(targetColour: targetColour,
                                                                                  usingAlpha: 0.5)
        XCTAssertEqual(requiredOverpaint.red, 0, accuracy: 0.001)
        XCTAssertEqual(requiredOverpaint.green, 0, accuracy: 0.001)
        XCTAssertEqual(requiredOverpaint.blue, 1, accuracy: 0.001)
    }

}
