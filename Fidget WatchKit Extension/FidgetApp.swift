//
//  FidgetApp.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 6/26/21.
//

import SwiftUI

func watchHaptic(velocity: Double) {
    WKInterfaceDevice.current().play(WKHapticType.click)
}

@main
struct FidgetApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(frame: WKInterfaceDevice.current().screenBounds.size, hapticCallback: watchHaptic)
            }
        }
    }
}
