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

    var testImage: UIImage?

    override func setUp() {
        super.setUp()
        testImage = UIImage(named: "Example")
    }

    override func tearDown() {
        super.tearDown()
    }

    func testBasicEvolutionaryHillClimbing() {
        let approximator = BasicEvolutionaryApproximator(imageToApproximate: testImage!,
                                                         using: ShapeStyle.ellipses)
        self.measure {
            approximator.refineApproximation()
        }
    }

    func testPerformanceHillClimbing() {
        let approximator = HillClimbApproximator(imageToApproximate: testImage!,
                                                 using: ShapeStyle.ellipses)
        self.measure {
            approximator.refineApproximation()
        }
    }

    func testPerformanceStochasticHillClimbing() {
        let approximator = StochasticHillClimbApproximator(imageToApproximate: testImage!,
                                                           using: ShapeStyle.ellipses)
        self.measure {
            approximator.refineApproximation()
        }
    }
}
