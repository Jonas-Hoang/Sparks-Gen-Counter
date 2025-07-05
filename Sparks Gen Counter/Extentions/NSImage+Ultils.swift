//  NSImage+Resize+Hash.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 5/7/25.
//



import AppKit
import Foundation

extension NSImage {
    func resized(to size: CGSize) -> NSImage? {
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        self.draw(in: NSRect(origin: .zero, size: size),
                  from: NSRect(origin: .zero, size: self.size),
                  operation: .copy,
                  fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }

    func averageHash() -> String {
        guard let resized = self.resized(to: CGSize(width: 8, height: 8)) else { return "" }

        guard let bitmap = NSBitmapImageRep(data: resized.tiffRepresentation!) else { return "" }
        var totalBrightness: Double = 0
        var brightnessValues: [Double] = []

        for y in 0..<8 {
            for x in 0..<8 {
                guard let color = bitmap.colorAt(x: x, y: y) else { continue }
                let brightness = 0.299 * Double(color.redComponent) +
                                 0.587 * Double(color.greenComponent) +
                                 0.114 * Double(color.blueComponent)
                brightnessValues.append(brightness)
                totalBrightness += brightness
            }
        }

        let avg = totalBrightness / 64
        let hash = brightnessValues.map { $0 > avg ? "1" : "0" }.joined()
        return hash
    }
}
