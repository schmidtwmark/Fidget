//
//  ContentView.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 6/26/21.
//

import SwiftUI
import Combine
import CoreMotion

let SHOW_DEBUG = false

struct ContentView : View  {
    var accelView: AccelerometerView 
    var crownView: CrownView
    var buttonView: ButtonView
    var settingsView: SettingsView
    var breatheView: BreatheView
    @State var selection: Int = 0
//    @State var selection: Int {
//        get {
//            return self.selection
//        }
//        set(newSelection) {
//            print("Selecting! Current: \(self.selection) New: \(newSelection)")
//            self.selection = newSelection
//        }
//    }
    @StateObject var settings : AppSettings


    init(frame: CGSize, cornerRadius: Double, hapticCallback: @escaping (Double) -> Void ) {
        _settings = StateObject(wrappedValue: AppSettings())
        let motion = MotionManager(frame: CGSize(width: frame.width, height: frame.height), cornerRadius: cornerRadius, playHaptic: hapticCallback)
        accelView = AccelerometerView(frame: frame, cornerRadius: cornerRadius, hapticCallback: hapticCallback, motionManager: motion, showDebug: SHOW_DEBUG)
        crownView = CrownView(frame: frame, motionManager: motion)
        buttonView = ButtonView(frame: frame, hapticCallback: hapticCallback, motionManager: motion)
        breatheView = BreatheView(frame: frame, hapticCallback: hapticCallback, motionManager: motion)
        settingsView = SettingsView(motionManager: motion)
    }
    
    
    var body: some View {
        TabView(selection: $selection) {
            breatheView
            accelView
            buttonView
            crownView
            settingsView
        }.environmentObject(settings).navigationBarHidden(true)
    }
}

// struct ContentView_Previews: PreviewProvider {
//     static var previews: some View {
//         ContentView(frame: WKInterfaceDevice.current().screenBounds.size, hapticCallback: { (Double) -> Void in })
//     }
// }
