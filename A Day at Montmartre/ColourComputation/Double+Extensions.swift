//
//  Double+Extensions.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 28.12.17.
//  Copyright © 2017 Michael Kühweg. All rights reserved.
//

import Foundation

extension Double {

    func clamp(between lowerBound: Double, and upperBound: Double) -> Double {
        return max(lowerBound, min(self, upperBound))
    }

}
