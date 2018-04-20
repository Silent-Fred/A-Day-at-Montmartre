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
    private let dynamicSizesBasedOnQuality = [75.0: minimumSize,
                                              90.0: defaultSize / 2,
                                              94.0: defaultSize,
                                              95.0: defaultSize * 2]

    func suggest(forCurrentQuality quality: Double) -> Int {
        var size = DynamicSizeSuggestion.minimumSize
        for sizeForQuality in dynamicSizesBasedOnQuality where quality >= sizeForQuality.key {
            size = max(size, sizeForQuality.value)
        }
        return size
    }

}
