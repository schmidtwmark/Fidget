//
//  BreathingView.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 9/4/21.
//

import Foundation
import SwiftUI
import Combine



struct BreatheIcon: View {
    let base = 20.0
    
    var body: some View {
        Rectangle().stroke(Color.white)
            .frame(width: base,  height: base)
    }
}


struct BreatheView: View{
    var frame: CGSize
    var hapticCallback: (Double) -> Void
    
    
    @State var isRunning: Date? = nil
    @State var message: String = "Square Breathing"
    @EnvironmentObject var settings : AppSettings
    @GestureState var isDetectingLongPress = false
    
    
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    init(frame: CGSize, hapticCallback: @escaping (Double) -> Void) {
        self.hapticCallback = hapticCallback
        self.frame = frame
    }
    
    let statements = ["Inhale", "Hold", "Exhale", "Hold"]
    
    func getStatement() -> String {
        if let startTime = isRunning {
            var interval = -startTime.timeIntervalSinceNow
            if(interval < 1.0) {
                return "Get Ready 4"
            } else if(interval < 2.0) {
                return "Get Ready 3"
            } else if(interval < 3.0) {
                return "Get Ready 2"
            } else if(interval < 4.0) {
                return "Get Ready 1"
            } else {
                interval = interval - 4.0
                let index = Int(exactly: (interval / 4.0).rounded(.towardZero))
                return statements[index! % statements.count]
            }
        } else {
            return "Square Breathing"
        }
    }
    
    
    var body: some View {
        VStack {
            settings.theme.getBackground().mask(Text(self.message)).frame(width: 150, height: 30)
            settings.theme.getBackground().mask(
                BreatheIcon()
                    .rotationEffect(Angle(degrees: isRunning != nil ? 315.0 : 0.0))
                    .scaleEffect(isRunning != nil ? 2.25 : 1.0, anchor: .center)
                    .animation(isRunning != nil ? Animation.easeInOut(duration: 4.0)
                        .delay(4.0)
                        .repeatForever() : Animation.default, value: isRunning)
            )
            Button(action: {
            }) {
                settings.theme.getBackground().mask(
                    Text("Hold to Start"))
            }
            .onTouchDownGesture(downCallback: {
                isRunning = Date()
            }, upCallback: {
                isRunning = nil
            })
            .buttonStyle(MSButtonStyle()).frame(width: 120, height: 30)
        }.onReceive(timer) {
            input in
            let oldMessage = self.message
            self.message = getStatement()
            if(self.message != oldMessage) {
                self.hapticCallback(0.0)
            }
        }
    }
}
