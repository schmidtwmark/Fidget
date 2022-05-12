//
//  SwitchView.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 12/27/21.
//

import Foundation
import SwiftUI

enum RoundCorner {
    case bottom
    case top
}

struct MSRoundRectangle: Shape {
    let round: [RoundCorner]
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.size.width
        let h = rect.size.height
        
        let should_top = round.contains(.top)
        let should_bottom = round.contains(.bottom)
        
        let tr = should_top ? radius : 0.0
        let tl = should_top ? radius : 0.0
        let bl = should_bottom ? radius : 0.0
        let br = should_bottom ? radius : 0.0
        
        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.closeSubpath()
        
        return path
    }
}

class SwitchState: ObservableObject {
    @Published var topPressed = false
}

struct Switch : View {
    let location: RoundCorner
    let character: String
    @ObservedObject var state: SwitchState
    
    func pressed() -> Bool {
        (state.topPressed && location == .top ) || (!state.topPressed && location == .bottom)
    }
    var body: some View {
        ZStack {
            MSRoundRectangle(round: [location], radius: 8.0)
                .fill(pressed() ? Color.white : Color.clear)
            MSRoundRectangle(round: [location], radius: 8.0)
                .stroke(Color.white, lineWidth: 4)
            Text(character).bold()
        }
    }
}


struct SwitchView: View {
    
    @EnvironmentObject var settings : AppSettings
    
    @StateObject var state = SwitchState()
    private let frame: Frame
    var hapticCallback: (Double) -> Void
    
    func press() {
        withAnimation(.easeInOut(duration: 0.25)) {
            state.topPressed = !state.topPressed
        }
        self.hapticCallback(0.0)
        
    }
    init(frame: Frame, hapticCallback: @escaping (Double) -> Void) {
        self.frame = frame
        self.hapticCallback = hapticCallback
    }
    
    var body: some View {
        ZStack {
            // This is so dumb. SwiftUI decides to fudge gestures a bit, so either the switch has to be teeny tiny to leave room for your finger to swipe between screens, or I have to put the drag recognizer on a hidden view atop the switches. So dumb
            GeometryReader { geo in
                let area = CGRect(x:0, y:0, width: geo.size.width, height: geo.size.height)
                let gestureWidth = 20.0
                Rectangle()
                    .fill(Color.black.opacity(0.0001))
                    .frame(width: gestureWidth, height: geo.size.height)
                    .offset(x: geo.size.width / 2.0 - gestureWidth / 2.0, y: 0.0)
                    .gesture(DragGesture(minimumDistance: 0.0).onChanged({
                        gesture in
                        guard area.contains(gesture.startLocation) else { return }
                        let position = gesture.location
                        let frame = geo.size
                        let y = position.y
                        let separator = frame.height / 2.0
                        if ((y > separator) == state.topPressed) {
                            press()
                        }
                    }))
            }
            
            settings.theme.getBackground().allowsHitTesting(false).mask(
                ZStack {
                    RoundedRectangle(cornerRadius: self.frame.cornerRadius).fill(Color.white).scaleEffect(state.topPressed ? 1.05 : 0.0).opacity(0.2).allowsHitTesting(false).frame(width: self.frame.width, height: self.frame.height)
                    
                    ZStack {
                        VStack(spacing: 0.0){
                            Switch(location: .top, character: "I", state: state)
                            Switch(location: .bottom, character: "O", state: state)
                        }.allowsHitTesting(false)
                    }.frame(width: self.frame.width * 0.3, height: self.frame.height * 0.5)
                }.onDisappear(perform: {
                    state.topPressed = false
                })
            )
        }
    }
}


struct SwitchView_Previews: PreviewProvider {
    static var previews: some View {
        SwitchView(frame:  getFrame(WKInterfaceDevice.current().screenBounds.size), hapticCallback: { (Double) -> Void in }).previewDevice("Apple Watch Series 3 - 42mm").environmentObject(AppSettings())
    }
}
