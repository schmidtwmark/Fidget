//
//  SettingsView.swift
//  Fidget WatchKit Extension
//
//  Created by Mark Schmidt on 7/24/21.
//

import Foundation
import SwiftUI
import Combine
import StoreKit

struct ColorPickerView : View {
    @EnvironmentObject var settings : AppSettings
    func getViewFor(color: MSColor) -> some View{
        return Text(color.key).tag(color).foregroundColor(color.rawColor)
    }
    var body : some View {
        VStack {
            Picker("App Color Theme", selection: $settings.pickerColor) {
                getViewFor(color: MSColor(rawColor: Color("Purple"), key: "Purple"))
                getViewFor(color: MSColor(rawColor: Color("Blue"), key: "Blue"))
                getViewFor(color: MSColor(rawColor: Color("Green"), key: "Green"))
                getViewFor(color: MSColor(rawColor: Color("Mint"), key: "Mint"))
                getViewFor(color: MSColor(rawColor: Color("Orange"), key: "Orange"))
                getViewFor(color: MSColor(rawColor: Color("Pink"), key: "Pink"))
                getViewFor(color: MSColor(rawColor: Color("Red"), key: "Red"))
                getViewFor(color: MSColor(rawColor: Color("White"), key: "White"))
                getViewFor(color: MSColor(rawColor: Color("Yellow"), key: "Yellow"))
            }
            Button("Confirm", action: {
                print("Saving color")
                settings.color = settings.pickerColor
                
            })
        }
    }
    
}

struct PurchaseView : View {
    @EnvironmentObject var settings : AppSettings
    @EnvironmentObject var store: Store
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("Fidget Premium").foregroundColor(Color.purple)
                Text("Fidget Premium includes:\n - App theming\n - Any future updates\n - Supporting an independent developer").font(.system(size: 12.0))
                ForEach(store.products, id: \.id) {
                    product in
                    Button("Buy $0.99", action : {
                        Task {
                            do {
                                if try await store.purchase(product) != nil {
                                    print("Successful payment")
                                    settings.paid = true
                                }
                            } catch StoreError.failedVerification {
                                print("Failed verification")
                                errorTitle = "Your purchase could not be verified by the App Store."
                                isShowingError = true
                            } catch {
                                print("Failed purchase for \(product.id): \(error)")
                            }
                                
                        }
                    }).buttonStyle(BorderedButtonStyle(tint: .green))
                    
                }
                Button("Restore Purchases", action: {
                    Task {
                        //This call displays a system prompt that asks users to authenticate with their App Store credentials.
                        //Call this function only in response to an explicit user action, such as tapping a button.
                        try? await AppStore.sync()
                        settings.paid = await store.checkIsPurchased(premiumId)
                    }
                })
            }
        }
        .alert(isPresented: $isShowingError, content: {
            Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("Okay")))
        })
    }
    
}

struct SettingsView : View {
    @EnvironmentObject var settings : AppSettings
    @EnvironmentObject var store: Store

    var body : some View {
        if settings.paid {
            ColorPickerView()
        } else {
            PurchaseView()
        }
    }
}
