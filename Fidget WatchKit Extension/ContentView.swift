//
//  ContentView.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 6/26/21.
//

import SwiftUI
import Combine
import CoreMotion


struct ContentView : View  {
    var accelView: AccelerometerView 
    var crownView: CrownView
    var buttonView: ButtonView



    init(frame: CGSize, hapticCallback: @escaping (Double) -> Void ) {
        let showDebug = true
        accelView = AccelerometerView(frame: frame, hapticCallback: hapticCallback, playerColor: Color.purple, showDebug: showDebug)
        crownView = CrownView(frame: frame, showDebug: true)
        buttonView = ButtonView(frame: frame, hapticCallback: hapticCallback)

    }
    
    var body: some View {
        TabView {
            buttonView
            crownView
            accelView
        }
    }
}

// struct ContentView_Previews: PreviewProvider {
//     static var previews: some View {
//         ContentView(frame: WKInterfaceDevice.current().screenBounds.size, hapticCallback: { (Double) -> Void in })
//     }
// }
