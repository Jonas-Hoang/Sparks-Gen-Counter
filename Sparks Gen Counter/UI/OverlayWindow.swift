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
        let controller = NSHostingController(rootView: content)
        let frame = NSScreen.main?.frame ?? .zero

        let window = NSWindow(contentRect: frame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.level = .statusBar
        window.isOpaque = false
        window.backgroundColor = .clear
        window.ignoresMouseEvents = false
        window.contentView = controller.view
        window.makeKeyAndOrderFront(nil)

        self.window = window
    }

    func hide() {
        window?.orderOut(nil)
        window = nil
    }
}
