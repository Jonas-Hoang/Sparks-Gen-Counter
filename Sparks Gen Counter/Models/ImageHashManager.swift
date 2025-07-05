//
//  ImageHashManager.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 5/7/25.
//

import Foundation
import AppKit

class ImageHashManager {
    static let shared = ImageHashManager()
    private init() {}

    func matchCard(from image: NSImage) -> CardData? {
        guard let imageHash = generateHash(from: image) else { return nil }

        return CardLibrary.allCards.first { card in
            card.imageHash == imageHash
        }
    }

    func generateHash(from image: NSImage) -> String? {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else { return nil }

        let resizedImage = NSImage(size: NSSize(width: 8, height: 8))
        resizedImage.lockFocus()
        bitmap.draw(in: NSRect(x: 0, y: 0, width: 8, height: 8))
        resizedImage.unlockFocus()

        guard let resizedBitmap = NSBitmapImageRep(data: resizedImage.tiffRepresentation!) else { return nil }

        var hash = ""
        for y in 0..<8 {
            for x in 0..<8 {
                let color = resizedBitmap.colorAt(x: x, y: y) ?? .white
                let brightness = color.brightnessComponent
                hash.append(brightness > 0.5 ? "1" : "0")
            }
        }
        return hash
    }
}
