//
//  Double+Orbit.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 03.05.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import Foundation

extension Double {

    func orbit(_ orbit: Int) -> (x: Double, y: Double) {

        guard orbit > 0 else { return (0.0, 0.0) }

        let orbitDivisor = pow(Double(10.0), Double(orbit))
        let orbitValue = 2.0 * Double.pi
            * (self / orbitDivisor).remainder(dividingBy: Double(1.0))
        // rotate to start at the more common "twelve o'clock" position
        let rotatedOrbitValue = orbitValue - Double.pi / 2
        let x = cos(rotatedOrbitValue)
        let y = sin(rotatedOrbitValue)
        return (x, y)
    }
}
