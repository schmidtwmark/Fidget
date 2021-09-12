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


func getFrame(_ deviceBounds: CGSize) -> Frame{
    switch deviceBounds.width {
        case 136:
            return Frame(bottom: deviceBounds.height - 19.0, right: deviceBounds.width, cornerRadius: 0.0)
        case 156: // 42mm
            return Frame(bottom: deviceBounds.height - 21.0, right: deviceBounds.width, cornerRadius: 0.0)
        case 162: // 40mm
            let offset = 29.0
        return Frame(top: -offset, bottom: deviceBounds.height - offset + 1.0, left: -1.0, right: deviceBounds.width, cornerRadius: 30.0)
        case 184: // 44mm
            let offset = 31.0
            return Frame(top: -offset, bottom: deviceBounds.height - offset, left: -1.0, right: deviceBounds.width, cornerRadius: 35.0)
        default:
            print("Unknown watch")
            return Frame(bottom: deviceBounds.height, right: deviceBounds.width, cornerRadius: 35.0)
        }
}

@main
struct FidgetApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(frame: getFrame(WKInterfaceDevice.current().screenBounds.size), hapticCallback: watchHaptic)
            }
        }
    }
}
