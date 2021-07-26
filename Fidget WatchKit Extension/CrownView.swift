import WatchKit
import SwiftUI
import Combine

struct Triangle : Shape {
    func path(in rect: CGRect) -> Path {
        let path = CGMutablePath()
        let startPoint = CGPoint(x: 0, y: 0)
        path.move(to: startPoint)
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height))
        path.closeSubpath()
        return Path(path)
    }
}

struct CrownView: View{
    var frame: CGSize

    var debugView: Text? 

    @EnvironmentObject var settings : AppSettings

    @State var crownRotation = 0.0

    init(frame: CGSize, showDebug: Bool) {
        self.frame = frame
        showDebug ? self.debugView = Text("Rotation: \(self.crownRotation)") : nil
        
    }

    var body: some View {
        ZStack {
            Triangle()
                    .transform(CGAffineTransform(scaleX: 0.5, y: 0.5))
                    .rotation(Angle(radians: self.crownRotation))
                    .stroke(settings.color.rawColor, lineWidth: 3)
                    .offset(x: self.frame.width / 4, y: self.frame.height / 4)
            if let debugView = self.debugView {
                debugView
            }
        }.digitalCrownRotation(self.$crownRotation)
       
    }
}
