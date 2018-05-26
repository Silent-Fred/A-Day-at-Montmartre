//
//  Types.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 05.04.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

enum ApproximationStyle: String {
    case hillClimb = "HillClimbing"
    case stochasticHillClimb = "StochasticHillClimbing"
    case basicEvolutionary = "BasicEvolutionary"
}

enum ShapeStyle: String {
    case ellipses = "Ellipses"
    case rectangles = "Rectangles"
    case smallDots = "SmallDots"
    case lines = "Lines"
    case triangles = "Triangles"
    case quadCurve = "QuadCurves"
}
