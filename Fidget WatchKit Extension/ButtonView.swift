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

    init(frame: CGSize, hapticCallback: @escaping (Double) -> Void) {
        self.hapticCallback = hapticCallback
    }

    var body: some View {
        ZStack {
            Button(action: {
            }){
                Text("Press")
            }.onTouchDownGesture(downCallback: {
                hapticCallback(0.0)
                isPressed = true
            }, upCallback: {
                isPressed = false
                hapticCallback(0.0)
            }) .buttonStyle(MSButtonStyle())
            Circle().fill(settings.color.rawColor)
                .frame(width: 100.0,  height: 100.0)
                .scaleEffect(isPressed ? 5.0 : 0.0, anchor: .center)
                .animation(isPressed ? Animation.easeInOut(duration: 1.5) : Animation.default, value: isPressed)
                .opacity(isPressed ? 0.7 : 0.1)
        }.onDisappear(perform: {
            isPressed = false
        })
       
    }
}
