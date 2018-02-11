//
//  ShapeMask.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 14.01.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import UIKit

class ShapeMask {

    private static let shapeColour = UIColor.gray

    private var bitmap: BitmapMagic

    private var width: Int
    private var height: Int

    private lazy var renderer: UIGraphicsImageRenderer = self.createRenderer()

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        bitmap = BitmapMagic(width: width, height: height)
    }

    func maskedPixelIndices(shape: GeometricShape) -> [Int] {

        guard let imageMask = drawShapeMask(shape: shape)
            else { return [Int]() }

        return maskIndices(image: imageMask)
    }

    func unmaskedPixelIndices() -> [Int] {
        return Array(0..<width*height)
    }

    private func createRenderer() -> UIGraphicsImageRenderer {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        return UIGraphicsImageRenderer(size: CGSize(width: width,
                                                    height: height),
                                       format: format)
    }

    private func drawShapeMask(shape: GeometricShape) -> CGImage? {
        let image = renderer.image { context in
            shape.drawInContext(context: context,
                                usingColour: ShapeMask.shapeColour)
        }
        return image.cgImage
    }

    private func maskIndices(image: CGImage) -> [Int] {
        var indices = [Int]()

        guard
            let cfData = image.dataProvider?.data,
            let pixelDataPointer = CFDataGetBytePtr(cfData)
            else { return indices }

        var movingPointer = pixelDataPointer

        var index = 0
        let maxIndex = image.width * image.height
        while index < maxIndex {
            if movingPointer.pointee != 0 {
                indices.append(index)
            }
            movingPointer += 4
            index += 1
        }
        return indices
    }
}
