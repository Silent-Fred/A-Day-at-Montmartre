//
//  SettingsBundleHelper.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 07.02.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import Foundation

class SettingsBundleHelper {

    struct SettingsBundleKeys {
        static let approximationStyle = "ApproximationStyle"
        static let shapeStyle = "ShapeStyle"
    }

    class func approximationStyle() -> ApproximationStyle? {
        let approximationStyle =
            UserDefaults.standard.string(forKey: SettingsBundleKeys.approximationStyle)
                ?? ApproximationStyle.hillClimb.rawValue
        return ApproximationStyle(rawValue: approximationStyle)
    }

    class func shapeStyle() -> ShapeStyle? {
        let shapeStyle =
            UserDefaults.standard.string(forKey: SettingsBundleKeys.shapeStyle)
                ?? ShapeStyle.ellipses.rawValue
        return ShapeStyle(rawValue: shapeStyle)
    }
}
