//
//  CardLibrary.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 5/7/25.
//

import Foundation
import AppKit

struct CardLibrary {
    static var allCards: [CardData] = []

    static func loadCardsFromDisk() {
        let path = Bundle.main.resourcePath! + "Resources/Cards"
        allCards = CardDataLoader.loadCardData(from: path)
        print("Loaded \(allCards.count) cards from \(path)")
    }
}
