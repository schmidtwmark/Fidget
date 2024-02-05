//
//  ReorderView.swift
//  Fidget WatchKit App
//
//  Created by Mark Schmidt on 2/5/24.
//

import Foundation
import SwiftUI

enum FidgetViewType : Int, Identifiable {
    var id: Self {
        return self
    }
    case crown = 0, accelerometer = 1, joystick = 2, lightswitch = 3, button = 4, breathe = 5
    
    func getName() -> String {
        switch self {
        case .crown:
            return "Spinner"
        case .accelerometer:
            return "Bouncing Ball"
        case .joystick: return "Joystick"
        case .lightswitch: return "Switch"
        case .button: return "Button"
        case .breathe: return "Square Breathing"
        }
    }
}

let defaultOrder : [FidgetViewType] = [.crown, .accelerometer, .joystick, .lightswitch, .button, .breathe]

func orderToString(_ order: [FidgetViewType]) -> String {
    return order.map({type in "\(type.rawValue)" }).joined(separator: ",")
}

func stringToOrder(_ string: String) -> [FidgetViewType] {
    string.split(separator: ",").map({ rawValue in FidgetViewType(rawValue: Int(rawValue)!)!})
}

struct ReorderView : View {
   
    @AppStorage("order") var orderString = orderToString(defaultOrder)
    
    var body: some View {
        NavigationView {
            List{
                Section {
                    ForEach(stringToOrder(orderString)) { viewType in
                        Text("\(viewType.getName())")
                    }
                    .onMove { from, to in
                        var order = stringToOrder(orderString)
                        order.move(fromOffsets: from, toOffset: to)
                        print("Updating order: \(order)")
                        orderString = orderToString(order)
                    }
                } header: {
                    Text("Reorder Widgets")
                }
            }
        }
    }
}


 struct ContentView_Previews: PreviewProvider {
     static var previews: some View {
         ReorderView()
     }
 }
