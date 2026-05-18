import UIKit
import StoreKit

@MainActor
@Observable
final class CreditManager {
    private(set) var credits: Int = 0
    private(set) var products: [Product] = []
    private(set) var isPurchasing = false
    private(set) var restoreError: String? = nil

    static let productIDs = ["credits_10", "credits_30", "credits_100"]
    private static let creditsKey   = "hairlens_credits_v1"
    private static let firstRunKey  = "hairlens_first_run_v1"
    private static let workerBase   = "https://aurax-api.auraxai.workers.dev"

    private var updates: Task<Void, Never>?

    init() {
        let stored = UserDefaults.standard.integer(forKey: Self.creditsKey)
        if !UserDefaults.standard.bool(forKey: Self.firstRunKey) {
            credits = 3
            UserDefaults.standard.set(3, forKey: Self.creditsKey)
            UserDefaults.standard.set(true, forKey: Self.firstRunKey)
        } else {
            credits = stored
        }
        updates = Task { await self.observeTransactionUpdates() }
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
                await apply(credits: n, jws: tx.jwsRepresentation)
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

    // MARK: - Restore (subscriptions / non-consumables only; consumables are re-purchased)

    func restore() async {
        restoreError = nil
        do {
            try await AppStore.sync()
            restoreError = nil
        } catch {
            restoreError = "Restore failed. Please try again."
        }
    }

    // MARK: - Local credit ops (called by AppState)

    func consume() {
        guard credits > 0 else { return }
        credits -= 1
        persist()
    }

    func refund() {
        credits += 1
        persist()
    }

    // MARK: - Internals

    private func apply(credits n: Int, jws: String) async {
        credits += n
        persist()
        notifyWorker(jws: jws)
    }

    private func persist() {
        UserDefaults.standard.set(credits, forKey: Self.creditsKey)
    }

    private func creditsFor(productID: String) -> Int {
        switch productID {
        case "credits_10":  return 10
        case "credits_30":  return 30
        case "credits_100": return 100
        default: return 0
        }
    }

    private func notifyWorker(jws: String) {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        guard !deviceId.isEmpty else { return }
        var req = URLRequest(url: URL(string: "\(Self.workerBase)/credits/purchase")!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: ["jwsToken": jws, "deviceId": deviceId])
        Task.detached { _ = try? await URLSession.shared.data(for: req) }
    }

    private func observeTransactionUpdates() async {
        for await result in Transaction.updates {
            guard case .verified(let tx) = result else { continue }
            let n = creditsFor(productID: tx.productID)
            await apply(credits: n, jws: tx.jwsRepresentation)
            await tx.finish()
        }
    }
}

// MARK: - Helpers for UI

extension CreditManager {
    static func creditsLabel(for productID: String) -> Int {
        switch productID {
        case "credits_10":  return 10
        case "credits_30":  return 30
        case "credits_100": return 100
        default: return 0
        }
    }

    static func descriptionLabel(for productID: String) -> String {
        switch productID {
        case "credits_10":  return "Try a few styles"
        case "credits_30":  return "Best value — save 16%"
        case "credits_100": return "For serious style hunters"
        default: return ""
        }
    }

    static func badge(for productID: String) -> String? {
        productID == "credits_30" ? "BEST VALUE" : nil
    }
}
