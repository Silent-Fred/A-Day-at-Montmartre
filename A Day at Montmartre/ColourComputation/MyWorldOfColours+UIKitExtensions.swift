//
//  MyWorldOfColours+UIKitExtensions.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 14.01.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import UIKit

extension MontmartreColour {

    func uiColor() -> UIColor {
        return UIColor(displayP3Red: CGFloat(red),
                       green: CGFloat(green),
                       blue: CGFloat(blue),
                       alpha: CGFloat(alpha))
    }
}
