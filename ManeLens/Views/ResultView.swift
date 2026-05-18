import SwiftUI

struct ResultView: View {
    let style: HairStyle?
    @Bindable var appState: AppState
    var onBack: () -> Void
    var onTryAnother: () -> Void

    @State private var liked: Bool? = nil
    @State private var saved = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Before/After slider with real images
                    if let before = appState.selectedPhoto, let after = appState.generatedImage {
                        BeforeAfterSlider(before: before, after: after)
                            .padding(.top, 52)
                    }

                    VStack(spacing: 16) {
                        // Style chip
                        if let style {
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "scissors")
                                        .font(.system(size: 12))
                                    Text(style.name)
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundStyle(Color.hairPurple)
                                .padding(.horizontal, 14)
                                .frame(height: 32)
                                .background(Color.hairPurpleAlpha)
                                .overlay(Capsule().stroke(Color.hairPurple.opacity(0.2), lineWidth: 1))
                                .clipShape(Capsule())
                            }
                        }

                        // Action bar
                        HStack(spacing: 0) {
                            ActionButton(icon: saved ? "heart.fill" : "heart", label: "Save", active: saved) {
                                saved.toggle()
                            }
                            Divider().frame(height: 40)
                            ActionButton(icon: "arrow.down.to.line", label: "Export") {
                                exportImage()
                            }
                            Divider().frame(height: 40)
                            ActionButton(icon: "square.and.arrow.up", label: "Share") {
                                shareImage()
                            }
                            Divider().frame(height: 40)
                            ActionButton(icon: "arrow.clockwise", label: "Redo") {
                                onTryAnother()
                            }
                        }
                        .background(Color.black.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))

                        // Feedback
                        feedbackSection

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, DS.paddingPage)
                    .padding(.top, 16)
                }
            }

            // Bottom CTA
            VStack(spacing: 0) {
                PrimaryButton(title: "Try Another Style", icon: "scissors", variant: .primary, action: onTryAnother)
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
        .overlay(alignment: .top) {
            ScreenNav(
                title: "Your Preview",
                onBack: onBack,
                trailing: AnyView(
                    Button(action: shareImage) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.hairText)
                    }
                )
            )
            .background(.ultraThinMaterial)
        }
    }

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How does it look?")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.hairText)

            HStack(spacing: 10) {
                FeedbackButton(icon: "👍", label: "Love it", selected: liked == true) { liked = true }
                FeedbackButton(icon: "👎", label: "Not quite", selected: liked == false) { liked = false }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.hairPurpleLight)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func shareImage() {
        guard let image = appState.generatedImage else { return }
        let av = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController?
            .present(av, animated: true)
    }

    private func exportImage() {
        guard let image = appState.generatedImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

private struct ActionButton: View {
    let icon: String
    let label: String
    var active: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(active ? Color.hairPurple : Color.hairText)
                Text(label)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.hairTextSec)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(active ? Color.hairPurpleAlpha : Color.clear)
        }
    }
}

private struct FeedbackButton: View {
    let icon: String
    let label: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(icon).font(.system(size: 18))
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(selected ? Color.hairPurple : Color.hairText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(selected ? Color.hairPurpleAlpha : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selected ? Color.hairPurple : Color.black.opacity(0.08), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
