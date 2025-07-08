//
//  CardDataLoader.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 5/7/25.
//


import Foundation

struct CardDataLoader {
    static func loadAllCards() -> [CardData] {
        guard let url = Bundle.main.url(forResource: "CardData", withExtension: "json") else {
            print("❌ CardData.json not found in bundle!")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([CardData].self, from: data)
        } catch {
            print("❌ Failed to decode CardData.json: \(error)")
            return []
        }
    }
}
