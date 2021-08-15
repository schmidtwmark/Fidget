import SwiftUI
import Combine
import CoreMotion

typealias AccelerationVector = SIMD2<Double>;
typealias VelocityVector = SIMD2<Double>;
typealias PositionVector = SIMD2<Double>;

class MotionManager : ObservableObject {
    private var motionManager: CMMotionManager
    private var playHapticCallback: (Double) -> Void
    private let frame: CGSize
    private let collisionFactor = 0.8
    private let gravityFactor = 5.0
    private let frictionFactor = 0.01
    private let cornerRadius: Double
    
    @Published
    var gravitationalAcceleration: AccelerationVector = SIMD2<Double>(0.0, 0.0)
    
    @Published
    var playerPosition: PositionVector = SIMD2<Double>(0.0, 0.0)
    
    @Published
    var playerVelocity: VelocityVector = SIMD2<Double>(0.0, 0.0)
    
    func bounceX() {
        self.playerVelocity.x = -collisionFactor * self.playerVelocity.x
        self.playHapticCallback(sqrt(self.playerVelocity.x * self.playerVelocity.x + self.playerVelocity.y * self.playerVelocity.y))
    }
    
    func bounceY() {
        self.playerVelocity.y = -collisionFactor * self.playerVelocity.y
        self.playHapticCallback(sqrt(self.playerVelocity.x * self.playerVelocity.x + self.playerVelocity.y * self.playerVelocity.y))
    }
    
    func stopUpdates() {
        self.motionManager.stopAccelerometerUpdates()
    }
    
    func resetPlayer() {
        self.playerPosition = SIMD2<Double>(self.frame.width / 2.0 , self.frame.height / 2.0)
        self.playerVelocity = SIMD2<Double>(0.0, 0.0)
        self.gravitationalAcceleration = SIMD2<Double>(0.0, 0.0)
    }
    
    func getCornerCollision(lastX: Double, lastY: Double, offset: CGSize) {
        let radiusSquared = self.cornerRadius * self.cornerRadius;
        
        let px = self.playerPosition.x - offset.width
        let py = self.playerPosition.y - offset.height;
        
        if px * px + py * py > radiusSquared {
            // Out of bounds
            var lastX = lastX - offset.width
            var lastY = lastY - offset.height
            
            var newX = (lastX + px) / 2.0
            var newY = (lastY + py) / 2.0
            
            let exitRad = sqrt(newX * newX + newY * newY)
            newX *= self.cornerRadius / exitRad
            newY *= self.cornerRadius / exitRad
            
            self.playerPosition.x = newX + offset.width;
            self.playerPosition.y = newY + offset.height;
            
            
            let twiceProjFactor = 2 * (newX * self.playerVelocity.x + newY * self.playerVelocity.y) / radiusSquared
            self.playerVelocity.x = self.playerVelocity.x - twiceProjFactor * newX;
            self.playerVelocity.y = self.playerVelocity.y - twiceProjFactor * newY;
            self.playHapticCallback(sqrt(self.playerVelocity.x * self.playerVelocity.x + self.playerVelocity.y * self.playerVelocity.y))
        }
    }
    
    func initUpdates() {
        self.motionManager.startAccelerometerUpdates(to: .main) { (accelerometerData, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            if let accelData = accelerometerData {
                var lastX = self.playerPosition.x
                var lastY = self.playerPosition.y
                self.gravitationalAcceleration = SIMD2<Double>(accelData.acceleration.x, -accelData.acceleration.y);
                self.playerVelocity += self.gravityFactor * self.gravitationalAcceleration;
                self.playerVelocity -= self.playerVelocity * self.frictionFactor
                self.playerPosition += self.motionManager.accelerometerUpdateInterval * self.playerVelocity;
            
                // Collision handling:
                if self.playerPosition.x < 0.0 {
                    // Colliding with left wall
                    self.playerPosition.x = -self.playerPosition.x
                    self.bounceX()
                }
                if self.playerPosition.x > self.frame.width {
                    // Colliding with right wall
                    self.playerPosition.x = self.frame.width - (self.playerPosition.x - self.frame.width)
                    self.bounceX()
                }
            
                if self.playerPosition.y < 0.0 {
                    // Colliding with top
                    self.playerPosition.y = -self.playerPosition.y
                    self.bounceY()
                }
                
                if self.playerPosition.y > self.frame.height {
                    // Colliding with bottom
                    self.playerPosition.y = self.frame.height - (self.playerPosition.y - self.frame.height)
                    self.bounceY()
                }
                
                // ENTER CORNER BOUNCING SHIT
                
                if self.playerPosition.x < self.cornerRadius {
                    if self.playerPosition.y < self.cornerRadius {
                        // TOP LEFT
                        self.getCornerCollision(lastX: lastX, lastY: lastY, offset: CGSize(width: self.cornerRadius, height: self.cornerRadius))
                    } else if self.playerPosition.y > self.frame.height - self.cornerRadius {
                        // BOTTOM LEFT
                        self.getCornerCollision(lastX: lastX, lastY: lastY, offset: CGSize(width: self.cornerRadius, height: self.frame.height - self.cornerRadius))
                    }
                } else if self.playerPosition.x > self.frame.width - self.cornerRadius {
                    if self.playerPosition.y < self.cornerRadius {
                        // TOP RIGHT
                        self.getCornerCollision(lastX: lastX, lastY: lastY, offset: CGSize(width: self.frame.width - self.cornerRadius, height: self.cornerRadius))
                    } else if self.playerPosition.y > self.frame.height - self.cornerRadius {
                        // BOTTOM RIGHT
                        self.getCornerCollision(lastX: lastX, lastY: lastY, offset: CGSize(width: self.frame.width - self.cornerRadius, height: self.frame.height - self.cornerRadius))
                    }
                }
            }
            
                        
        }
    }
    
    init(frame: CGSize, cornerRadius: Double, playHaptic: @escaping (Double) -> Void) {
        self.frame = frame
        self.cornerRadius = cornerRadius
        self.motionManager = CMMotionManager()
        self.playHapticCallback = playHaptic
        self.motionManager.accelerometerUpdateInterval = 1/60
        self.resetPlayer()
    }
}

struct AccelerometerDebugView: View {
    @ObservedObject
    var motion: MotionManager
    var body: some View {
        VStack {
            Text(String(format: "Player: (%.2f, %.2f)", motion.playerPosition.x, motion.playerPosition.y))
            Text(String(format: "Velocity: (%.2f, %.2f)", motion.playerVelocity.x, motion.playerVelocity.y))
            Text(String(format: "Acceleration: (%.2f, %.2f)", motion.gravitationalAcceleration.x, motion.gravitationalAcceleration.y))
        }
    }
}


struct AccelerometerView: View {
    
    @StateObject
    var motion: MotionManager

    @EnvironmentObject var settings: AppSettings 

    var debugView: AccelerometerDebugView?
    var frame: CGSize
    var cornerRadius: Double

    init(frame: CGSize, cornerRadius: Double, hapticCallback: @escaping (Double) -> Void, showDebug: Bool) {
        self.frame = frame
        self.cornerRadius = cornerRadius
        let motion = MotionManager(frame: CGSize(width: frame.width, height: frame.height), cornerRadius: cornerRadius, playHaptic: hapticCallback)
        _motion = StateObject(wrappedValue: motion)
        self.debugView = showDebug ?  AccelerometerDebugView(motion: motion) : nil
    }
    
    

    var body: some View {
        ZStack {
            Circle().fill(settings.color.rawColor).frame(width: 20.0, height: 20.0).position(x: motion.playerPosition.x, y: motion.playerPosition.y)
            if let debugView = self.debugView {
                debugView
            }
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(settings.color.rawColor, lineWidth: 3)
                .frame(width: self.frame.width, height: self.frame.height)
        }.onAppear {
            motion.resetPlayer()
            motion.initUpdates()
        }
        .onDisappear {
            motion.stopUpdates()
        }
    }
}
