/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The Store is responsible for requesting products from the App Store and starting purchases; other parts of
    the app query the store to learn what products have been purchased.
*/

import Foundation
import StoreKit

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public enum StoreError: Error {
    case failedVerification
}

let premiumId = "consumable.premium"

class Store: ObservableObject {

    @Published private(set) var products: [Product]
    @Published private(set) var purchasedIdentifiers = Set<String>()

    var updateListenerTask: Task<Void, Error>? = nil
    private let productIds = [premiumId]

    init() {
        print("Initializing Store")
        //Initialize empty products then do a product request asynchronously to fill them in.
        products = []

        //Start a transaction listener as close to app launch as possible so you don't miss any transactions.
        updateListenerTask = listenForTransactions()

        Task {
            //Initialize the store by starting a product request.
            await requestProducts()
        }
    }

    deinit {
        print("Deinitializing Store")
        updateListenerTask?.cancel()
    }

    func listenForTransactions() -> Task<Void, Error> {
        print("Called listenForTransactions")
        return Task.detached {
            print("Running listenForTransactionsTask")
            //Iterate through any transactions which didn't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                print("Examining result \(result)")
                do {
                    let transaction = try self.checkVerified(result)

                    //Deliver content to the user.
                    await self.updatePurchasedIdentifiers(transaction)

                    //Always finish a transaction.
                    await transaction.finish()
                } catch {
                    //StoreKit has a receipt it can read but it failed verification. Don't deliver content to the user.
                    print("Transaction failed verification")
                }
            }
        }
    }

    @MainActor
    func requestProducts() async {
        do {
            //Request products from the App Store using the identifiers defined in the Products.plist file.
            let storeProducts = try await Product.products(for: productIds)

            //Filter the products into different categories based on their type.
            for product in storeProducts {
                products.append(product)
            }

        } catch {
            print("Failed product request: \(error)")
        }
    }

    func purchase(_ product: Product) async throws -> Transaction? {
        //Begin a purchase.
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            //Deliver content to the user.
            await updatePurchasedIdentifiers(transaction)

            //Always finish a transaction.
            await transaction.finish()

            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }

    func isPurchased(_ productIdentifier: String) async throws -> Bool {
        //Get the most recent transaction receipt for this `productIdentifier`.
        guard let result = await Transaction.latest(for: productIdentifier) else {
            //If there is no latest transaction, the product has not been purchased.
            print("No latest transaction for identifier")
            return false
        }

        let transaction = try checkVerified(result)

        //Ignore revoked transactions, they're no longer purchased.

        //For subscriptions, a user can upgrade in the middle of their subscription period. The lower service
        //tier will then have the `isUpgraded` flag set and there will be a new transaction for the higher service
        //tier. Ignore the lower service tier transactions which have been upgraded.
        return transaction.revocationDate == nil && !transaction.isUpgraded
    }
    
 

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check if the transaction passes StoreKit verification.
        switch result {
        case .unverified(_, let error):
            //StoreKit has parsed the JWS but failed verification. Don't deliver content to the user.
//            if error == VerificationResult.VerificationError.missingRequiredProperties {
//                print("Missing required properties but allowing anyways. Maybe this is a testing thing")
//                return safe
//            }
            print("Unverified result: \(error)")
            throw StoreError.failedVerification
        case .verified(let safe):
            //If the transaction is verified, unwrap and return it.
            return safe
        }
    }

    @MainActor
    func updatePurchasedIdentifiers(_ transaction: Transaction) async {
        if transaction.revocationDate == nil {
            //If the App Store has not revoked the transaction, add it to the list of `purchasedIdentifiers`.
            purchasedIdentifiers.insert(transaction.productID)
        } else {
            //If the App Store has revoked this transaction, remove it from the list of `purchasedIdentifiers`.
            purchasedIdentifiers.remove(transaction.productID)
        }
        print("Updated purchased identifiers: \(purchasedIdentifiers)")
    }

}
