//
//  Point.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 18.02.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import Foundation

struct Point {

    // swiftlint:disable identifier_name
    let x: Double
    let y: Double

    // MARK: neighbours
    func left(by: Double) -> Point {
        return Point(x: x - by, y: y)
    }
    func right(by: Double) -> Point {
        return Point(x: x + by, y: y)
    }
    func up(by: Double) -> Point {
        return Point(x: x, y: y - by)
    }
    func down(by: Double) -> Point {
        return Point(x: x, y: y + by)
    }

    func jiggle(peak: Double) -> Point {
        let jiggleX = x + (drand48() * peak * 2) - peak
        let jiggleY = y + (drand48() * peak * 2) - peak
        return Point(x: jiggleX, y: jiggleY)
    }
}
