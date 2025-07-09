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
                // Nền hoàn toàn trong suốt nhưng vẫn bắt sự kiện
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 5) // Tăng minimumDistance để tránh nhầm với click
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
                    .onTapGesture {
                        onCancel()
                    }
                
                // Vẽ vùng chọn (chỉ hiển thị khi đang kéo)
                if let start = startLocation, let current = currentLocation {
                    Rectangle()
                        .stroke(Color.blue, lineWidth: 2)
                        .background(Color.blue.opacity(0.2))
                        .frame(
                            width: abs(start.x - current.x),
                            height: abs(start.y - current.y)
                        )
                        .position(
                            x: (start.x + current.x) / 2,
                            y: (start.y + current.y) / 2
                        )
                }
                
                // Hướng dẫn sử dụng (tùy chọn)
                if startLocation == nil {
                    VStack {
                        Text("Kéo để chọn vùng quét")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.top, 40)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private func handleSelectionEnd() {
        guard let start = startLocation, let end = currentLocation else {
            onCancel()
            return
        }
        
        let rect = CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(start.x - end.x),
            height: abs(start.y - end.y)
        )
        
        // Kiểm tra kích thước tối thiểu
        if rect.width < 20 || rect.height < 20 {
            resetSelection()
            return
        }
        
        onSelectionComplete(rect)
    }
    
    private func resetSelection() {
        startLocation = nil
        currentLocation = nil
    }
}
