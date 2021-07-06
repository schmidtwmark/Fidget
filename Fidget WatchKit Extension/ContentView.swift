//
//  ContentView.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 6/26/21.
//

import SwiftUI
import Combine
import CoreMotion

typealias AccelerationVector = SIMD2<Double>;
typealias VelocityVector = SIMD2<Double>;
typealias PositionVector = SIMD2<Double>;

class MotionManager : ObservableObject {
    private var motionManager: CMMotionManager;
    
    @Published
    var gravitationalAcceleration: AccelerationVector = SIMD2<Double>(0.0, 0.0)
    
    @Published
    var playerPosition: PositionVector = SIMD2<Double>(0.0, 0.0)
    
    var playerVelocity: VelocityVector = SIMD2<Double>(0.0, 0.0)
    
    init() {
        self.motionManager = CMMotionManager()
        self.motionManager.accelerometerUpdateInterval = 1/60
        self.motionManager.startAccelerometerUpdates(to: .main) { (accelerometerData, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            if let accelData = accelerometerData {
                self.gravitationalAcceleration = SIMD2<Double>(accelData.acceleration.x, accelData.acceleration.y);
                self.playerVelocity += self.gravitationalAcceleration;
                self.playerPosition += self.motionManager.accelerometerUpdateInterval * self.playerVelocity;
                
                
            }
            
            
            
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
                Text(String(format: "X: %.2f", motion.gravitationalAcceleration.x))
                Text(String(format: "Y: %.2f", motion.gravitationalAcceleration.y))
            }
        }
       
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(motion: MotionManager())
    }
}
