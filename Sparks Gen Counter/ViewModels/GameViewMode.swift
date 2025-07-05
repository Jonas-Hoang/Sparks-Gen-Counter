//
//  GameViewMode.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 4/7/25.
//
import Foundation
import Combine

extension Notification.Name {
    static let cardDetected = Notification.Name("cardDetected")
}

class GameViewModel: ObservableObject {
    @Published var spark = 6
    @Published var tick = 0
    @Published var tickMode: TickMode = .normal
    @Published var timerActive = false
    @Published var opponent: Opponent = .none
    @Published var health = 5
    
    private var timer: Timer?
    private var interval: TimeInterval = 7
    private var boostTicksRemaining = 0
    private var boostValue = 0
    private(set) var maxSpark = 10
    private var cancellables = Set<AnyCancellable>()
    
    
    init() {
        setupCardListener()
    }
    
    func updateSparkValuesForOpponent() {
        spark = opponent.startSpark
        maxSpark = opponent.maxSpark
    }
    
    func start() {
        spark = opponent.startSpark
        maxSpark = opponent.maxSpark
        tick = 0
        tickMode = .normal
        timerActive = true
        interval = 7
        
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
    
    func tickForward() {
        tick += 1
        
        if tick == 16 {
            tickMode = .fast
            interval = 5
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                self?.tickForward()
            }
            tick = 17 // to trigger UI display logic
        }
        
        var sparkGain = 2
        if boostTicksRemaining > 0 {
            sparkGain = boostValue
            boostTicksRemaining -= 1
        }
        
        spark = min(spark + sparkGain, maxSpark)
    }
    
    
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
    
    func pause() {
        timer?.invalidate()
        timer = nil
    }
    
    func resume() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.tickForward()
        }
    }
    
    //Dravos creature dead
    func addSparkFromKill() {
        guard opponent == .dravos else { return }
        spark = min(spark + 1, maxSpark)
    }
    
    func reduceSpark(by amount: Int) {
        spark = max(spark - amount, 0)
    }
    
    // MARK: - Handle Card Recognition
    private func setupCardListener() {
        NotificationCenter.default.publisher(for: .cardDetected)
            .compactMap { $0.object as? CardData }
            .sink { [weak self] card in
                self?.applyCard(card)
            }
            .store(in: &cancellables)
    }
    
    func applyCard(_ card: CardData) {
        print("[🎴] Đang áp dụng thẻ: \(card.name), cost: \(card.cost), loại: \(card.type)")
        reduceSpark(by: card.cost)
    }
    
    // MARK: - SparkGen Effect
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
