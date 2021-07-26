//
//  ButtonView.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 7/24/21.
//

import SwiftUI
import Combine

struct HapticButtonStyle: ButtonStyle {
  @EnvironmentObject var settings : AppSettings

  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .padding()
      .foregroundColor(settings.color.rawColor)
      .background(configuration.isPressed ? settings.color.rawColor: Color.clear)
      .animation(nil)
      .cornerRadius(8.0)
  }
}

struct ButtonView: View {

    @EnvironmentObject var settings : AppSettings
    
    var hapticCallback: (Double) -> Void

    init(frame: CGSize, hapticCallback: @escaping (Double) -> Void) {
        self.hapticCallback = hapticCallback
    }

    @State
    var pressed : Bool = false;

    var body: some View {
        Button("Press", action: {hapticCallback(0)})
            .buttonStyle(HapticButtonStyle())
            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(settings.color.rawColor))
    }
}
