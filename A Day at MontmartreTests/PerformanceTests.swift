//
//  PerformanceTests.swift
//  A Day at MontmartreTests
//
//  Created by Michael Kühweg on 30.01.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import XCTest
@testable import A_Day_at_Montmartre

class PerformanceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceWithIndices() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            let mask = ShapeMask(width: 256, height: 256)
            let shape = Ellipse(center: Point(x: 0.5, y: 0.5),
                                radiusX: 0.25, radiusY: 0.3,
                                angleInDegrees: 0.0)
            for _ in 1...100 {
                mask.maskedPixelIndices(shape: shape)
            }
        }
    }
}
