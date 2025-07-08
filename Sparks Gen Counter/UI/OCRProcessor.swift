//
//  OCRProcessor.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 7/7/25.
//

import Foundation

/// Bộ xử lý chuỗi OCR để nhận dạng hành động và tính sparks tiêu hao
import Foundation

struct OCRResult {
    let cardName: String
    let cost: Int
}

struct OCRProcessor {
    let allCards: [CardData]
    
    func parseOCRLines(_ lines: [String]) -> [OCRResult] {
        var results: [OCRResult] = []
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if trimmed.isEmpty { continue }
            
            // 1. Creature card detection
            if let creatureResult = matchCreature(from: line) {
                results.append(creatureResult)
                continue
            }
            
            // 2. Spell card detection
            if let spellResult = matchSpell(from: line) {
                results.append(spellResult)
                continue
            }
        }
        
        return results
    }
    
    private func matchCreature(from line: String) -> OCRResult? {
        guard line.lowercased().contains("summoned") else { return nil }
        
        // Example: "Hal summoned Tox Siren"
        let parts = line.components(separatedBy: "summoned")
        guard parts.count > 1 else { return nil }
        
        let possibleName = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let matched = fuzzyFindCard(named: possibleName, type: .creature) {
            return OCRResult(cardName: matched.name, cost: matched.cost)
        }
        return nil
    }
    
    private func matchSpell(from line: String) -> OCRResult? {
        guard line.contains("✧") else { return nil }
        
        // Example: "Hal ✧ Singe"
        let parts = line.components(separatedBy: "✧")
        guard parts.count > 1 else { return nil }
        
        let possibleName = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let matched = fuzzyFindCard(named: possibleName, type: .spell) {
            return OCRResult(cardName: matched.name, cost: matched.cost)
        }
        return nil
    }
    
    private func fuzzyFindCard(named input: String, type: CardType) -> CardData? {
        // Very simple fuzzy matching: case-insensitive contains
        let lcInput = input.lowercased()
        let filtered = allCards.filter { $0.type == type }
        
        // Exact match first
        if let exact = filtered.first(where: { $0.name.lowercased() == lcInput }) {
            return exact
        }
        
        // Partial match
        if let partial = filtered.first(where: { lcInput.contains($0.name.lowercased()) || $0.name.lowercased().contains(lcInput) }) {
            return partial
        }
        
        return nil
    }
}
