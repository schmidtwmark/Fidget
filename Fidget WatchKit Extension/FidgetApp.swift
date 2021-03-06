//
//  FidgetApp.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 6/26/21.
//

import SwiftUI

func watchHaptic(velocity: Double) {
//    print("Playing haptic, velocity is \(velocity)")
    WKInterfaceDevice.current().play(WKHapticType.click)
}


func getFrame(_ deviceBounds: CGSize) -> Frame{
    switch deviceBounds.width {
    case 136: // 38mm
        return Frame(bottom: deviceBounds.height - 19.0, right: deviceBounds.width, cornerRadius: 0.0)
    case 156: // 42mm
        return Frame(bottom: deviceBounds.height - 21.0, right: deviceBounds.width, cornerRadius: 0.0)
    case 162: // 40mm
        let offset = 28.0
        return Frame(top: -offset, bottom: deviceBounds.height - offset + 1.0, left: -1.0, right: deviceBounds.width , cornerRadius: 30.0)
    case 184: // 44mm
        let offset = 31.0
        return Frame(top: -offset, bottom: deviceBounds.height - offset, left: -1.0, right: deviceBounds.width, cornerRadius: 35.0)
    case 176.0: // 41 mm
        let offset = 34.0
        return Frame(top: -offset, bottom: deviceBounds.height - offset, left: -1.0, right: deviceBounds.width - 1.0, cornerRadius: 40.0)
    case 198.0: // 45 mm
        let offset = 35.0
        return Frame(top: -offset, bottom: deviceBounds.height - offset, left: -1.0, right: deviceBounds.width - 1.0, cornerRadius: 42.0)
    default:
        print("Unknown watch with width: \(deviceBounds.width)")
        return Frame(bottom: deviceBounds.height, right: deviceBounds.width, cornerRadius: 35.0)
    }
}

class ExtensionDelegate : NSObject, WKExtensionDelegate {
//    override init() {
//        print("Initializing extension delegate")
//        super.init()
//    }
//
    private var motion: MotionManager?
    private var tabViewManager: TabViewManager?
    func setMotionManager(motion: MotionManager) {
        self.motion = motion
    }
    func setTabViewManager(tabViewManager: TabViewManager) {
        self.tabViewManager = tabViewManager
    }
    
    func applicationDidBecomeActive() {
        print("Active app")
        if let motion = self.motion, let tabManager = self.tabViewManager{
            if tabManager.selection == 2 {
                motion.resetPlayer()
                motion.initUpdates()
            }
            
        }
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
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(frame: getFrame(WKInterfaceDevice.current().screenBounds.size), hapticCallback: watchHaptic, delegate: extensionDelegate)
            }
        }
    }
}
