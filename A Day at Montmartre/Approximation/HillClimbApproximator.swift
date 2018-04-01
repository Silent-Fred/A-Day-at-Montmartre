//
//  HillClimbApproximator.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 28.01.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import UIKit

class HillClimbApproximator: Approximator {

    private let tolerateFailedAttempsInARow = 2

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

    private func hillClimb(startingWith: GeometricShape)
        -> (shape: GeometricShape, improvement: Double) {

        var bestImprovement = calculateImprovement(shape: startingWith)
        var failedAttemptsInARow = 0
        while failedAttemptsInARow < tolerateFailedAttempsInARow {
            failedAttemptsInARow += 1
            autoreleasepool {
                for neighbour in bestImprovement.shape.neighbours() {
                    let improvement = calculateImprovement(shape: neighbour)
                    if improvement.improvement > bestImprovement.improvement {
                        bestImprovement = improvement
                        failedAttemptsInARow = 0
                    }
                }
            }
        }
        return bestImprovement
    }

}
