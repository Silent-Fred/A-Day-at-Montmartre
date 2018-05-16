//
//  BasicEvolutionaryApproximator.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 28.01.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import Foundation

class BasicEvolutionaryApproximator: Approximator {

    private let attemptedShapes = 8
    private let acceptedFailuresPerShape = 100

    override func refineApproximation() {

        guard let context = context else { return }

        var bestAttempt = basicEvolutionaryWithRandomShape()
        for _ in 1...attemptedShapes {
            autoreleasepool {
                let generation = basicEvolutionaryWithRandomShape()
                if generation.improvement > bestAttempt.improvement {
                    bestAttempt = generation
                }
            }
        }
        if bestAttempt.improvement > 0.0 {
            context.append(shape: bestAttempt.shape)
        }
    }

    private func basicEvolutionaryWithRandomShape() -> (shape: GeometricShape, improvement: Double) {
        return basicEvolutionary(startingWith: randomShape())
    }

    private func basicEvolutionary(startingWith: GeometricShape)
        -> (shape: GeometricShape, improvement: Double) {

        var bestImprovement = (shape: startingWith, improvement: -Double.infinity)
        var mutatingShape = startingWith
        var failuresLeft = acceptedFailuresPerShape
        var failedAttemptsInARow = 0
        while failuresLeft > 0
            && failedAttemptsInARow < startingWith.patienceWithFailedMutations() {
                let improvement = calculateImprovement(shape: mutatingShape)
                if improvement.improvement > bestImprovement.improvement {
                    bestImprovement = improvement
                    failedAttemptsInARow = 0
                } else {
                    failuresLeft -= 1
                    failedAttemptsInARow += 1
                }
                // No need to undo the last step, we just mutate the best step again.
                // Absolutely take care that when resetting to the shape before,
                // mutated MUST NOT return the same mutation over and over again
                mutatingShape = bestImprovement.shape.mutated()
        }
        return bestImprovement
    }

}
