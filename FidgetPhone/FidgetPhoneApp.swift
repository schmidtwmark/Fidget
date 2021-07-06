//
//  FidgetPhoneApp.swift
//  FidgetPhone
//
//  Created by Mark Schmidt on 7/4/21.
//

import SwiftUI

@main
struct FidgetPhoneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(motion: MotionManager())
        }
    }
}
