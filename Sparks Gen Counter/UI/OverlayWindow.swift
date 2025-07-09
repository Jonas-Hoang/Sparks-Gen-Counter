//
//  OverlayWindow.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 5/7/25.
//

import SwiftUI

class OverlayWindow {
    static let shared = OverlayWindow()
    private var window: NSWindow?
    
    func show(with content: SelectionOverlayView) {
        // Đảm bảo chỉ có một window duy nhất
        if let existingWindow = window {
            existingWindow.orderOut(nil)
            self.window = nil
        }
        
        let hostingController = NSHostingController(rootView: content)
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
        
        // Tạo window với cấu hình tối ưu
        let window = NSWindow(
            contentRect: NSScreen.main?.frame ?? .zero,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // Cấu hình window
        window.level = .floating  // Trên cùng nhưng không chặn các cửa sổ khác
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = false  // Cho phép tương tác chuột
        window.acceptsMouseMovedEvents = true
        window.collectionBehavior = [.transient, .ignoresCycle, .fullScreenNone]
        window.contentView = hostingController.view
        
        // Vô hiệu hóa hiệu ứng mờ/xám
        window.animationBehavior = .none
        
        // Hiển thị window
        window.makeKeyAndOrderFront(nil)
        
        self.window = window
    }
    
    func hide() {
        window?.orderOut(nil)
        window = nil
    }
    
    // Thêm hàm để cập nhật kích thước khi cần
    func updateFrame(_ frame: CGRect) {
        window?.setFrame(frame, display: true)
    }
}
