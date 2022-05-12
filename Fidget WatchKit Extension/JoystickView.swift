//
//  JoystickView.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 1/2/22.
//

import Foundation
import SwiftUI

struct JoystickView: View {
    
    @EnvironmentObject var settings : AppSettings
    
    @State var offset = CGSize.zero
    @State var old_d_2 = 0.0
    let frame: Frame
    var hapticCallback: (Double) -> Void
    
    let MAXIMUM = 0.8
    let HANDLE = 0.3
    
    var body: some View {
        ZStack {
            settings.theme.getBackground().mask(Circle().fill(Color.white).opacity(0.2).frame(width: self.frame.width * MAXIMUM, height: self.frame.height * MAXIMUM))
            settings.theme.getBackground().mask(Circle()
                .stroke(Color.white))
            .frame(width: self.frame.width * HANDLE, height: self.frame.height * HANDLE)
            .offset(self.offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        let new_x = gesture.translation.width
                        let new_y = gesture.translation.height
                        let d_2 = new_x * new_x + new_y * new_y
                        let maximum_r = (self.frame.width / 2) * MAXIMUM;
                        let max_r_2 = maximum_r * maximum_r
                        if d_2 > max_r_2 {
                            // Out of bounds
                            if self.old_d_2 < max_r_2 {
                                // If the last d2 was out of range, play the haptic
                                print("Max: \(max_r_2), r^2: \(d_2), new_x: \(new_x), new_y: \(new_y)")
                                self.hapticCallback(0.0)
                            }
                            let d = sqrt(d_2)
                            self.offset = CGSize(width: new_x / d * maximum_r, height: new_y / d * maximum_r)
                        } else {
                            self.offset = gesture.translation
                        }
                        self.old_d_2 = d_2
                        
                    }
                
                    .onEnded { _ in
                        self.hapticCallback(0.0)
                        withAnimation(.easeIn(duration: 0.1)) {
                            print("Ending animation")
                            self.offset = .zero
                        }
                    }
            )
        }
    }
    
}

struct JoystickView_Previews: PreviewProvider {
    static var previews: some View {
        JoystickView(frame:  getFrame(WKInterfaceDevice.current().screenBounds.size), hapticCallback: { (Double) -> Void in }).previewDevice("Apple Watch Series 7 - 41mm").environmentObject(AppSettings())
    }
}
