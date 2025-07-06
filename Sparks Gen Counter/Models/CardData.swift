//
//  CardData.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 5/7/25.
//

import Foundation
import AppKit

struct CardData: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    let name: String
    let cost: Int
    let type: CardType
    let imageHash: String
}

enum CardType: String, CaseIterable, Codable {
    case spell, creature
}

// MARK: - CardMeta (metadata for generation)
struct CardMeta: Codable {
    let name: String
    let cost: Int
    let type: CardType
}

// MARK: - CardData Generator
class CardDataGenerator {
    static func generateCardData(metadataFile: URL, output: URL) {
        guard let data = try? Data(contentsOf: metadataFile),
              let metaList = try? JSONDecoder().decode([CardMeta].self, from: data) else {
            print("❌ Không thể đọc metadata JSON.")
            return
        }

        var result: [CardData] = []

        for meta in metaList {
            guard let image = NSImage(named: meta.name),
                  let resized = image.resized(to: CGSize(width: 64, height: 64)) else {
                print("⚠️ Không load được ảnh cho \(meta.name)")
                continue
            }

            let hash = resized.averageHash()

            let card = CardData(
                name: meta.name,
                cost: meta.cost,
                type: meta.type,
                imageHash: hash
            )
            result.append(card)
        }

        do {
            let jsonData = try JSONEncoder().encode(result)
            try jsonData.write(to: output)
            print("✅ Đã sinh CardData.json tại \(output.path)")
        } catch {
            print("❌ Ghi file JSON thất bại: \(error)")
        }
    }
}
