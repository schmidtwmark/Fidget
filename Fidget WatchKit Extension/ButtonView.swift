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
    
    var hapticCallback: (Double) -> Void

    init(frame: CGSize, hapticCallback: @escaping (Double) -> Void) {
        self.hapticCallback = hapticCallback
    }

    var body: some View {
        Button(action: {hapticCallback(0.0)}){
            Text("Press")
        }.onTouchDownGesture {
            hapticCallback(0.0)
        }.buttonStyle(MSButtonStyle())
       
    }
}
