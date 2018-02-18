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

    enum ApproximationStyle: String {
        case hillClimb = "HillClimbing"
        case basicGenetic = "BasicGenetic"
    }

    enum ShapeStyle: String {
        case ellipses = "Ellipses"
        case rectangles = "Rectangles"
        case smallDots = "SmallDots"
        case lines = "Lines"
        case triangles = "Triangles"
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
