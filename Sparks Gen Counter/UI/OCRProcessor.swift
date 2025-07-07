//
//  OCRProcessor.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 7/7/25.
//

import Vision
import AppKit

class OCRProcessor {
    private let queue = DispatchQueue(label: "OCRProcessorQueue")
    private var request: VNRecognizeTextRequest!
    private var imageSource: CGImage?

    var onCardRecognized: ((String) -> Void)?

    init() {
        request = VNRecognizeTextRequest(completionHandler: self.handleTextRecognition)
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
    }

    func processImage(_ image: CGImage) {
        self.imageSource = image
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        queue.async {
            do {
                try handler.perform([self.request])
            } catch {
                print("❌ OCR error: \(error)")
            }
        }
    }

    private func handleTextRecognition(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation], let image = self.imageSource else { return }

        for observation in observations {
            guard let best = observation.topCandidates(1).first else { continue }
            let text = best.string

            if let box = try? observation.boundingBoxForImage(image),
               ColorDetector.isPinkRed(in: image, box: box) {
                print("🔍 Recognized Red Text: \(text)")
                onCardRecognized?(text)
            }
        }
    }
}

extension VNRecognizedTextObservation {
    func boundingBoxForImage(_ image: CGImage) throws -> CGRect {
        let size = CGSize(width: image.width, height: image.height)
        return VNImageRectForNormalizedRect(self.boundingBox, Int(size.width), Int(size.height))
    }
}
