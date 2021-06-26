//
//  ContentView.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 6/26/21.
//

import SwiftUI
import Combine
import CoreMotion


class MotionManager : ObservableObject {
    private var motionManager: CMMotionManager;
    
    @Published
    var x: Double = 0.0
    
    @Published
    var y: Double = 0.0
    
    @Published
    var z: Double = 0.0
    
    init() {
        self.motionManager = CMMotionManager()
        self.motionManager.accelerometerUpdateInterval = 1/60
        self.motionManager.startAccelerometerUpdates(to: .main) { (accelerometerData, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            if let accelData = accelerometerData {
                self.x = accelData.acceleration.x
                self.y = accelData.acceleration.y
                self.z = accelData.acceleration.z
    
            }
        }
    }
}

struct ContentView: View {
    
    @ObservedObject
    var motion: MotionManager
    
    var body: some View {
        VStack {
            Text("Accel Data")
            Text("X: \(motion.x)")
            Text("Y: \(motion.y)")
            Text("Z: \(motion.z)")
        }
       
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(motion: MotionManager())
    }
}
