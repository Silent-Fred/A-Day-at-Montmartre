//
//  BasicGeneticApproximator.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 28.01.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import UIKit

class BasicGeneticApproximator: Approximator {

    private let attemptedShapes = 8
    private let acceptedFailuresPerShape = 100

    override func refineApproximation() {

        guard let context = context else { return }

        var bestAttempt = basicGeneticWithRandomShape()
        for _ in 1...attemptedShapes {
            let climber = basicGeneticWithRandomShape()
            if climber.improvement > bestAttempt.improvement {
                bestAttempt = climber
            }
        }
        if (bestAttempt.improvement > 0.0) {
            context.append(shape: bestAttempt.shape)
        }
    }

    private func basicGeneticWithRandomShape() -> (shape: GeometricShape, improvement: Double) {
        return basicGenetic(startingWith: randomShape())
    }

    private func basicGenetic(startingWith: GeometricShape)
        -> (shape: GeometricShape, improvement: Double) {

            var mutatingShape = startingWith
            var bestImprovement = 0.0
            var bestShape = startingWith
            var failuresLeft = acceptedFailuresPerShape
            var failedAttemptsInARow = 0
            while failuresLeft > 0
                && failedAttemptsInARow < startingWith.patienceWithFailedMutations() {
                    let improvement = tintShapeAndCalculateImprovement(shape: &mutatingShape)
                    if improvement > bestImprovement {
                        bestImprovement = improvement
                        bestShape = mutatingShape
                        failedAttemptsInARow = 0
                    } else {
                        failuresLeft -= 1
                        failedAttemptsInARow += 1
                    }
                    // No need to undo the last step, we just mutate the best step again.
                    // Absolutely take care that when resetting to the shape before,
                    // mutated MUST NOT return the same mutation over and over again
                    mutatingShape = bestShape.mutated()
            }
            return (bestShape, bestImprovement)
    }

}
