//
//  TestImageProvider.swift
//  A Day at MontmartreTests
//
//  Created by Michael Kühweg on 23.01.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import XCTest
@testable import A_Day_at_Montmartre

class TestImageProvider {

    /*
     For ease of coding, quadrants are not in mathematical order.
     They are ordered this way:
     
     +----+----+
     | Q1 | Q2 |
     +----+----+
     | Q3 | Q4 |
     +----+----+
     */
    static func colourQuadrants(edgeLength: Int,
                                backgroundColour: MontmartreColour?,
                                coloursInQuadrants: [MontmartreColour])
        -> UIImage {
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            format.opaque = false
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: edgeLength,
                                                                height: edgeLength),
                                                   format: format)
            let image = renderer.image { context in
                if backgroundColour != nil {
                    let rect = CGRect(x: 0, y: 0, width: edgeLength, height: edgeLength)
                    context.cgContext.setFillColor(backgroundColour!.uiColor().cgColor)
                    context.fill(rect)
                }
                var quadrant = 0
                let quadrantEdgeLength = edgeLength / 2
                for colour in coloursInQuadrants {
                    let quadrantRect = CGRect(x: quadrant % 2 * quadrantEdgeLength,
                                              y: ((quadrant / 2) % 2) * quadrantEdgeLength,
                                              width: edgeLength / 2,
                                              height: edgeLength / 2)
                    context.cgContext.setFillColor(colour.uiColor().cgColor)
                    context.fill(quadrantRect, blendMode: CGBlendMode.normal)
                    quadrant += 1
                }
            }
            return image
    }

    static func colourQuadrantsOnTransparentBackground(
        edgeLength: Int,
        coloursInQuadrants: [MontmartreColour])
        -> UIImage {
            return colourQuadrants(edgeLength: edgeLength,
                                   backgroundColour: nil,
                                   coloursInQuadrants: coloursInQuadrants)
    }
}
