//
//  OrbitNumberImage.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 03.05.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import UIKit

struct OrbitNumberImage {

    // the number to be visualised
    var number: Double

    // the number of orbits to be used for visualisation
    var orbits: Int

    var backgroundColour = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.75)
    var orbitColour = UIColor.lightGray
    var numberColour = UIColor.red
    var numberRadius: Double?

    init(_ number: Double, orbits: Int = 3) {
        self.number = number
        self.orbits = orbits
    }

    func image(width: Int, height: Int) -> UIImage {
        return UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
            .image { context in
                background(context: context)
                for o in 1...orbits {
                    orbit(o, inContext: context)
                }
                number(inContext: context)
        }
    }

    private func background(context: UIGraphicsImageRendererContext) {
        let cgContext = context.cgContext
        cgContext.setFillColor(backgroundColour.cgColor)
        cgContext.setStrokeColor(UIColor.clear.cgColor)
        cgContext.setLineWidth(0)
        cgContext.addArc(center: center(inContext: context),
                         radius: backgroundRadius(inContext: context),
                         startAngle: 0,
                         endAngle: CGFloat(Double.pi * 2.0),
                         clockwise: true)
        cgContext.drawPath(using: .fill)
    }

    private func center(inContext context: UIGraphicsImageRendererContext) -> CGPoint {
        let width = context.currentImage.size.width
        let height = context.currentImage.size.height
        return CGPoint(x: width / 2, y: height / 2)
    }

    private func backgroundRadius(inContext context: UIGraphicsImageRendererContext) -> CGFloat {
        let width = context.currentImage.size.width
        let height = context.currentImage.size.height
        let squareExtent = min(width, height)
        return CGFloat(Double(squareExtent) / 2.0)
    }

    private func orbit(_ orbit: Int,
                       inContext context: UIGraphicsImageRendererContext) {
        let cgContext = context.cgContext
        cgContext.setFillColor(UIColor.clear.cgColor)
        cgContext.setStrokeColor(orbitColour.cgColor)
        cgContext.setLineWidth(1)
        cgContext.addArc(center: center(inContext: context),
                         radius: orbitRadius(orbit: orbit, inContext: context),
                         startAngle: 0,
                         endAngle: CGFloat(Double.pi * 2.0),
                         clockwise: true)
        cgContext.drawPath(using: .stroke)
    }

    private func orbitDistance(inContext context: UIGraphicsImageRendererContext) -> CGFloat {
        return backgroundRadius(inContext: context) / CGFloat(orbits + 1)
    }

    private func orbitRadius(orbit: Int,
                             inContext context: UIGraphicsImageRendererContext) -> CGFloat {
        return orbitDistance(inContext: context) * CGFloat(orbit)
    }

    private func defaultNumberRadius(inContext context: UIGraphicsImageRendererContext) -> CGFloat {
        return orbitDistance(inContext: context) / CGFloat(4)
    }

    private func number(inContext context: UIGraphicsImageRendererContext) {
        let theCenter = center(inContext: context)
        let actualNumberRadius = numberRadius ?? Double(defaultNumberRadius(inContext: context))
        for o in 1...orbits {
            let thisOrbitsRadius = orbitRadius(orbit: o, inContext: context)
            let orbitalPosition = number.orbit(o)
            let point = CGPoint(x: theCenter.x + CGFloat(orbitalPosition.x) * CGFloat(thisOrbitsRadius),
                                y: theCenter.y + CGFloat(orbitalPosition.y) * CGFloat(thisOrbitsRadius))
            let cgContext = context.cgContext
            cgContext.setFillColor(numberColour.cgColor)
            cgContext.setStrokeColor(numberColour.cgColor)
            cgContext.setLineWidth(0)
            cgContext.addArc(center: point,
                             radius: CGFloat(actualNumberRadius),
                             startAngle: 0,
                             endAngle: CGFloat(Double.pi * 2.0),
                             clockwise: true)
            cgContext.drawPath(using: .fill)
        }
    }
}
