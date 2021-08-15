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

    @EnvironmentObject var settings : AppSettings

    @State var crownRotation = 0.0

    init(frame: CGSize) {
        self.frame = frame
    }

    var body: some View {
        ZStack {
            Triangle()
//                .transform(CGAffineTransform(scaleX: 0.5, y: 0.5))
                .stroke(settings.color.rawColor, lineWidth: 3)
                .rotationEffect(.degrees(crownRotation), anchor: .center)
                // .offset(x: self.frame.width / 4, y: self.frame.height / 4)
            Text("Rotation: \(crownRotation)")
        }.focusable().digitalCrownRotation($crownRotation, from: 0.0, through: 360.0, sensitivity: .high, isContinuous: true)
       
    }
}
