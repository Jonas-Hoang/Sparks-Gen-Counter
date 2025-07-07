//
//  ColorDetector.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 7/7/25.
//

import AppKit

class ColorDetector {
    static func isPinkRed(in image: CGImage, box: CGRect) -> Bool {
        guard let cropped = image.cropping(to: box) else { return false }

        let bitmap = NSBitmapImageRep(cgImage: cropped)
        var redPixelCount = 0
        let width = Int(bitmap.pixelsWide)
        let height = Int(bitmap.pixelsHigh)

        for x in 0..<width {
            for y in 0..<height {
                let color = bitmap.colorAt(x: x, y: y) ?? .black
                let red = color.redComponent
                let green = color.greenComponent
                let blue = color.blueComponent

                if red > 0.75 && green < 0.5 && blue < 0.65 {
                    redPixelCount += 1
                }
            }
        }

        let total = width * height
        return Double(redPixelCount) / Double(total) > 0.2
    }
}
