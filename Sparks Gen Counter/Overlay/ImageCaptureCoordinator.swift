//
//  ImageCaptureCoordinator.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 5/7/25.
//

import Foundation
import Combine
import Vision
import SwiftUI
import AppKit
import ScreenCaptureKit
import AVFoundation

/// macOS-only typealias
typealias PlatformImage = NSImage

class ImageCaptureCoordinator: ObservableObject {
    private var isCapturing = false
    private var cancellables = Set<AnyCancellable>()

    /// 📌 Danh sách tất cả card trong app (truyền vào lúc init)
    private let allCards: [CardData]

    init(allCards: [CardData]) {
        self.allCards = allCards

        // Lắng nghe notification cardDetected
        NotificationCenter.default.publisher(for: .cardDetected)
            .compactMap { $0.object as? CardData }
            .sink { card in
                print("[OCR] 🎴 Nhận diện được thẻ: \(card.name)")
            }
            .store(in: &cancellables)
    }

    // MARK: - Start capture overlay

    func beginCaptureOnce() {
        guard !isCapturing else {
            print("[Capture] 🚫 Đang capture rồi.")
            return
        }

        isCapturing = true
        print("[Capture] ✅ Bắt đầu overlay chọn vùng ảnh...")

        let overlay = SelectionOverlayView(
            onSelectionComplete: { rect in
                Task {
                    await self.captureAndProcess(rect: rect)
                    await MainActor.run {
                        self.isCapturing = false
                        OverlayWindow.shared.hide()
                    }
                }
            },
            onCancel: {
                print("[Capture] 🛑 Người dùng huỷ capture.")
                self.isCapturing = false
                OverlayWindow.shared.hide()
            }
        )

        OverlayWindow.shared.show(with: overlay)
    }

    func cancelCapture() {
        print("[Capture] ❗️ Bị huỷ thủ công.")
        isCapturing = false
        OverlayWindow.shared.hide()
    }

    // MARK: - New method to actually capture and process the rect
    
    static func captureScreenKit(in rect: CGRect) async -> NSImage? {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
            guard let display = content.displays.first else {
                print("[CaptureKit] ❌ Không tìm thấy display")
                return nil
            }

            let filter = SCContentFilter(display: display, excludingWindows: [])
            let config = SCStreamConfiguration()
            config.width = Int(rect.width)
            config.height = Int(rect.height)
            config.pixelFormat = kCVPixelFormatType_32BGRA

            let delegate = ScreenCaptureDelegate()
            let stream = SCStream(filter: filter, configuration: config, delegate: delegate)
            try await stream.startCapture()

            let sampleBuffer = try await delegate.waitForFirstFrame()
            try await stream.stopCapture()

            guard let pixelBuffer = sampleBuffer.imageBuffer else {
                print("[CaptureKit] ❌ Không có pixelBuffer")
                return nil
            }

            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let rep = NSCIImageRep(ciImage: ciImage)
            let nsImage = NSImage(size: rep.size)
            nsImage.addRepresentation(rep)

            return nsImage

        } catch {
            print("[CaptureKit] ❌ Lỗi: \(error)")
            return nil
        }
    }


    final class ScreenCaptureDelegate: NSObject, SCStreamDelegate {
        private var continuation: CheckedContinuation<CMSampleBuffer, Error>?

        func waitForFirstFrame() async throws -> CMSampleBuffer {
            try await withCheckedThrowingContinuation { cont in
                self.continuation = cont
            }
        }

        func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of outputType: SCStreamOutputType) {
            if let cont = continuation {
                continuation = nil
                cont.resume(returning: sampleBuffer)
            }
        }
    }


    func captureAndProcess(rect: CGRect) async {
        print("[Capture] 🎯 Đang chụp vùng: \(rect)")

        if let image = await Self.captureScreenKit(in: rect) {
            print("[Capture] ✅ Capture thành công, bắt đầu OCR")
            self.processImage(image)
        } else {
            print("[Capture] ❌ Không capture được ảnh từ vùng chọn.")
        }
    }
    // MARK: - Xử lý OCR chính

    func processImage(_ image: NSImage) {
        guard let cgImage = image.cgImageForOCR() else {
            print("[OCR] ❌ Ảnh không hợp lệ (không tạo CGImage được)")
            return
        }

        print("[OCR] 🖼️ Bắt đầu xử lý OCR...")

        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }

            if let error = error {
                print("[OCR] ❗️ Lỗi: \(error.localizedDescription)")
                return
            }

            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let lines = observations.compactMap { $0.topCandidates(1).first?.string }

            print("[OCR] ✅ Kết quả text:")
            for line in lines {
                print("👉 \(line)")
            }

            self.parseTextLines(lines)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("[OCR] ❗️ VNImageRequestHandler error: \(error)")
            }
        }
    }

    // MARK: - Parse lines để nhận diện thẻ

    private func parseTextLines(_ lines: [String]) {
        for line in lines {
            let lower = line.lowercased()

            // CASE 1: Summoned (creature)
            if lower.contains("summoned") {
                if let matchName = extractCardName(from: line, keyword: "summoned") {
                    if let card = allCards.first(where: { $0.name.lowercased() == matchName.lowercased() && $0.type == .creature }) {
                        print("[OCR] 🎯 Tìm thấy Creature: \(card.name)")
                        NotificationCenter.default.post(name: .cardDetected, object: card)
                        return
                    }
                }
            }

            // CASE 2: Spell (✧)
            if lower.contains("✧") {
                if let matchName = extractCardName(from: line, keyword: "✧") {
                    if let card = allCards.first(where: { $0.name.lowercased() == matchName.lowercased() && $0.type == .spell }) {
                        print("[OCR] 🎯 Tìm thấy Spell: \(card.name)")
                        NotificationCenter.default.post(name: .cardDetected, object: card)
                        return
                    }
                }
            }
        }

        print("[OCR] ⚠️ Không tìm thấy card phù hợp trong text.")
    }

    /// Helper: cắt tên thẻ sau keyword
    private func extractCardName(from line: String, keyword: String) -> String? {
        guard let range = line.range(of: keyword, options: .caseInsensitive) else {
            return nil
        }

        let after = line[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
        print("[OCR] ✂️ Extracted sau '\(keyword)': \(after)")
        return after
    }
}
