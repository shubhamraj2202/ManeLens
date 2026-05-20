import SwiftUI
import StoreKit

struct PaywallView: View {
    @Bindable var appState: AppState
    var onClose: () -> Void

    @State private var selectedProduct: Product? = nil
    @State private var isLoading = false

    private var creditManager: CreditManager { appState.creditManager }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Hero
                VStack(spacing: 12) {
                    Text("✨")
                        .font(.system(size: 52))

                    Text("Out of Credits")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.hairText)

                    Text("Get more previews to find your perfect look")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.hairTextSec)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // Pack cards
                if creditManager.products.isEmpty {
                    ProgressView()
                        .padding(.vertical, 40)
                } else {
                    VStack(spacing: 12) {
                        ForEach(creditManager.products, id: \.id) { product in
                            PackCard(
                                product: product,
                                selected: selectedProduct?.id == product.id,
                                onTap: { selectedProduct = product }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, DS.paddingPage)
            .padding(.bottom, 24)
        }
        .background(Color.hairBg)
        .navigationBarHidden(true)
        .overlay(alignment: .topTrailing) {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.hairText)
                    .frame(width: 32, height: 32)
                    .background(Color.black.opacity(0.07))
                    .clipShape(Circle())
            }
            .padding(.top, 16)
            .padding(.trailing, DS.paddingPage)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 14) {
                PrimaryButton(
                    title: ctaTitle,
                    variant: .gradient
                ) {
                    guard let product = selectedProduct, !creditManager.isPurchasing else { return }
                    isLoading = true
                    Task {
                        await creditManager.purchase(product)
                        isLoading = false
                        onClose()
                    }
                }
                .opacity(selectedProduct == nil || creditManager.isPurchasing ? 0.6 : 1)

                HStack(spacing: 20) {
                    Button {
                        Task { await creditManager.restore() }
                    } label: {
                        Text("Restore Purchase")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.hairTextSec)
                    }

                    Button("Privacy Policy") {}
                        .font(.system(size: 12))
                        .foregroundStyle(Color.hairTextSec)
                }
            }
            .padding(.horizontal, DS.paddingPage)
            .padding(.top, 16)
            .padding(.bottom, 44)
            .background(
                LinearGradient(colors: [.white.opacity(0), .white], startPoint: .top, endPoint: UnitPoint(x: 0.5, y: 0.3))
                    .ignoresSafeArea()
            )
        }
        .task {
            await creditManager.loadProducts()
            if selectedProduct == nil {
                selectedProduct = creditManager.products.first(where: { $0.id == "credits_60" })
                             ?? creditManager.products.first
            }
        }
    }

    private var ctaTitle: String {
        guard let product = selectedProduct else { return "Select a pack" }
        let credits = CreditManager.creditsLabel(for: product.id)
        return "Continue · \(credits) credits — \(product.displayPrice)"
    }
}

private struct PackCard: View {
    let product: Product
    let selected: Bool
    let onTap: () -> Void

    private var credits: Int   { CreditManager.creditsLabel(for: product.id) }
    private var desc: String   { CreditManager.descriptionLabel(for: product.id) }
    private var badge: String? { CreditManager.badge(for: product.id) }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(product.displayName.isEmpty ? packName : product.displayName) · \(credits) credits")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.hairText)
                        Text(desc)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.hairTextSec)
                    }

                    Spacer()

                    Text(product.displayPrice)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(selected ? Color.hairPurple : Color.hairText)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(selected ? Color.hairPurpleAlpha : Color.hairBg)
                .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.radiusCard)
                        .stroke(selected ? Color.hairPurple : Color.black.opacity(0.08), lineWidth: selected ? 2 : 1)
                )

                if let badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .kerning(0.5)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(LinearGradient.hairBrand)
                        .clipShape(Capsule())
                        .offset(x: -10, y: -10)
                }
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: selected)
    }

    private var packName: String {
        switch product.id {
        case "credits_5":   return "Try It"
        case "credits_20":  return "Starter"
        case "credits_60":  return "Standard"
        case "credits_200": return "Pro Pack"
        default: return product.id
        }
    }
}
