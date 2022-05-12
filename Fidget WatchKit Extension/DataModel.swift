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
    var theme: MSTheme {
        didSet {
            save(theme: theme)
        }
    }
    
    @Published
    var paid : Bool {
        didSet {
            save(paid: paid)
        }
    }
    
    init() {
        let theme = loadTheme()
        self.theme = theme
        self.paid = loadPaid()
        print("Done init with theme \(self.theme.key), colors: \(self.theme.colors)")
    }
    
}


let DEFAULT_SIZE = CGSize(width: 400, height: 400)
struct MSTheme : Hashable{
    var colors: [Color] = [Color.purple]
    var key: String = "Purple"
    
    func getBackground(frame: CGSize = DEFAULT_SIZE) -> some View{
        //        let MAX_C_2 = pow(DEFAULT_SIZE.width, 2) + pow(DEFAULT_SIZE.height, 2)
        //        let c_2 = pow(frame.width, 2) + pow(frame.height, 2)
        //
        //        let pct = min(c_2 / MAX_C_2, 1.0)
        //
        //        let count : CGFloat = CGFloat(colors.count)
        //
        //        let included_colors = (count * pct).rounded(.up)
        //
        //        let offset = (count - included_colors) / 2.0
        //
        //        let start : Int = Int(offset)
        //        let end : Int = min(colors.count - Int(offset), colors.count - 1)
        //
        //        let hues : [Color]  = Array(colors[start...end])
        return LinearGradient(colors: colors, startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
        //        return LinearGradient(colors: colors, startPoint: .bottomLeading, endPoint: .topTrailing)
    }
    func getBackground(frame: Frame) -> some View {
        return getBackground(frame: CGSize(width: frame.width, height: frame.height))
    }
}

let CLEAR_BACKGROUND = LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
let BLACK_BACKGROUND = LinearGradient(colors: [Color.black], startPoint: .leading, endPoint: .trailing)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
let GRADIENTS = [
    
    MSTheme(colors: [
        Color(hex: "D12229"),
        Color(hex: "F68A1E"),
        Color(hex: "FDE01A"),
        Color(hex: "007940"),
        Color(hex: "24408E"),
        Color(hex: "732982")
    ], key: "Pride"),
    MSTheme(colors: [
        Color(hex: "D60270"),
        Color(hex: "D60270"),
        Color(hex: "9B4F96"),
        Color(hex: "0038A8"),
        Color(hex: "0038A8")
    ], key: "Bi Pride"),
    MSTheme(colors: [
        Color(hex: "5BCEFA"),
        Color(hex: "5BCEFA"),
        Color(hex: "F5A9B8"),
        Color(hex: "FFFFFF"),
        Color(hex: "F5A9B8"),
        Color(hex: "5BCEFA"),
        Color(hex: "5BCEFA")
    ], key: "Trans Pride"),
    MSTheme(colors: [
        Color(hex: "F76E11"),
        Color(hex: "FF9F45"),
        Color(hex: "FFBC80"),
        Color(hex: "FC4F4F")
    ], key: "Fire"),
    MSTheme(colors: [
        Color(hex: "5F7161"),
        Color(hex: "6D8B74"),
        Color(hex: "EFEAD8"),
        Color(hex: "D0C9C0")
    ], key: "Earth"),
    MSTheme(colors: [
        Color(hex: "001D6E"),
        Color(hex: "22577E"),
        Color(hex: "5584AC"),
    ], key: "Water"),
    MSTheme(colors: [
        Color(hex: "F4E7EC"),
        Color(hex: "C0EDFF"),
        Color(hex: "FFFBFB"),
    ], key: "Air")]


let GRADIENT_MAP = GRADIENTS.reduce(into: [String: MSTheme]()) {
    $0[$1.key] = $1
}

let SOLIDS = [MSTheme(colors: [Color("Purple")], key: "Purple"),
              MSTheme(colors: [Color("Blue")], key: "Blue"),
              MSTheme(colors: [Color("Green")], key: "Green"),
              MSTheme(colors: [Color("Mint")], key: "Mint"),
              MSTheme(colors: [Color("Orange")], key: "Orange"),
              MSTheme(colors: [Color("Pink")], key: "Pink"),
              MSTheme(colors: [Color("Red")], key: "Red"),
              MSTheme(colors: [Color("White")], key: "White"),
              MSTheme(colors: [Color("Yellow")], key: "Yellow")]
let SOLID_MAP = SOLIDS.reduce(into: [String: MSTheme]()) {
    $0[$1.key] = $1
}

let COLOR_KEY = "color"
let PAID_KEY = "paid"

func save(theme: MSTheme) {
    print("Saving theme \(theme.key)")
    UserDefaults.standard.set(theme.key, forKey: COLOR_KEY)
}

func save(paid: Bool) {
    print("Saving \(paid)")
    UserDefaults.standard.set(paid, forKey: PAID_KEY)
}

func loadTheme() -> MSTheme  {
    if !loadPaid() {
        print("Has not paid or failed to auth, returning purple")
        return MSTheme()
    }
    if let savedColorString = UserDefaults.standard.string(forKey: COLOR_KEY) {
        print("Loaded \(savedColorString)")
        if let gradient = GRADIENT_MAP[savedColorString] {
            print("Loading from gradient map")
            return gradient;
        } else if let solid = SOLID_MAP[savedColorString] {
            // It's a specific color, or maybe a failure
            print("Loading from solid map")
            return solid;
        } else {
            print("Not found in solid or gradients, returning default")
            return MSTheme()
        }
    } else {
        print("Attempted to load and failed, returning purple")
        return MSTheme()
    }
}

func loadPaid() -> Bool{
    return UserDefaults.standard.bool(forKey: PAID_KEY)
}
