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
import TipKit

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

//final class TabViewManager: ObservableObject {
//    @Published var selection: Int = 0 {
//        didSet {
//            if selection == FidgetViewType.accelerometer.rawValue {
//                motion.resetPlayer()
//                motion.initUpdates()
//            } else {
//                motion.stopUpdates()
//                motion.resetPlayer()
//            }
//        }
//    }
//    
//    var motion: MotionManager
//    init(motion: MotionManager) {
//        self.motion = motion
//        
//    }
//}

struct IntroTip: Tip {
    var title: Text {
        Text("Fidgets 3.0")
    }


    var message: Text? {
        Text("Swipe between 6 interactive fidget toys!\n\nSwipe all the way to the right to reorder fidgets and change color theme.")
    }
}

struct HeadlineTipViewStyle: TipViewStyle {
    var settings : AppSettings
    
    
    func makeBody(configuration: TipViewStyle.Configuration) -> some View {

            VStack(alignment: .leading, spacing: 8.0) {
                HStack {
                    configuration.title.foregroundStyle(settings.theme.colors.first!)
                    Spacer()
                    Button(action: { configuration.tip.invalidate(reason: .tipClosed) }) {
                        Image(systemName: "xmark")
                    }.buttonStyle(.plain).frame(width: 40, height: 40)
                }
                configuration.message?.font(.system(size: 12.0))
            }.padding()
    }
}

struct ContentView : View  {
    var accelView: AccelerometerView 
    var crownView: CrownView
    var buttonView: ButtonView
    var settingsView: SettingsView
    var breatheView: BreatheView
    var switchView: SwitchView
    var joystickView: JoystickView
    var reorderView: ReorderView
    var frame: Frame
    
//    @ObservedObject var tabViewManager: TabViewManager
    
    @StateObject var settings : AppSettings = AppSettings()
    @StateObject var store: Store = Store()
    @AppStorage("order") var orderString = orderToString(defaultOrder)

    init(frame: Frame, hapticCallback: @escaping (Double) -> Void , delegate: ExtensionDelegate) {
        self.frame = frame
        let motion = MotionManager(frame: frame, playHaptic: hapticCallback, invert: WKInterfaceDevice.current().crownOrientation == .left)
//        tabViewManager = TabViewManager(motion: motion)
        delegate.setMotionManager(motion: motion)

        accelView = AccelerometerView(frame: frame, hapticCallback: hapticCallback, motionManager: motion, showDebug: SHOW_DEBUG)
        crownView = CrownView(frame: frame.size)
        buttonView = ButtonView(frame: frame.size, hapticCallback: hapticCallback)
        breatheView = BreatheView(frame: frame.size, hapticCallback: hapticCallback)
        switchView = SwitchView(frame: frame, hapticCallback: hapticCallback)
        joystickView = JoystickView(frame: frame, hapticCallback: hapticCallback)
        settingsView = SettingsView()
        reorderView = ReorderView()
//        delegate.setTabViewManager(tabViewManager: self.tabViewManager)
    }
    
    func typeToView(_ type: FidgetViewType) -> any View {
        switch type {
        case .accelerometer:
            return accelView
        case .crown:
            return crownView
        case .joystick:
            return joystickView
        case .lightswitch:
            return switchView
        case .button:
            return buttonView
        case .breathe:
            return breatheView
            
        }
        
    }
    
    var ordered: [(FidgetViewType, any View)] {
        stringToOrder(orderString).map({type in
            return (type, typeToView(type))
        })
    }
    
    
    
    var body: some View {
        TabView() {
            ForEach(stringToOrder(orderString), content: { type in
                switch type {
                case .accelerometer:
                    accelView.tag(type.rawValue)
                case .crown:
                    ZStack {
                        crownView.tag(type.rawValue)
                        TipView(IntroTip()).tipViewStyle(HeadlineTipViewStyle(settings: settings))
                    }
                case .joystick:
                    joystickView.tag(type.rawValue)
                case .lightswitch:
                    switchView.tag(type.rawValue)
                case .button:
                    buttonView.tag(type.rawValue)
                case .breathe:
                    breatheView.tag(type.rawValue)
                }
            })
            
            reorderView.tag(1000)
            settingsView.tag(500)
        }.environmentObject(settings).environmentObject(store).navigationBarHidden(frame.hideNavBar)
            .task {
                    // Configure and load your tips at app launch.
//                try! Tips.resetDatastore()
                    try? Tips.configure([
                        .displayFrequency(.immediate),
                        .datastoreLocation(.applicationDefault)
                    ])
                }
    }
}

// struct ContentView_Previews: PreviewProvider {
//     static var previews: some View {
//         ContentView(frame: WKInterfaceDevice.current().screenBounds.size, hapticCallback: { (Double) -> Void in })
//     }
// }
