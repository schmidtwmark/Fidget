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

final class TabViewManager: ObservableObject {
    @Published var selection: Int = 0 {
        didSet {
            if selection == 2 {
                motion.resetPlayer()
                motion.initUpdates()
            } else {
                motion.stopUpdates()
                motion.resetPlayer()
            }
        }
    }
    
    var motion: MotionManager
    init(motion: MotionManager) {
        self.motion = motion
        
    }
}

struct ContentView : View  {
    var accelView: AccelerometerView 
    var crownView: CrownView
    var buttonView: ButtonView
    var settingsView: SettingsView
    var breatheView: BreatheView
    
    @ObservedObject var tabViewManager: TabViewManager
    
    @StateObject var settings : AppSettings = AppSettings()
    @StateObject var store: Store = Store()


    init(frame: CGSize, cornerRadius: Double, hapticCallback: @escaping (Double) -> Void ) {
        let motion = MotionManager(frame: CGSize(width: frame.width, height: frame.height), cornerRadius: cornerRadius, playHaptic: hapticCallback)
        tabViewManager = TabViewManager(motion: motion)
        accelView = AccelerometerView(frame: frame, cornerRadius: cornerRadius, hapticCallback: hapticCallback, motionManager: motion, showDebug: SHOW_DEBUG)
        crownView = CrownView(frame: frame)
        buttonView = ButtonView(frame: frame, hapticCallback: hapticCallback)
        breatheView = BreatheView(frame: frame, hapticCallback: hapticCallback)
        settingsView = SettingsView()
    }
    
    
    var body: some View {
        TabView(selection: $tabViewManager.selection) {
            breatheView.tag(1)
//            accelView.tag(2)
//            buttonView.tag(3)
//            crownView.tag(4)
            settingsView.tag(5)
        }.environmentObject(settings).environmentObject(store).navigationBarHidden(true)
    }
}

// struct ContentView_Previews: PreviewProvider {
//     static var previews: some View {
//         ContentView(frame: WKInterfaceDevice.current().screenBounds.size, hapticCallback: { (Double) -> Void in })
//     }
// }
