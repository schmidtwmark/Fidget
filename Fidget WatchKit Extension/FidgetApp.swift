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

func getCornerRadius() -> Double {
    let screenBounds = WKInterfaceDevice.current().screenBounds
    switch screenBounds.width {
    case 136:
        fallthrough
    case 156: // 42mm
        return 0
    case 162: // 40mm
        return 25
    case 184:
        return 35
    default:
        print("UNKNOWN WATCH")
        return 0
    }
}

@main
struct FidgetApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(frame: WKInterfaceDevice.current().screenBounds.size, cornerRadius: getCornerRadius(), hapticCallback: watchHaptic)
            }
        }
    }
}
