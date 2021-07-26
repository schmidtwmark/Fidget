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

    init() {
        let color = loadColor()
        self.color = color
        self.pickerColor = color
        print("Done init")
    }

}

struct MSColor : Hashable{
    var rawColor: Color
    var key: String

    static func == (lhs: MSColor, rhs: MSColor) -> Bool {
        let ret = lhs.rawColor == rhs.rawColor && lhs.key == rhs.key
        print("Comparing \(lhs.key) and \(rhs.key), matches: \(ret)")
        return ret
    }

    func hash(into hasher: inout Hasher) {
        
        hasher.combine(key)
//        hasher.combine(rawColor)
        print("Hashing \(key), value is \(hasher.finalize())")
//        print("Got value \(hasher)
    }
}

let COLOR_KEY = "color"
let PAID_KEY = "paid"

func save(color: MSColor) {
    print("Saving \(color.key)")
    UserDefaults.standard.set(color.key, forKey: COLOR_KEY)
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
