//
//  SelectionOverlayView.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 5/7/25.
//

import SwiftUI

struct SelectionOverlayView: View {
    var onSelectionComplete: (CGRect) -> Void
    var onCancel: () -> Void

    @State private var startLocation: CGPoint? = nil
    @State private var currentLocation: CGPoint? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Màu overlay mờ
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if startLocation == nil {
                                    startLocation = value.startLocation
                                }
                                currentLocation = value.location
                            }
                            .onEnded { _ in
                                handleSelectionEnd()
                            }
                    )

                // Vẽ vùng chọn
                if let start = startLocation, let current = currentLocation {
                    Rectangle()
                        .stroke(Color.white, lineWidth: 2)
                        .background(Color.clear)
                        .frame(
                            width: abs(start.x - current.x),
                            height: abs(start.y - current.y)
                        )
                        .position(
                            x: (start.x + current.x) / 2,
                            y: (start.y + current.y) / 2
                        )
                }

                // Nút Cancel (nếu muốn)
                VStack {
                    HStack {
                        Spacer()
                        Button("Cancel") {
                            onCancel()
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                        .padding()
                    }
                    Spacer()
                }
            }
        }
    }

    private func handleSelectionEnd() {
        guard let start = startLocation, let end = currentLocation else {
            print("[Overlay] ⚠️ No start/end. Cancelling.")
            onCancel()
            return
        }

        let rect = CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(start.x - end.x),
            height: abs(start.y - end.y)
        )

        if rect.width < 5 || rect.height < 5 {
            print("[Overlay] ⚠️ Region too small. Ignoring selection.")
            // Không gọi onCancel – chỉ reset
            startLocation = nil
            currentLocation = nil
            return
        }

        print("[Overlay] ✅ Selected region: \(rect)")
        onSelectionComplete(rect)
    }
}
