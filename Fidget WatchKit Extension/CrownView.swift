import WatchKit
import SwiftUI
import Combine



struct Triangle : Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.width * 0.5, y: rect.height * 0.5) 
        let offset = rect.width * 0.25
        let offsetXComponent = offset * (3.squareRoot() / 2)
        let offsetYComponent = offset / 2

        let path = CGMutablePath()
        let startPoint = CGPoint(x: center.x, y: center.y - offset)

        path.move(to: startPoint)
        path.addLine(to: CGPoint(x: center.x + offsetXComponent, y: center.y + offsetYComponent))
        path.addLine(to: CGPoint(x: center.x - offsetXComponent, y: center.y + offsetYComponent))
        path.closeSubpath()
        return Path(path)
    }
}

struct CrownView: View{
    var frame: CGSize
    var motion: MotionManager

    @EnvironmentObject var settings : AppSettings

    @State var crownRotation = 0.0

    init(frame: CGSize, motionManager: MotionManager) {
        self.frame = frame
        self.motion = motionManager
    }

    var body: some View {
        ZStack {
            Triangle()
                .stroke(settings.color.rawColor, lineWidth: 3)
                .rotationEffect(.degrees(crownRotation), anchor: .center)
        }.focusable().digitalCrownRotation($crownRotation, from: 0.0, through: 360.0, by: 10.0, sensitivity: .high, isContinuous: true).onAppear(perform: {
            motion.stopUpdates()
        })
       
    }
}
