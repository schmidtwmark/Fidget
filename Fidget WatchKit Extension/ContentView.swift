//
//  ContentView.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 6/26/21.
//

import SwiftUI
import Combine
import CoreMotion

typealias AccelerationVector = simd_double3;
typealias VelocityVector = simd_double3;
typealias PositionVector = simd_double3;

class MotionManager : ObservableObject {
    private var motionManager: CMMotionManager;
    
    @Published
    var gravitationalAcceleration: AccelerationVector = vector3(0.0, 0.0, 0.0)
    
    @Published
    var playerPosition: PositionVector = vector3(0.0, 0.0, 0.0)
    var playerVelocity: VelocityVector = vector3(0.0, 0.0, 0.0)
    
    init() {
        self.motionManager = CMMotionManager()
        self.motionManager.accelerometerUpdateInterval = 1/60
        self.motionManager.startAccelerometerUpdates(to: .main) { (accelerometerData, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            if let accelData = accelerometerData {
                self.gravitationalAcceleration = vector3(accelData.acceleration.x, accelData.acceleration.y, accelData.acceleration.z);
            }
            
            let oppositeGravity = -self.gravitationalAcceleration;
            let cosTheta = oppositeGravity.z;
            let theta = acos(cosTheta); // Radians?
            
            
        }
    }
}

struct ContentView: View {
    
    @ObservedObject
    var motion: MotionManager
    
    var body: some View {
        ZStack {
            Text("🥺").position(x: 20.0, y: 20.0)
            VStack {
                Text("Accel Data")
                Text(String(format: "X: %.2f", motion.gravitationalAcceleration.x))
                Text(String(format: "Y: %.2f", motion.gravitationalAcceleration.y))
                Text(String(format: "Z: %.2f", motion.gravitationalAcceleration.z))
            }
        }
       
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(motion: MotionManager())
    }
}
