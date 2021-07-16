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
    
    private let frame: CGSize;
    
    private let collisionFactor = 0.8;
    private let gravityFactor = 5.0;
    private let frictionFactor = 0.01;
    
    @Published
    var gravitationalAcceleration: AccelerationVector = SIMD2<Double>(0.0, 0.0)
    
    @Published
    var playerPosition: PositionVector = SIMD2<Double>(0.0, 0.0)
    
    @Published
    var playerVelocity: VelocityVector = SIMD2<Double>(0.0, 0.0)
    
    func bounceX() {
        self.playerVelocity.x = -collisionFactor * self.playerVelocity.x
        sendBump(velocity: abs(self.playerVelocity.x))
    }
    
    func bounceY() {
        self.playerVelocity.y = -collisionFactor * self.playerVelocity.y
        sendBump(velocity: abs(self.playerVelocity.y))
    }
    
    func sendBump(velocity: Double) {
        let impactMed = UIImpactFeedbackGenerator(style: .heavy)
        impactMed.impactOccurred(intensity: velocity / 10.0)
    }
    
    init(frame: CGSize) {
        self.frame = frame
        self.playerPosition = SIMD2<Double>(frame.width / 2.0, frame.height / 2.0)
        self.motionManager = CMMotionManager()
        self.motionManager.accelerometerUpdateInterval = 1/60
        self.motionManager.startAccelerometerUpdates(to: .main) { (accelerometerData, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            if let accelData = accelerometerData {
                self.gravitationalAcceleration = SIMD2<Double>(accelData.acceleration.x, -accelData.acceleration.y);
                self.playerVelocity += self.gravityFactor * self.gravitationalAcceleration;
                self.playerVelocity -= self.playerVelocity * self.frictionFactor
                self.playerPosition += self.motionManager.accelerometerUpdateInterval * self.playerVelocity;
            }
            
            // Collision handling:
            
            if self.playerPosition.x < 0.0 {
                // Colliding with left wall
                self.playerPosition.x = -self.playerPosition.x
                self.bounceX()
            }
            if self.playerPosition.x > frame.width {
                // Colliding with right wall
                self.playerPosition.x = frame.width - (self.playerPosition.x - frame.width)
                self.bounceX()
            }
            
            if self.playerPosition.y < 0.0 {
                // Colliding with top
                self.playerPosition.y = -self.playerPosition.y
                self.bounceY()
            }
            
            if self.playerPosition.y > frame.height {
                // Colliding with bottom
                self.playerPosition.y = frame.height - (self.playerPosition.y - frame.height)
                self.bounceY()
            }
        }
    }
}

struct ContentView: View {
    
    @ObservedObject
    var motion: MotionManager
    
    var body: some View {
        ZStack {
            Text("🥺").position(x: motion.playerPosition.x, y: motion.playerPosition.y)
            VStack {
                Text(String(format: "Player: (%.2f, %.2f)", motion.playerPosition.x, motion.playerPosition.y))
                Text(String(format: "Velocity: (%.2f, %.2f)", motion.playerVelocity.x, motion.playerVelocity.y))
                Text(String(format: "Acceleration: (%.2f, %.2f)", motion.gravitationalAcceleration.x, motion.gravitationalAcceleration.y))
            }
            
        }
       
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(motion: MotionManager(frame: UIScreen.main.bounds.size))
    }
}
