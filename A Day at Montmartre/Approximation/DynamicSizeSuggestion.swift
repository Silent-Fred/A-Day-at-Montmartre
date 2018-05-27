//
//  DynamicSizeSuggestion.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 20.04.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import Foundation

struct DynamicSizeSuggestion {

    private static let defaultSize = 256
    private static let minimumSize = defaultSize / 4
    private let dynamicSizesBasedOnQuality = [92: defaultSize / 2,
                                              94: defaultSize,
                                              96: defaultSize * 2]
    private let dynamicSizesBasedOnShapes = [50: defaultSize / 2,
                                             100: defaultSize,
                                             1000: defaultSize * 2]

    func suggestInitialSize() -> Int {
        return suggest(basedOnQuality: 0.0, andNumberOfShapes: 0)
    }

    func suggest(basedOnQuality quality: Double, andNumberOfShapes shapes: Int)
        -> Int {
        return min(suggest(forCurrentQuality: quality),
                   suggest(forCurrentNumberOfShapes: shapes))
    }

    private func suggest(forCurrentQuality quality: Double) -> Int {
        return suggest(fromDictionary: dynamicSizesBasedOnQuality,
                       forProgress: Int(quality.rounded()))
    }

    private func suggest(forCurrentNumberOfShapes shapes: Int) -> Int {
        return suggest(fromDictionary: dynamicSizesBasedOnShapes,
                       forProgress: shapes)
    }

    private func suggest(fromDictionary dict: [Int: Int], forProgress progress: Int) -> Int {
        var size: Int?
        for progressEntry in dict where progress >= progressEntry.key {
            let safeSize = size ?? progressEntry.value
            size = min(safeSize, progressEntry.value)
        }
        return size ?? DynamicSizeSuggestion.minimumSize
    }

}
