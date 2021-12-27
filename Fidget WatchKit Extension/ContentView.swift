//
//  ContentView.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 6/26/21.
//

import SwiftUI
import Combine
import CoreMotion
import UIKit

let SHOW_DEBUG = false

struct Frame {
    var top : Double = 0.0
    var bottom : Double
    var left : Double = 0.0
    var right : Double
    var cornerRadius : Double = 0.0
    
    var width : Double {
        get {
            return right - left
            
        }
    }
    var height : Double {
        get {
            return bottom - top
            
        }
        
        
    }
    var size: CGSize {
        get {
            return CGSize(width: self.width, height: self.height)
        }
    }
    
    var hideNavBar: Bool {
        get {
            return cornerRadius != 0.0
        }
    }
}

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
    var frame: Frame
    
    @ObservedObject var tabViewManager: TabViewManager
    
    @StateObject var settings : AppSettings = AppSettings()
    @StateObject var store: Store = Store()

    init(frame: Frame, hapticCallback: @escaping (Double) -> Void , delegate: ExtensionDelegate) {
        self.frame = frame
        let motion = MotionManager(frame: frame, playHaptic: hapticCallback, invert: WKInterfaceDevice.current().crownOrientation == .left)
        tabViewManager = TabViewManager(motion: motion)
        delegate.setMotionManager(motion: motion)

        accelView = AccelerometerView(frame: frame, hapticCallback: hapticCallback, motionManager: motion, showDebug: SHOW_DEBUG)
        crownView = CrownView(frame: frame.size)
        buttonView = ButtonView(frame: frame.size, hapticCallback: hapticCallback)
        breatheView = BreatheView(frame: frame.size, hapticCallback: hapticCallback)
        settingsView = SettingsView()
        delegate.setTabViewManager(tabViewManager: self.tabViewManager)
    }
    
    
    var body: some View {
        TabView(selection: $tabViewManager.selection) {
            crownView.tag(4)
            accelView.tag(2)
            buttonView.tag(3)
            breatheView.tag(1)
            settingsView.tag(5)
        }.environmentObject(settings).environmentObject(store).navigationBarHidden(frame.hideNavBar)
    }
}

// struct ContentView_Previews: PreviewProvider {
//     static var previews: some View {
//         ContentView(frame: WKInterfaceDevice.current().screenBounds.size, hapticCallback: { (Double) -> Void in })
//     }
// }
