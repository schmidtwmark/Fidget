//
//  ContentView.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 6/26/21.
//

import SwiftUI
import Combine
import CoreMotion


struct ContentView: View {
    var accelView: AccelerometerView 

    init(frame: CGSize) {
        self.accelView = AccelerometerView(frame: frame, playerColor: Color.purple, borderColor: Color.purple, showDebug: true)
    }
    
    var body: some View {
        self.accelView
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(frame: UIScreen.main.bounds.size)
    }
}
