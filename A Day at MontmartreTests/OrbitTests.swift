//
//  OrbitTests.swift
//  A Day at MontmartreTests
//
//  Created by Michael Kühweg on 06.05.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import XCTest
@testable import A_Day_at_Montmartre

class OrbitTests: XCTestCase {

    func testOrbits() {

        let top = (0.0).orbit(1)
        XCTAssertEqual(top.x, 0.0, accuracy: 0.001)
        XCTAssertEqual(top.y, -1.0, accuracy: 0.001)

        let right = (2.5).orbit(1)
        XCTAssertEqual(right.x, 1.0, accuracy: 0.001)
        XCTAssertEqual(right.y, 0.0, accuracy: 0.001)

        let bottom = (5.0).orbit(1)
        XCTAssertEqual(bottom.x, 0.0, accuracy: 0.001)
        XCTAssertEqual(bottom.y, 1.0, accuracy: 0.001)

        let left = (7.5).orbit(1)
        XCTAssertEqual(left.x, -1.0, accuracy: 0.001)
        XCTAssertEqual(left.y, 0.0, accuracy: 0.001)

        XCTAssertEqual((750.0).orbit(2).x, 0.0, accuracy: 0.001)
        XCTAssertEqual((750.0).orbit(2).y, 1.0, accuracy: 0.001)
        XCTAssertEqual((750.0).orbit(3).x, -1.0, accuracy: 0.001)
        XCTAssertEqual((750.0).orbit(3).y, 0.0, accuracy: 0.001)

        XCTAssertEqual((750.0).orbit(0).x, 0.0, accuracy: 0.001)
        XCTAssertEqual((750.0).orbit(0).y, 0.0, accuracy: 0.001)
    }

}
