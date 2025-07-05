//
//  SelectionOverlayView.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 5/7/25.
//

import SwiftUI
import ScreenCaptureKit

struct SelectionOverlayView: View {
    var onSelectionComplete: (NSImage) -> Void
    var onCancel: () -> Void

    @State private var startLocation: CGPoint? = nil
    @State private var currentLocation: CGPoint? = nil
    

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if startLocation == nil {
                                startLocation = value.startLocation
                            }
                            currentLocation = value.location
                        }
                        .onEnded { _ in
                            if let start = startLocation, let end = currentLocation {
                                let rect = CGRect(x: min(start.x, end.x),
                                                  y: min(start.y, end.y),
                                                  width: abs(start.x - end.x),
                                                  height: abs(start.y - end.y))

                                Task {
                                    if let image = await captureScreenKit(in: rect) {
                                        onSelectionComplete(image)
                                    } else {
                                        onCancel()
                                    }
                                }
                            } else {
                                onCancel()
                            }
                        }
                    )

                if let start = startLocation, let current = currentLocation {
                    Rectangle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: abs(start.x - current.x), height: abs(start.y - current.y))
                        .position(x: (start.x + current.x) / 2, y: (start.y + current.y) / 2)
                }
            }
        }
    }

    func captureScreenKit(in rect: CGRect) async -> NSImage? {
        guard let display = try? await SCShareableContent.current.displays.first else { return nil }

        let config = SCStreamConfiguration()
        config.width = Int(rect.width)
        config.height = Int(rect.height)
        config.pixelFormat = kCVPixelFormatType_32BGRA

        let filter = SCContentFilter(display: display, excludingWindows: [])

        do {
            let stream = SCStream(filter: filter, configuration: config, delegate: nil)
            try await stream.startCapture()

            // Simulate one frame capture - replace this logic with delegate callback if needed
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5s wait
            try await stream.stopCapture()

            // In real usage, use delegate method to get CMSampleBuffer and convert to CGImage -> NSImage
            // Placeholder result:
            return nil
        } catch {
            print("Screen capture error: \(error)")
            return nil
        }
    }
}
