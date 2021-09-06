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
        configuration.label
            .padding()
            .foregroundColor(settings.color.rawColor)
            .background(configuration.isPressed ? settings.color.rawColor : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(settings.color.rawColor, lineWidth: 2.0))
    }
}

extension View {
    func onTouchDownGesture(callback: @escaping () -> Void) -> some View {
        modifier(OnTouchDownGestureModifier(callback: callback))
    }
}

private struct OnTouchDownGestureModifier: ViewModifier {
    @State private var tapped = false
    let callback: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !self.tapped {
                        self.tapped = true
                        self.callback()
                    }
                }
                .onEnded { _ in
                    self.tapped = false
                })
    }
}
