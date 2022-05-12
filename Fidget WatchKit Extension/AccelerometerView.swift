import SwiftUI
import Combine
import CoreMotion

typealias AccelerationVector = SIMD2<Double>;
typealias VelocityVector = SIMD2<Double>;
typealias PositionVector = SIMD2<Double>;

class MotionManager : NSObject, ObservableObject, WKExtensionDelegate{
    private var motionManager: CMMotionManager
    private var playHapticCallback: (Double) -> Void
    private let frame: Frame
    private let collisionFactor = 0.8
    private let gravityFactor = 30.0
    public var invert: Bool
//    private let frictionFactor = 0.01
    private let frictionFactor = 0.02
    private var run: Bool = false
    
    @Published
    var goalPosition = SIMD2<Double>(0.0, 0.0)
    
    @Published
    var goalCount = 0
    
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
        print("Stopping motion updates")
        self.run = false
        self.motionManager.stopAccelerometerUpdates()
    }
    
    func resetPlayer() {
        self.playerPosition = SIMD2<Double>(self.frame.width / 2.0 , self.frame.height / 2.0)
        self.playerVelocity = SIMD2<Double>(-50.0, 50.0)
        self.gravitationalAcceleration = SIMD2<Double>(0.0, 0.0)
        
        self.goalPosition = newGoalPosition()
        self.goalCount = 0
    }
    
    func getCornerCollision(lastX: Double, lastY: Double, offset: CGSize) {
        let radiusSquared = self.frame.cornerRadius * self.frame.cornerRadius;
        
        let px = self.playerPosition.x - offset.width
        let py = self.playerPosition.y - offset.height;
        
        if px * px + py * py > radiusSquared {
            // Out of bounds
            let lastX = lastX - offset.width
            let lastY = lastY - offset.height
            
            var newX = (lastX + px) / 2.0
            var newY = (lastY + py) / 2.0
            
            let exitRad = sqrt(newX * newX + newY * newY)
            newX *= self.frame.cornerRadius / exitRad
            newY *= self.frame.cornerRadius / exitRad
            
            self.playerPosition.x = newX + offset.width;
            self.playerPosition.y = newY + offset.height;
            
            
            let twiceProjFactor = 2 * (newX * self.playerVelocity.x + newY * self.playerVelocity.y) / radiusSquared
            self.playerVelocity.x = self.playerVelocity.x - twiceProjFactor * newX;
            self.playerVelocity.y = self.playerVelocity.y - twiceProjFactor * newY;
            self.playHapticCallback(sqrt(self.playerVelocity.x * self.playerVelocity.x + self.playerVelocity.y * self.playerVelocity.y))
        }
    }
    
    
    func tick() {
        if !self.run {
            return
        }
        let lastX = self.playerPosition.x
        let lastY = self.playerPosition.y
        self.playerVelocity += self.gravityFactor * self.gravitationalAcceleration;
        self.playerVelocity -= self.playerVelocity * self.frictionFactor
        self.playerPosition += self.motionManager.accelerometerUpdateInterval * self.playerVelocity;
    
        // Collision handling:
        if self.playerPosition.x < self.frame.left{
            // Colliding with left wall
            self.playerPosition.x = self.frame.left - (self.playerPosition.x - self.frame.left)
            self.bounceX()
        }
        if self.playerPosition.x > self.frame.right {
            // Colliding with right wall
            self.playerPosition.x = self.frame.right - (self.playerPosition.x - self.frame.right)
            self.bounceX()
        }
        if self.playerPosition.y < self.frame.top{
            // Colliding with top
            self.playerPosition.y = self.frame.top - (self.playerPosition.y - self.frame.top)
            self.bounceY()
        }
        
        if self.playerPosition.y > self.frame.bottom {
            // Colliding with bottom
            self.playerPosition.y = self.frame.bottom - (self.playerPosition.y - self.frame.bottom)
            self.bounceY()
        }
        
        // ENTER CORNER BOUNCING SHIT
        
        if self.playerPosition.x < self.frame.left - self.frame.cornerRadius {
            if self.playerPosition.y < self.frame.top - self.frame.cornerRadius {
                // TOP LEFT
                self.getCornerCollision(lastX: lastX, lastY: lastY, offset: CGSize(width: self.frame.cornerRadius, height: self.frame.cornerRadius))
            } else if self.playerPosition.y > self.frame.bottom - self.frame.cornerRadius {
                // BOTTOM LEFT
                self.getCornerCollision(lastX: lastX, lastY: lastY, offset: CGSize(width: self.frame.cornerRadius, height: self.frame.bottom - self.frame.cornerRadius))
            }
        } else if self.playerPosition.x > self.frame.right - self.frame.cornerRadius {
            if self.playerPosition.y < self.frame.top - self.frame.cornerRadius {
                // TOP RIGHT
                self.getCornerCollision(lastX: lastX, lastY: lastY, offset: CGSize(width: self.frame.right - self.frame.cornerRadius, height: self.frame.cornerRadius))
            } else if self.playerPosition.y > self.frame.bottom - self.frame.cornerRadius {
                // BOTTOM RIGHT
                self.getCornerCollision(lastX: lastX, lastY: lastY, offset: CGSize(width: self.frame.right - self.frame.cornerRadius, height: self.frame.bottom - self.frame.cornerRadius))
            }
        }
        
        // CHECK COLLISION WITH GOAL
        
        if abs(self.goalPosition.x - self.playerPosition.x) < 10.0 && abs(self.goalPosition.y - self.playerPosition.y) < 10.0 {
            print("Hit goal")
            self.goalPosition = newGoalPosition()
            self.playHapticCallback(0.0)
            self.goalCount = (self.goalCount + 1) % 100
        }
        
    }
    
    func newGoalPosition() -> PositionVector {
        return SIMD2<Double>(
            Double.random(in: (self.frame.left + 20.0)..<(self.frame.right - 20.0)),
            Double.random(in: (self.frame.top + 20.0)..<(self.frame.bottom - 20.0))
        )
    }
    
    func initUpdates() {
        self.run = true
        print("Starting updates")
        self.motionManager.startAccelerometerUpdates(to: .main) { (accelerometerData, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            guard self.run else {
                return
            }
            
            if let accelData = accelerometerData {
                let modifier = self.invert ? -1.0 : 1.0
                self.gravitationalAcceleration = SIMD2<Double>(modifier * accelData.acceleration.x, modifier * -accelData.acceleration.y);
                self.tick()
            } else {
                print("Invalid accelerometer data")
            }
        }
    }
    
    init(frame: Frame, playHaptic: @escaping (Double) -> Void, invert: Bool) {
        self.frame = frame
        self.invert = invert
        self.motionManager = CMMotionManager()
        self.playHapticCallback = playHaptic
        self.motionManager.accelerometerUpdateInterval = 1/60
        super.init()
        
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

    var showDebug: Bool
    
    @State var showScore: Bool = true
    var frame: Frame

//    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect() // TODO disable before shipping

    init(frame: Frame, hapticCallback: @escaping (Double) -> Void, motionManager: MotionManager, showDebug: Bool ) {
        self.frame = frame
        _motion = StateObject(wrappedValue: motionManager)
        self.showDebug = showDebug
    }
    
    

    var body: some View {
        settings.theme.getBackground().mask(
        ZStack {
            Circle().fill(Color.white).frame(width: 20.0, height: 20.0).position(x: motion.playerPosition.x, y: motion.playerPosition.y)
            ZStack {
                if self.showScore {
                   Text("\(motion.goalCount)").font(.system(size: 10))
                }
                Circle().stroke(Color.white).frame(width: 20.0, height: 20.0)
                
            }.position(x: motion.goalPosition.x, y: motion.goalPosition.y)

            if self.showDebug {
                AccelerometerDebugView(motion: motion)
            }
            RoundedRectangle(cornerRadius: self.frame.cornerRadius, style: .continuous)
                .strokeBorder(Color.white, lineWidth: 4)
                .frame(width: self.frame.width, height: self.frame.height)
                .position(x: self.frame.left + (self.frame.width / 2.0), y: self.frame.top + (self.frame.height / 2.0))
        })
        .contentShape(Rectangle())
        .onTapGesture {
            print("On tap, toggling show score")
            self.showScore = !self.showScore
        }
        .onDisappear(perform: {
            motion.stopUpdates()
        })
//        }.background(Color.gray)
//         TO ENABLE DEBUG STUFF
            // TODO DISABLE BEFORE SHIPPING
//        .onReceive(timer) {
//            input in
//            self.motion.tick()
//        }
    }
}
struct AccelerometerView_Previews: PreviewProvider {
    static var previews: some View {
        AccelerometerView(frame:  getFrame(WKInterfaceDevice.current().screenBounds.size), hapticCallback: { (Double) -> Void in }, motionManager: MotionManager(frame: getFrame(WKInterfaceDevice.current().screenBounds.size), playHaptic: { (Double) -> Void in }, invert: false), showDebug: false).previewDevice("Apple Watch Series 7 - 41mm").environmentObject(AppSettings())
    }
}
