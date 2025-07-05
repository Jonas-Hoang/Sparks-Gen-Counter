//
//  ImageCaptureCoordinator.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 5/7/25.
//

import Foundation
import Combine

class ImageCaptureCoordinator: ObservableObject {
    private var isCapturing = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
          NotificationCenter.default.publisher(for: .cardDetected)
              .compactMap { $0.object as? CardData }
              .sink { card in
                  print("Nhận diện được thẻ: \(card.name)")
              }
              .store(in: &cancellables)
      }

    func beginCaptureOnce() {
        guard !isCapturing else {
            print("[Capture] Capture already in progress.")
            return
        }

        isCapturing = true
        print("[Capture] Starting overlay capture...")

        let overlay = SelectionOverlayView(
            onSelectionComplete: { image in
                if let card = ImageHashManager.shared.matchCard(from: image) {
                    print("[Capture] Matched card: \(card.name) | Cost: \(card.cost) | Type: \(card.type.rawValue)")
                    NotificationCenter.default.post(name: .cardMatched, object: card)
                } else {
                    print("[Capture] No card matched.")
                }

                self.isCapturing = false
                OverlayWindow.shared.hide()
            },
            onCancel: {
                print("[Capture] Capture cancelled by user.")
                self.isCapturing = false
                OverlayWindow.shared.hide()
            }
        )

        OverlayWindow.shared.show(with: overlay)
    }

    func cancelCapture() {
        print("[Capture] Forcibly cancelled.")
        isCapturing = false
        OverlayWindow.shared.hide()
    }
}
