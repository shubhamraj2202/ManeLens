import SwiftUI

struct PaywallView: View {
    @Bindable var appState: AppState
    var onClose: () -> Void

    @State private var selectedPack = 1

    private let packs: [(id: Int, credits: Int, price: String, usd: String, label: String, desc: String, badge: String?)] = [
        (0, 10,  "₹199",   "$2.99",  "Starter",  "Try a few styles",       nil),
        (1, 30,  "₹499",   "$7.99",  "Standard", "Best value — save 16%",  "BEST VALUE"),
        (2, 100, "₹1,499", "$19.99", "Pro Pack",  "For serious style hunters", nil),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
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
                    VStack(spacing: 12) {
                        ForEach(packs, id: \.id) { pack in
                            PackCard(
                                pack: pack,
                                selected: selectedPack == pack.id,
                                onTap: { selectedPack = pack.id }
                            )
                        }
                    }

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, DS.paddingPage)
            }

            // Bottom CTA
            VStack(spacing: 14) {
                PrimaryButton(
                    title: "Continue with \(packs[selectedPack].label) — \(packs[selectedPack].price)",
                    variant: .gradient
                ) {
                    let credits = packs[selectedPack].credits
                    appState.addCredits(credits)
                    onClose()
                }

                HStack(spacing: 20) {
                    Button("Restore Purchase") {}
                        .font(.system(size: 12))
                        .foregroundStyle(Color.hairTextSec)

                    Button("Privacy Policy") {}
                        .font(.system(size: 12))
                        .foregroundStyle(Color.hairTextSec)
                }
            }
            .padding(.horizontal, DS.paddingPage)
            .padding(.top, 20)
            .padding(.bottom, 44)
            .background(
                LinearGradient(colors: [.white.opacity(0), .white], startPoint: .top, endPoint: UnitPoint(x: 0.5, y: 0.2))
                    .ignoresSafeArea()
            )
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
    }
}

private struct PackCard: View {
    let pack: (id: Int, credits: Int, price: String, usd: String, label: String, desc: String, badge: String?)
    let selected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(pack.label) · \(pack.credits) credits")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.hairText)
                        Text(pack.desc)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.hairTextSec)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(pack.price)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(selected ? Color.hairPurple : Color.hairText)
                        Text(pack.usd)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.hairTextSec)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(selected ? Color.hairPurpleAlpha : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.radiusCard)
                        .stroke(selected ? Color.hairPurple : Color.black.opacity(0.08), lineWidth: selected ? 2 : 1)
                )

                // Badge
                if let badge = pack.badge {
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
}
