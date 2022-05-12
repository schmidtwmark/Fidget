//
//  MSButton.swift
//  MSButton
//
//  Created by Mark Schmidt on 9/6/21.
//

import SwiftUI
import Combine

struct MSButtonStyle: ButtonStyle {
    
    @EnvironmentObject var settings : AppSettings
    
    
    func makeBody(configuration: Configuration) -> some View {
        settings.theme.getBackground().mask(
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color.white : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(Color.white, lineWidth: 2.0))
        )
    }
}

extension View {
    func onTouchDownGesture(downCallback: @escaping () -> Void, upCallback: @escaping () -> Void ) -> some View {
        modifier(OnTouchDownGestureModifier(callback: downCallback, upCallback: upCallback))
    }
}

private struct OnTouchDownGestureModifier: ViewModifier {
    @State private var tapped = false
    let callback: () -> Void
    let upCallback: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(DragGesture(minimumDistance: 0)
                .onChanged { val in
                    if !self.tapped {
                        self.tapped = true
                        self.callback()
                    }
                }
                .onEnded { _ in
                    self.tapped = false
                    self.upCallback()
                })
    }
}
