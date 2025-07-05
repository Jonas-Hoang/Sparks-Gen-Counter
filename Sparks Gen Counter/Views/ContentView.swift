//
//  ContentView.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 4/7/25.
//

import SwiftUI
import UniformTypeIdentifiers


struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @StateObject private var captureCoordinator = ImageCaptureCoordinator()
    @State private var countdown: Int = 7
    @State private var countdownTimer: Timer?
    @State private var isPaused: Bool = false
    
    
    
    var displayTick: Int {
        viewModel.tickMode == .fast ? viewModel.tick - 16 : viewModel.tick
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("SPARKS: ")
                    .font(.largeTitle)
                    .foregroundColor(.mint)
                Text("\(viewModel.spark)")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
            }
            
            
            HStack {
                Text(viewModel.tickMode == .normal ? "Normal" : "Fast")
                    .foregroundColor(viewModel.tickMode == .normal ? .gray : .green)
                    .font(.system(size: 24))
                Spacer()
                HStack(spacing: 6) {
                    Button(action: {
                        viewModel.decreaseTick()
                    }) {
                        Image(systemName: "minus.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.timerActive || viewModel.tick <= 0)
                    
                    Text("Tick: \(displayTick)")
                        .foregroundColor(viewModel.tickMode == .fast || displayTick == 16 ? .green : .primary)
                        .font(.system(size: 24))
                        .frame(minWidth: 60)
                    
                    Button(action: {
                        viewModel.increaseTickManually()
                    }) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.green)
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.timerActive)
                }
            }
            .padding()
            
            Text("Timer: \(countdown)s")
                .font(.system(size: 30))
                .foregroundColor(.blue)
            
            Picker("Opponent", selection: $viewModel.opponent) {
                ForEach(Opponent.allCases) { opponent in
                    Text(opponent.rawValue).tag(opponent)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .disabled(viewModel.timerActive)
            .onChange(of: viewModel.opponent) { _, _ in
                viewModel.updateSparkValuesForOpponent()
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.applySparkGen()
                }) {
                    Circle()
                        .fill(viewModel.spark >= 3 ? Color.orange : Color.gray)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text("SGen")
                                .foregroundColor(.white)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.timerActive || viewModel.spark < 3)
                
                ForEach(1...5, id: \.self) { value in
                    Button(action: {
                        viewModel.reduceSpark(by: value)
                    }) {
                        Circle()
                            .fill(viewModel.spark >= value ? Color.red : Color.gray)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text("-\(value)")
                                    .foregroundColor(.white)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.timerActive || viewModel.spark < value)
                }
            }
            .padding()
            
            if viewModel.opponent == .dravos {
                Button(action: {
                    viewModel.addSparkFromKill()
                }) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.3))
                        .frame(width: 180, height: 44)
                        .overlay(
                            Text("Dead C")
                                .foregroundColor(Color.primary)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.timerActive)
            }
            
            if viewModel.timerActive{
                Button(action: {
                    isPaused.toggle()
                    if isPaused {
                        countdownTimer?.invalidate()
                        viewModel.pause()
                    } else {
                        viewModel.resume()
                        startCountdown()
                    }
                }) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange)
                        .frame(width: 120, height: 44)
                        .overlay(
                            Text(isPaused ? "Resume" : "Pause")
                                .foregroundColor(.white)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.timerActive)
            }
            
            Button("Generate JSON") {
                guard let resourceURL = Bundle.main.resourceURL else {
                    print("❌ Không thể lấy resourceURL.")
                    return
                }
                
                
                let imagesFolder = resourceURL.appendingPathComponent("Cards")
                let metadataFile = resourceURL.appendingPathComponent("metadata.json")

                let panel = NSSavePanel()
                panel.title = "Save CardData.json"
                panel.allowedContentTypes = [.json] // macOS 12+
                panel.nameFieldStringValue = "CardData.json"

                if panel.runModal() == .OK, let outputFile = panel.url {
                    CardDataGenerator.generateCardData(from: imagesFolder, metadataFile: metadataFile, output: outputFile)
                } else {
                    print("🛑 Người dùng đã hủy chọn đường dẫn.")
                }
            }
            
            Button(action: {
                if viewModel.timerActive {
                    viewModel.stop()
                    stopCountdown()
                    countdown = viewModel.tickMode == .normal ? 7 : 5
                    isPaused = false
                    captureCoordinator.cancelCapture()
                } else {
                    viewModel.start()
                    countdown = viewModel.tickMode == .normal ? 7 : 5
                    startCountdown()
                    captureCoordinator.beginCaptureOnce()
                }
            }) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(viewModel.timerActive ? Color.blue : Color.green)
                    .frame(width: 120, height: 44)
                    .overlay(
                        Text(viewModel.timerActive ? "Stop" : "Start")
                            .foregroundColor(.white)
                    )
            }
            
            .buttonStyle(.plain)
            .padding(.top)
            
        }
        .padding()
        .frame(width: 500, height: 550)
        .focusable(false)
    }
    
    func startCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            countdown -= 1
            if countdown <= 0 {
                countdown = viewModel.tickMode == .normal ? 7 : 5
            }
        }
    }
    
    func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
}



#Preview("Actual Layout", traits: .sizeThatFitsLayout) {
    ContentView()
        .frame(width: 500, height: 600)
}
