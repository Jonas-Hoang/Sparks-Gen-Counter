//
//  Sparks_Gen_CounterApp.swift
//  Sparks Gen Counter
//
//  Created by Jonas Hoang on 4/7/25.
//

import SwiftUI

@main
struct Sparks_Gen_CounterApp: App {
    var body: some Scene {
        //        WindowGroup {
        //            ContentView()
        //        }
        Settings {
            EmptyView() // Để app không crash
        }
    }
    init() {
        AlwaysOnTopWindow.makeWindow {
            ContentView()
        }
    }
}
