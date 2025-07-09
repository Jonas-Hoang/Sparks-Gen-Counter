//
//  ImageCaptureCoordinator.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 5/7/25.
//

import SwiftUI
import Combine
import Vision

class ImageCaptureCoordinator: NSObject, ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let allCards: [CardData]
    private let ocrProcessor: OCRProcessor
    
    @Published var lastOCRText: String = ""
    @Published var isShowingOverlay = false
    private var captureTask: Task<Void, Never>?
    private var isCapturing = false
    @Published var detectedCards: [CardData] = []
    
    init(allCards: [CardData]) {
        self.allCards = allCards
        self.ocrProcessor = OCRProcessor(allCards: allCards)
        super.init()
        setupOCRListener()
    }
    
    // MARK: - OCR Processing
    func processImage(_ image: NSImage) {
        print("⚠️ Đã chụp ảnh - Kích thước: \(image.size)")
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("⚠️ Không thể convert NSImage sang CGImage")
            return
        }
        
        Task {
            do {
                let recognizedText = try await performOCR(on: cgImage)
                await MainActor.run {
                    self.lastOCRText = recognizedText
                    NotificationCenter.default.post(
                        name: .ocrTextRecognized,
                        object: recognizedText
                    )
                }
                NotificationCenter.default.post(name: .ocrTextRecognized, object: recognizedText)
                print("⚠️ Đã gửi notification - Text: \(recognizedText.prefix(20))...")
            } catch {
                print("🔴 OCR Error: \(error.localizedDescription)")
            }
        }
        
        
    }
    
    private func performOCR(on image: CGImage) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                
                let text = observations.compactMap {
                    $0.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                continuation.resume(returning: text)
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - Notification Handling
    private func setupOCRListener() {
        NotificationCenter.default.publisher(for: .ocrTextRecognized)
            .receive(on: DispatchQueue.main)
            .compactMap { $0.object as? String }
            .sink { [weak self] text in
                self?.handleOCRText(text)
            }
            .store(in: &cancellables)
    }
    
    private func handleOCRText(_ text: String) {
        print("🔍 OCR Text Received:\n\(text)\n---")
        
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let results = ocrProcessor.parseOCRLines(lines)
        
        print("✅ Found \(results.count) card matches")
        results.forEach { result in
            print("🃏 Matched: \(result.cardName) (\(result.cost) sparks)")
            NotificationCenter.default.post(
                name: .cardDetected,
                object: allCards.first { $0.name == result.cardName }
            )
        }
    }
    
    func startInteractiveCapture() {
        guard !isShowingOverlay else { return }
        
        isShowingOverlay = true
        isCapturing = true
        print("🟢 Bắt đầu chọn vùng quét")
        
        let overlayView = SelectionOverlayView(
            onSelectionComplete: { [weak self] rect in
                self?.isShowingOverlay = false
                self?.handleRegionSelected(rect)
                OverlayWindow.shared.hide()
            },
            onCancel: { [weak self] in
                self?.isShowingOverlay = false
                OverlayWindow.shared.hide()
                print("🔴 Người dùng huỷ chọn vùng")
            }
        )
        
        OverlayWindow.shared.show(with: overlayView)
    }
    
    private func handleRegionSelected(_ rect: CGRect) {
        print("📏 Đã chọn vùng: \(rect)")
        
        Task {
            // 1. Chụp ảnh từ vùng đã chọn
            if let image = await captureRegion(rect) {
                // 2. Xử lý OCR
                self.processImage(image)
            }
        }
    }
    
    private func captureRegion(_ rect: CGRect) async -> NSImage? {
        // Triển khai logic chụp màn hình con
        // Sử dụng ScreenCaptureKit như đã thảo luận trước đó
        return nil // Thay bằng ảnh thực tế
    }
    func stopCapture() {
        print("🛑 Stopping all capture activities")
        
        // 1. Hủy task đang chạy
        captureTask?.cancel()
        captureTask = nil
        
        // 2. Ẩn overlay nếu đang hiển thị
        if isShowingOverlay {
            OverlayWindow.shared.hide()
            isShowingOverlay = false
        }
        
        // 3. Đặt lại trạng thái
        isCapturing = false
    }
    
    deinit {
        stopCapture()
    }
}
