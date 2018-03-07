//
//  HillClimbApproximator.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 28.01.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import UIKit

class HillClimbApproximator: Approximator {

    private let attemptedClimbers = 8

    override func refineApproximation() {

        guard let context = context else { return }

        var bestAttempt = hillClimbStartingWithRandomShape()
        for _ in 1...attemptedClimbers {
            let climber = hillClimbStartingWithRandomShape()
            if climber.improvement > bestAttempt.improvement {
                bestAttempt = climber
            }
        }
        if bestAttempt.improvement > 0.0 {
            context.append(shape: bestAttempt.shape)
        }
    }

    private func hillClimbStartingWithRandomShape()
        -> (shape: GeometricShape, improvement: Double) {
            return hillClimb(startingWith: randomShape())
    }

    private func hillClimb(startingWith: GeometricShape) -> (shape: GeometricShape, improvement: Double) {

        var mutatingShape = startingWith
        var bestImprovement = tintShapeAndCalculateImprovement(shape: &mutatingShape)
        var bestShape = mutatingShape
        var failedAttemptsInARow = 0
        while failedAttemptsInARow < 2 {
            failedAttemptsInARow += 1
            autoreleasepool {
                for var shape in bestShape.neighbours() {
                    let improvement = tintShapeAndCalculateImprovement(shape: &shape)
                    if improvement > bestImprovement {
                        bestImprovement = improvement
                        bestShape = shape
                        failedAttemptsInARow = 0
                    }
                }
            }
        }
        return (bestShape, bestImprovement)
    }

}
