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
    
    @State var selection : MSColor
    @EnvironmentObject var settings : AppSettings
    
    func getViewFor(color: MSColor) -> some View{
        return Text(color.key).tag(color).foregroundColor(color.rawColor)
    }
    var body : some View {
        VStack {
            Picker("App Color Theme", selection: $selection) {
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
                settings.color = selection
                
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
                Text("Fidgets Premium").foregroundColor(Color.purple)
                Text("Fidgets Premium includes:\n - App theming\n - Any future updates\n - Supporting an independent developer").font(.system(size: 12.0))
                Button("Buy $0.99", action : {
                    Task {
                        do {
                            if try await store.purchasePremium() != nil {
                                print("Successful payment")
                                settings.paid = true
                            }
                        } catch StoreError.failedVerification {
                            print("Failed verification")
                            errorTitle = "Your purchase could not be verified by the App Store."
                            isShowingError = true
                        } catch StoreError.missingProduct {
                            print("Failed purchase")
                            errorTitle = "Your purchase could not be completed."
                            isShowingError = true
                        } catch {
                            print("Failed purchase for \(premiumId): \(error)")
                        }
                            
                    }
                }).buttonStyle(BorderedButtonStyle(tint: .green))
                Button("Restore Purchases", action: {
                    Task {
                        //This call displays a system prompt that asks users to authenticate with their App Store credentials.
                        //Call this function only in response to an explicit user action, such as tapping a button.
                        try? await AppStore.sync()
                    }
                })
            }
        }
        .alert(isPresented: $isShowingError, content: {
            Alert(title: Text(errorTitle), message: nil, dismissButton: .default(Text("Okay")))
        })
        .onAppear {
            Task {
                //When this view appears, get all the purchased products to display.
                print("Checking is purchased")
                settings.paid = await checkIsPurchased(premiumId)
                print("Done checking is purchased")
            }
        }
    }
    
    @MainActor
    fileprivate func checkIsPurchased(_ productIdentifier: String) async -> Bool {
        for await result in Transaction.currentEntitlements{
            print("Checking current entitlements \(result)")
            if let transaction = try? store.checkVerified(result) {
                if transaction.productID == productIdentifier {
                    return true
                }
            }
        }
        return false
        
    }
}

struct SettingsView : View {
    @EnvironmentObject var settings : AppSettings
    @EnvironmentObject var store: Store

    var body : some View {
        if settings.paid {
            ColorPickerView(selection: settings.color)
        } else {
            PurchaseView()
        }
    }
}
