//
//  SettingsView.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 7/24/21.
//

import Foundation
import SwiftUI
import Combine

struct SettingsView : View {
    @EnvironmentObject var settings : AppSettings
    
    var motion: MotionManager
    
    init(motionManager: MotionManager) {
        self.motion = motionManager
    }
    
    func getViewFor(color: MSColor) -> some View{
        return Text(color.key).tag(color).foregroundColor(color.rawColor)
    }

    var body : some View {
        if settings.paid {
            VStack {
                Picker("App Color Theme", selection: $settings.pickerColor) {
                    getViewFor(color: MSColor(rawColor: Color("Purple"), key: "Purple"))
                    getViewFor(color: MSColor(rawColor: Color("Blue"), key: "Blue"))
                    getViewFor(color: MSColor(rawColor: Color("Green"), key: "Green"))
                    getViewFor(color: MSColor(rawColor: Color("Mint"), key: "Mint"))
                    getViewFor(color: MSColor(rawColor: Color("Orange"), key: "Orange"))
                    getViewFor(color: MSColor(rawColor: Color("Pink"), key: "Pink"))
                    getViewFor(color: MSColor(rawColor: Color("Red"), key: "Red"))
                    getViewFor(color: MSColor(rawColor: Color("White"), key: "White"))
                    getViewFor(color: MSColor(rawColor: Color("Yellow"), key: "Yellow"))
                }
                Button("Confirm", action: {
                    print("Saving color")
                    settings.color = settings.pickerColor
                    
                })
            }
            .onAppear(perform: {
                motion.stopUpdates()
            })
        } else {
            VStack {
                Text("Not paid")
            }
            .onAppear(perform: {
                motion.stopUpdates()
            })
        }
        
    }
}
