//
//  FidgetApp.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 6/26/21.
//

import SwiftUI

@main
struct FidgetApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(frame: UIScreen.main.bounds.size)
            }
        }
    }
}
