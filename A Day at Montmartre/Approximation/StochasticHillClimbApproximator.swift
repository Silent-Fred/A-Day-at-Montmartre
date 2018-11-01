//
//  StochasticHillClimbApproximator.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 15.05.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import Foundation

extension MutableCollection {

    mutating func shuffle() {
        // swiftlint:disable identifier_name
        for i in indices.dropLast() {
            let diff = distance(from: i, to: endIndex)
            let j = index(i, offsetBy: numericCast(arc4random_uniform(numericCast(diff))))
            swapAt(i, j)
        }
        // swiftlint:enable identifier_name
    }
}

extension Collection {

    func shuffled() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffle()
        return list
    }
}

class StochasticHillClimbApproximator: Approximator {

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
                    for neighbour in bestImprovement.shape.neighbours().shuffled() {
                        let improvement = calculateImprovement(shape: neighbour)
                        if improvement.improvement > bestImprovement.improvement {
                            bestImprovement = improvement
                            failedAttemptsInARow = 0
                            if bestImprovement.improvement > 0.0 {
                                break
                            }
                        }
                    }
                }
            }
            return bestImprovement
    }
}
