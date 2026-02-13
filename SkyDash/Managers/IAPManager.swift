import StoreKit

/// In-App Purchase Manager using StoreKit 2 (async/await API).
/// Products must be configured in App Store Connect before they'll work in production.
/// For testing, use a StoreKit Configuration file in Xcode.
class IAPManager {
    static let shared = IAPManager()

    private var products: [Product] = []
    private var purchasedProductIDs: Set<String> = []
    private var updateListenerTask: Task<Void, Error>?

    private init() {
        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products
    func loadProducts() async {
        do {
            products = try await Product.products(for: IAPProducts.allProductIDs)
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase
    func purchase(productID: String, completion: @escaping (Bool) -> Void) {
        Task {
            guard let product = products.first(where: { $0.id == productID }) else {
                await MainActor.run { completion(false) }
                return
            }

            do {
                let result = try await product.purchase()

                switch result {
                case .success(let verification):
                    let transaction = try checkVerified(verification)
                    await handlePurchase(productID: transaction.productID)
                    await transaction.finish()
                    await MainActor.run { completion(true) }

                case .userCancelled:
                    await MainActor.run { completion(false) }

                case .pending:
                    await MainActor.run { completion(false) }

                @unknown default:
                    await MainActor.run { completion(false) }
                }
            } catch {
                print("Purchase failed: \(error)")
                await MainActor.run { completion(false) }
            }
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() {
        Task {
            for await result in Transaction.currentEntitlements {
                if let transaction = try? checkVerified(result) {
                    await handlePurchase(productID: transaction.productID)
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - Handle Purchase
    private func handlePurchase(productID: String) async {
        purchasedProductIDs.insert(productID)

        await MainActor.run {
            switch productID {
            case IAPProducts.removeAds:
                AdManager.shared.adsRemoved = true

            case IAPProducts.coinPackSmall:
                ScoreManager.shared.addCoins(500)

            case IAPProducts.coinPackMedium:
                ScoreManager.shared.addCoins(1500)

            case IAPProducts.coinPackLarge:
                ScoreManager.shared.addCoins(5000)

            default:
                break
            }
        }
    }

    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? self.checkVerified(result) {
                    await self.handlePurchase(productID: transaction.productID)
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - Verification
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Helpers
    func product(for id: String) -> Product? {
        return products.first { $0.id == id }
    }

    func isPurchased(_ productID: String) -> Bool {
        return purchasedProductIDs.contains(productID)
    }
}
