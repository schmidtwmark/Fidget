//
//  ButtonView.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 7/24/21.
//

import SwiftUI
import Combine



struct ButtonView: View {
    
    @EnvironmentObject var settings : AppSettings
    
    @State var isPressed = false
    var hapticCallback: (Double) -> Void
    var frame: CGSize
    
    init(frame: CGSize, hapticCallback: @escaping (Double) -> Void) {
        self.frame = frame
        self.hapticCallback = hapticCallback
    }
    
    var body: some View {
        ZStack {
            settings.theme.getBackground().mask(
                Circle().fill(Color.white)
            )
            .frame(width: 100.0,  height: 50.0)
            .scaleEffect(isPressed ? 6.0 : 0.0, anchor: .center)
            .animation(isPressed ? Animation.easeInOut(duration: 1.5) : Animation.default, value: isPressed)
            .opacity(isPressed ? 0.7 : 0.1)
            Button(action: {
            }){
                settings.theme.getBackground().mask(
                    Text("Press"))
            }.onTouchDownGesture(downCallback: {
                hapticCallback(0.0)
                print("Pressed")
                isPressed = true
            }, upCallback: {
                print("Unpressed")
                isPressed = false
                hapticCallback(0.0)
            }).buttonStyle(MSButtonStyle()).frame(width: 80, height: 40)
        }.onDisappear(perform: {
            isPressed = false
        })
        
    }
}
