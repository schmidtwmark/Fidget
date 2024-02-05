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


func getDescription(inJune: Bool) -> String {
    print("inJune: \(inJune)")
    if inJune {
       return "Fidgets Premium includes:\n - App theming\n - For the month of June, proceeds go to The Trevor Project to support LGBT youth"
    } else {
       return "Fidgets Premium includes:\n - App theming\n - Any future updates\n - Supporting an independent developer"
    }
}

func dateInJune() -> Bool {
    let now = Date()
    let calendar = Calendar.current
    let components = calendar.dateComponents([.month], from: now)
    print("components: \(components)")
    if let month = components.month {
        return month == 6
    }
    return false
 
    
}

struct ColorPickerView : View {
    
    @State var selection : MSTheme
    @EnvironmentObject var settings : AppSettings
    let cornerRadius = 8.0
    
    func getViewFor(theme: MSTheme) -> some View{
        return theme.getBackground().mask(Text(theme.key)).tag(theme)
    }
    var body : some View {
        VStack {
            settings.theme.getBackground().mask(Text("App Color Theme"))
            ZStack {
                Picker("App Color Theme", selection: $selection) {
                    Group {
                        ForEach(SOLIDS, id: \.key) {
                            getViewFor(theme: $0)
                        }
                    }
                    Group {
                        ForEach(GRADIENTS, id: \.key) {
                            getViewFor(theme: $0)
                        }
                    }
                }.labelsHidden()
                RoundedRectangle(cornerSize: CGSize(width: 2.0, height: 2.0))
                    .strokeBorder(.black, lineWidth: 6) // Hide the edges with a wide black border
                settings.theme.getBackground().mask(RoundedRectangle(cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
                    .strokeBorder(Color.white, lineWidth: 2)) // Color the border as I like it
            }
            Button("Confirm", action: {
                print("Saving color")
                settings.theme = selection
            })
        }
    }
    
}

struct PurchaseView : View {
    @EnvironmentObject var settings : AppSettings
    @EnvironmentObject var store: Store
    @State var errorTitle = ""
    @State var isShowingError: Bool = false
    @State var isPurchasing: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("Fidgets Premium").foregroundColor(Color.purple)
                Text(getDescription(inJune: dateInJune())).font(.system(size: 12.0))
                isPurchasing ? AnyView(ProgressView()) : AnyView(Button("Buy $0.99", action : {
                    Task {
                        isPurchasing = true
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
                        isPurchasing = false
                    }
                }).buttonStyle(BorderedButtonStyle(tint: .green)))
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
            ColorPickerView(selection: settings.theme)
        } else {
            PurchaseView()
        }
    }
}
