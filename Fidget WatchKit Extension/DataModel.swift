//
//  DataModel.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 7/25/21.
//

import Foundation
import SwiftUI
import Combine 

class AppSettings : ObservableObject {
    @Published
    var color: MSColor {
        didSet {
            save(color: color)
        }
    }

    @Published
    var pickerColor: MSColor {
        didSet {
            print("Set picker color to \(pickerColor.key)")
        }
    }
    
    @Published
    var paid : Bool {
        didSet {
            save(paid: paid)
        }
    }

    init() {
        let color = loadColor()
        self.color = color
        self.pickerColor = color
        self.paid = loadPaid()
        print("Done init")
    }

}

struct MSColor : Hashable{
    var rawColor: Color
    var key: String
}

let COLOR_KEY = "color"
let PAID_KEY = "paid"

func save(color: MSColor) {
    print("Saving \(color.key)")
    UserDefaults.standard.set(color.key, forKey: COLOR_KEY)
}

func save(paid: Bool) {
    print("Saving \(paid)")
    UserDefaults.standard.set(paid, forKey: PAID_KEY)
}

func loadColor() -> MSColor  {
    if let savedColorString = UserDefaults.standard.string(forKey: COLOR_KEY) {
        print("Loaded \(savedColorString)")
        let color = MSColor(rawColor: Color(savedColorString), key: savedColorString)
        if color.rawColor == Color.clear {
            print("Returning default")
            return MSColor(rawColor: Color.purple, key: "Purple")
        }
        return color
    } else {
        print("Attempted to load and failed, returning purple")
        return MSColor(rawColor: Color.purple, key: "Purple")
    }
}

func loadPaid() -> Bool{
    return UserDefaults.standard.bool(forKey: PAID_KEY)
}
