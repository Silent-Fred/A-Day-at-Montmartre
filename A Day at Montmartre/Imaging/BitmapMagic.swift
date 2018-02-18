//
//  BitmapMagic.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 05.01.18.
//  Copyright © 2018 Michael Kühweg. All rights reserved.
//

import UIKit

class BitmapMagic {

    public private (set) var width: Int
    public private (set) var height: Int

    public private (set) var colouredPixels = [MontmartreColour]()
    public private (set) var pixelBuffer = [UInt8]()

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        reservePixelBuffer()
    }

    init(forImage image: CGImage) {
        width = image.width
        height = image.height
        reservePixelBuffer()
        attachTo(image: image)
    }

    func colourCloud(maskedByPixelIndices mask: [Int]) -> ColourCloud {
        let colourCloud = ColourCloud()
        for index in mask {
            colourCloud.appendPoint(inColour: colouredPixels[index])
        }
        return colourCloud
    }

    private func reservePixelBuffer() {
        pixelBuffer = Array(repeating: 0, count: 4 * width * height)
    }

    private func attachTo(image: CGImage) {
        // make sure the image's byte representation is in the expected
        // colour space
        guard let imageInExpectedColourSpace = convertImageIntoExpectedColourSpace(image: image)
            else {
                colouredPixels = [MontmartreColour.white]
                return
        }
        colouredPixels = imageToColouredPixels(image: imageInExpectedColourSpace)
    }

    private func copyImageToPixelBuffer(image: CGImage) {

        guard let cfData = image
            .dataProvider?
            .data else { return }
        guard let pixelDataPointer = CFDataGetBytePtr(cfData)
            else {
                reservePixelBuffer()
                return
        }

        for index in 0..<pixelBuffer.count {
            pixelBuffer[index] = pixelDataPointer[index]
        }
    }

    private func imageToColouredPixels(image: CGImage) -> [MontmartreColour] {
        copyImageToPixelBuffer(image: image)
        return convertPixelBufferToColours(pixelBuffer: pixelBuffer)
    }

    private func convertPixelBufferToColours(pixelBuffer: [UInt8]) -> [MontmartreColour] {
        var colouredPixels = [MontmartreColour]()
        var index = 0
        let max = pixelBuffer.count
        while index < max {
            let red = pixelBuffer[index]
            let green = pixelBuffer[index + 1]
            let blue = pixelBuffer[index + 2]
            let alpha = pixelBuffer[index + 3]
            // colours come in premultiplied alpha
            colouredPixels.append(MontmartreColour(
                premultipliedRed: Double(red) / 255,
                green: Double(green) / 255,
                blue: Double(blue) / 255,
                alpha: Double(alpha) / 255))
            index += 4
        }
        return colouredPixels
    }

    private func convertImageIntoExpectedColourSpace(image: CGImage) -> CGImage? {
        let context = CGContext(data: nil,
                                width: image.width,
                                height: image.height,
                                bitsPerComponent: 8,
                                bytesPerRow: 0,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo:
            CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue)
        context?.draw(image,
                      in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return context?.makeImage()
    }
}
