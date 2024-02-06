//
//  FidgetApp.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 6/26/21.
//

import SwiftUI
import Dynamic

func watchHaptic(velocity: Double) {
//    print("Playing haptic, velocity is \(velocity)")
    WKInterfaceDevice.current().play(WKHapticType.click)
}


func getFrame(_ deviceBounds: CGSize) -> Frame{
    switch deviceBounds.width {
    case 162: // 40mm
        print("Detected 40 mm")
        let offset = 32.0
        return Frame(top: -offset, bottom: deviceBounds.height - offset + 1.0, left: -2.0, right: deviceBounds.width - 2.0, cornerRadius: 30.0)
    case 184: // 44mm
        print("Detected 44 mm")
        let offset = 38.0
        return Frame(top: -offset, bottom: deviceBounds.height - offset, left: -2.0, right: deviceBounds.width - 2.0, cornerRadius: 35.0)
    case 176.0: // 41 mm
        print("Detected 41 mm")
        let offset = 38.0
        return Frame(top: -offset, bottom: deviceBounds.height - offset, left: -1.0, right: deviceBounds.width - 2.0, cornerRadius: 40.0)
    case 198.0: // 45 mm
        print("Detected 45 mm")
        let offset = 42.0
        return Frame(top: -offset, bottom: deviceBounds.height - offset, left: -1.0, right: deviceBounds.width - 2.0, cornerRadius: 42.0)
    case 205.0:
        print("Detected 49 mm")
        let offset = 46.0
        return Frame(top: -offset, bottom: deviceBounds.height - offset, left: -1.0, right: deviceBounds.width - 2.0, cornerRadius: 54.0)
        
    default:
        print("Unknown watch with width: \(deviceBounds.width)")
        return Frame(bottom: deviceBounds.height, right: deviceBounds.width, cornerRadius: 35.0)
    }
}

class ExtensionDelegate : NSObject, WKApplicationDelegate {
//    override init() {
//        print("Initializing extension delegate")
//        super.init()
//    }
//
    private var motion: MotionManager?
//    private var tabViewManager: TabViewManager?
    func setMotionManager(motion: MotionManager) {
        self.motion = motion
    }
//    func setTabViewManager(tabViewManager: TabViewManager) {
//        self.tabViewManager = tabViewManager
//    }
    
    func applicationDidBecomeActive() {
        print("Active app")
        let app = Dynamic.PUICApplication.sharedPUICApplication()
        app._setStatusBarTimeHidden(true, animated: false, completion: nil)
//        if let motion = self.motion, let tabManager = self.tabViewManager{
//            if tabManager.selection == 2 {
//                motion.resetPlayer()
//                motion.initUpdates()
//            }
//            
//        }
    }
    func applicationDidEnterBackground() {
        print("Deactivating app")
        if let motion = self.motion {
            motion.stopUpdates()
        }
    }
    
    func deviceOrientationDidChange() {
        print("Orientation changed")
        if let motion = self.motion {
            motion.invert = WKInterfaceDevice.current().crownOrientation == .left
        }
    }
}

@main
struct FidgetApp: App {
    @WKApplicationDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(frame: getFrame(WKInterfaceDevice.current().screenBounds.size), hapticCallback: watchHaptic, delegate: extensionDelegate)
            }
        }
    }
}
