//
//  ContentView.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 6/26/21.
//

import SwiftUI
import Combine
import CoreMotion

let SHOW_DEBUG = true

struct ContentView : View  {
    var accelView: AccelerometerView 
    var crownView: CrownView
    var buttonView: ButtonView
    var settingsView: SettingsView
    @StateObject var settings : AppSettings


    init(frame: CGSize, cornerRadius: Double, hapticCallback: @escaping (Double) -> Void ) {
        _settings = StateObject(wrappedValue: AppSettings())
        accelView = AccelerometerView(frame: frame, cornerRadius: cornerRadius, hapticCallback: hapticCallback, showDebug: SHOW_DEBUG)
        crownView = CrownView(frame: frame)
        buttonView = ButtonView(frame: frame, hapticCallback: hapticCallback)
        settingsView = SettingsView()
    }
    
    
    var body: some View {
        TabView {
            buttonView
            crownView
            accelView
            settingsView
        }.environmentObject(settings).navigationBarHidden(true)
    }
}

// struct ContentView_Previews: PreviewProvider {
//     static var previews: some View {
//         ContentView(frame: WKInterfaceDevice.current().screenBounds.size, hapticCallback: { (Double) -> Void in })
//     }
// }
