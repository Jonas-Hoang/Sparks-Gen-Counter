//
//  Opponent.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 4/7/25.
//
enum Opponent: String, CaseIterable, Identifiable {
    case none = "Default"
    case meren = "Meren"
    case dravos = "Dravos"
    case cfk = "CFKV"

    var id: String { rawValue }

    var startSpark: Int {
        switch self {
        case .meren: return 5
        case .dravos, .cfk, .none: return 6
        }
    }

    var maxSpark: Int {
        switch self {
        case .meren: return 5
        case .dravos: return 8
        case .cfk: return 12
        case .none: return 10
        }
    }
}
