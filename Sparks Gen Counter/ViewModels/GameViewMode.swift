//
//  GameViewModel.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 4/7/25.
//

import Foundation
import Combine
import SwiftUI
import ScreenCaptureKit
import AppKit

class GameViewModel: ObservableObject {
    @Published var spark = 6
    @Published var tick = 0
    @Published var tickMode: TickMode = .normal
    @Published var timerActive = false
    @Published var opponent: Opponent = .none
    @Published var health = 5
    @Published var allCards: [CardData] = []
    @Published var isRunning: Bool = false
    @Published var isCapturing: Bool = false
    
    private var captureTask: Task<Void, Never>?
    
    
    // Coordinator được giữ ở đây
    let captureCoordinator: ImageCaptureCoordinator
    
    private var timer: Timer?
    private var interval: TimeInterval = 7
    private var boostTicksRemaining = 0
    private var boostValue = 0
    private(set) var maxSpark = 10
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let cards = CardDataLoader.loadAllCards()
        self.allCards = cards
        //        print(cards)
        self.captureCoordinator = ImageCaptureCoordinator(allCards: cards)
    }
    
    
    // MARK: - Opponent setup
    func updateSparkValuesForOpponent() {
        spark = opponent.startSpark
        maxSpark = opponent.maxSpark
    }
    
    // MARK: - Timer Controls
    func start() {
        spark = opponent.startSpark
        maxSpark = opponent.maxSpark
        tick = 0
        tickMode = .normal
        timerActive = true
        interval = 7
//        captureCoordinator.startInteractiveCapture()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.tickForward()
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        timerActive = false
        spark = 0
        tick = 0
        tickMode = .normal
        boostTicksRemaining = 0
        boostValue = 0
        health = 5
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
    }
    
    func resume() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.tickForward()
        }
    }
    
    private func tickForward() {
        tick += 1
        
        if tick == 16 {
            tickMode = .fast
            interval = 5
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                self?.tickForward()
            }
            tick = 17
        }
        
        var sparkGain = 2
        if boostTicksRemaining > 0 {
            sparkGain = boostValue
            boostTicksRemaining -= 1
        }
        
        spark = min(spark + sparkGain, maxSpark)
    }
    
    // MARK: - Manual Adjust
    func decreaseTick() {
        if tick > 0 {
            tick -= 1
            spark = max(spark - 2, 0)
        }
    }
    
    func increaseTickManually() {
        tick += 1
        spark = min(spark + 2, maxSpark)
    }
    
    // MARK: - Spark Gen logic
    func applySparkGen() {
        guard spark >= 3 else { return }
        spark -= 3
        health -= 1
        
        if boostTicksRemaining > 0 && boostValue == 3 {
            boostValue = 4
        } else if boostTicksRemaining > 0 && boostValue == 4 {
            boostValue = 5
        } else {
            boostValue = 3
        }
        boostTicksRemaining = 5
    }
    
    func addSparkFromKill() {
        guard opponent == .dravos else { return }
        spark = min(spark + 1, maxSpark)
    }
    
    func reduceSpark(by amount: Int) {
        let oldValue = spark // Ghi lại giá trị cũ
        spark = max(spark - amount, 0)
        print("⚠️ DEBUG: Spark reduced from \(oldValue) to \(spark)")
    }
    
    // MARK: - Card / OCR application
    func applyCard(_ card: CardData) {
        print("[🎴] Applying card: \(card.name), cost: \(card.cost), type: \(card.type)")
        reduceSpark(by: card.cost)
    }
    
    func handleOCRText(_ text: String) {
        print("⚠️ DEBUG: OCR text received - \(text)") // Thêm dòng này để kiểm tra
        
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let processor = OCRProcessor(allCards: self.allCards)
        let results = processor.parseOCRLines(lines)
        
        print("⚠️ DEBUG: Parsed \(results.count) results") // Thêm log
        
        for result in results {
            print("[📝 OCR] Matched: \(result.cardName), cost: \(result.cost) sparks")
            self.reduceSpark(by: result.cost)
            
            // Thêm kiểm tra spark sau khi trừ
            print("⚠️ DEBUG: Current spark after reduction - \(self.spark)")
        }
    }
    
    // MARK: - SparkGenEffect
    private var sparkGenEffect: SparkGenEffect?
}

struct SparkGenEffect {
    let startTick: Int
    
    func effect(forTick currentTick: Int) -> Int? {
        let delta = currentTick - startTick
        switch delta {
        case 1...5: return 3
        case 6...10: return 0
        default: return nil
        }
    }
}
