import WatchKit
import SwiftUI
import Combine

class CrownManager : NSObject, ObservableObject, WKCrownDelegate{ 
   @Published
   var rotation: Double = 0.0

   func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
       self.rotation += rotationalDelta
       // TODO wraparound rotation
       print("Got rotation delta \(rotationalDelta)")
   }

}

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

    @StateObject
    var crownManager: CrownManager

    init(frame: CGSize, showDebug: Bool) {
        self.frame = frame
        self._crownManager = StateObject(wrappedValue: CrownManager())
        showDebug ? self.debugView = Text("Rotation: \(self.crownManager.rotation)") : nil
    }

    var body: some View {
        ZStack {
            Triangle()
                    .transform(CGAffineTransform(scaleX: 0.5, y: 0.5))
                    .rotation(Angle(radians: self.crownManager.rotation))
                    .stroke(Color.purple, lineWidth: 3)
                    .offset(x: self.frame.width / 4, y: self.frame.height / 4)
            if let debugView = self.debugView {
                debugView
            }
        }
       
    }
}
