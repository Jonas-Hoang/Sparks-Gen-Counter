//
//  CardDataLoader.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 5/7/25.
//


import Foundation
import AppKit

class CardDataLoader {
    static func loadCardData(from folderPath: String) -> [CardData] {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(atPath: folderPath) else {
            return []
        }

        var cardDataList: [CardData] = []

        for file in files {
            let fullPath = "\(folderPath)/\(file)"
            guard let image = NSImage(contentsOfFile: fullPath) else { continue }

            let fileName = file.replacingOccurrences(of: ".png", with: "").replacingOccurrences(of: ".jpg", with: "")
            let components = fileName.components(separatedBy: "_")
            guard components.count == 3,
                  let cost = Int(components[1]),
                  let type = CardType(rawValue: components[2]) else { continue }

            let name = components[0]

            guard let imageHash = ImageHashManager.shared.generateHash(from: image) else { continue }

            let card = CardData(name: name, cost: cost, type: type, imageHash: imageHash)
            cardDataList.append(card)
        }

        return cardDataList
    }
}
