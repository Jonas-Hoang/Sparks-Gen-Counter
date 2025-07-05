//
//  AlwaysOnTopWindow.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 4/7/25.
//

import SwiftUI

class AlwaysOnTopWindow {
    static func makeWindow<Content: View>(@ViewBuilder content: @escaping () -> Content) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.isReleasedWhenClosed = false
        window.level = .floating
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.title = "Sparks Gen Counter"
        window.contentView = NSHostingView(rootView: content())

        let windowController = NSWindowController(window: window)
        windowController.showWindow(nil)
    }
}
