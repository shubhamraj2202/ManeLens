import UIKit
import StoreKit

@MainActor
@Observable
final class CreditManager {
    private(set) var credits: Int = 0
    private(set) var products: [Product] = []
    private(set) var isPurchasing = false
    private(set) var restoreError: String? = nil

    static let productIDs = ["credits_5", "credits_20", "credits_60", "credits_200"]
    private static let creditsKey   = "hairlens_credits_v1"
    private static let firstRunKey  = "hairlens_first_run_v1"
    private static let workerBase   = "https://aurax-api.auraxai.workers.dev"

    // nonisolated(unsafe) so deinit (which is nonisolated) can cancel it
    nonisolated(unsafe) private var updates: Task<Void, Never>?

    init() {
        let stored = UserDefaults.standard.integer(forKey: Self.creditsKey)
        if !UserDefaults.standard.bool(forKey: Self.firstRunKey) {
            credits = 3
            UserDefaults.standard.set(3, forKey: Self.creditsKey)
            UserDefaults.standard.set(true, forKey: Self.firstRunKey)
        } else {
            credits = stored
        }
        updates = Task { @MainActor in await self.observeTransactionUpdates() }
    }

    deinit { updates?.cancel() }

    // MARK: - Product loading

    func loadProducts() async {
        guard products.isEmpty else { return }
        products = ((try? await Product.products(for: Self.productIDs)) ?? [])
            .sorted { $0.price < $1.price }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async {
        guard !isPurchasing else { return }
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(.verified(let tx)):
                let n = creditsFor(productID: tx.productID)
                await apply(credits: n, transactionID: String(tx.id), productID: tx.productID)
                await tx.finish()
            case .success(.unverified): break
            case .pending: break
            case .userCancelled: break
            @unknown default: break
            }
        } catch {
            // purchase() threw — likely StoreKit not configured in sandbox
        }
    }

    // MARK: - Restore

    func restore() async {
        restoreError = nil
        do {
            try await AppStore.sync()
            restoreError = nil
        } catch {
            restoreError = "Restore failed. Please try again."
        }
    }

    // MARK: - Local credit ops

    func consume() {
        guard credits > 0 else { return }
        credits -= 1
        persist()
    }

    func refund() {
        credits += 1
        persist()
    }

    func resetCredits() {
        credits = 0
        persist()
    }

    func clearRestoreError() {
        restoreError = nil
    }

    // MARK: - Internals

    private func apply(credits n: Int, transactionID: String, productID: String) async {
        credits += n
        persist()
        notifyWorker(transactionID: transactionID, productID: productID)
    }

    private func persist() {
        UserDefaults.standard.set(credits, forKey: Self.creditsKey)
    }

    private func creditsFor(productID: String) -> Int {
        switch productID {
        case "credits_5":   return 5
        case "credits_20":  return 20
        case "credits_60":  return 60
        case "credits_200": return 200
        default: return 0
        }
    }

    private func notifyWorker(transactionID: String, productID: String) {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        guard !deviceId.isEmpty else { return }
        var req = URLRequest(url: URL(string: "\(Self.workerBase)/credits/purchase")!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: [
            "deviceId": deviceId,
            "productId": productID,
            "transactionId": transactionID
        ])
        Task.detached { _ = try? await URLSession.shared.data(for: req) }
    }

    private func observeTransactionUpdates() async {
        for await result in Transaction.updates {
            guard case .verified(let tx) = result else { continue }
            let n = creditsFor(productID: tx.productID)
            await apply(credits: n, transactionID: String(tx.id), productID: tx.productID)
            await tx.finish()
        }
    }
}

// MARK: - Helpers for UI

extension CreditManager {
    static func creditsLabel(for productID: String) -> Int {
        switch productID {
        case "credits_5":   return 5
        case "credits_20":  return 20
        case "credits_60":  return 60
        case "credits_200": return 200
        default: return 0
        }
    }

    static func descriptionLabel(for productID: String) -> String {
        switch productID {
        case "credits_5":   return "Try it out — no commitment"
        case "credits_20":  return "Perfect for a style refresh"
        case "credits_60":  return "Best value — most popular"
        case "credits_200": return "For serious style hunters"
        default: return ""
        }
    }

    static func badge(for productID: String) -> String? {
        productID == "credits_60" ? "BEST VALUE" : nil
    }
}
