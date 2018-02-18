//
//  GeometricShapes.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 28.12.17.
//  Copyright © 2017 Michael Kühweg. All rights reserved.
//

import UIKit

// Abstract geometric shapes with coordinates on a [0, 1] scale.
// This allows them to scale for pixel images and vector images
protocol GeometricShape {

    static func randomShape(frameWidth: Int, frameHeight: Int) -> GeometricShape

    var colour: MontmartreColour { get set }

    func neighbours() -> [GeometricShape]

    func mutated() -> GeometricShape

    func patienceWithFailedMutations() -> Int

    func drawInContext(context: UIGraphicsImageRendererContext)

    func drawInContext(context: UIGraphicsImageRendererContext, usingColour: UIColor)

}
