import SwiftUI
import Photos
import StoreKit

struct ResultView: View {
    let style: HairStyle?
    @Bindable var appState: AppState
    var onBack: () -> Void
    var onTryAnother: () -> Void

    @State private var liked: Bool? = nil
    @State private var saved = false
    @State private var saveMessage: String? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Before/After slider with real images
                    if let before = appState.selectedPhoto, let after = appState.generatedImage {
                        BeforeAfterSlider(before: before, after: after)
                            .padding(.top, 56)
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
                            ActionButton(icon: saved ? "checkmark.circle.fill" : "square.and.arrow.down", label: saved ? "Saved" : "Save", active: saved) {
                                if !saved { saveImage(); saved = true }
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
                PrimaryButton(title: "Try Another Style", icon: "✂️", variant: .primary, action: onTryAnother)
            }
            .padding(.horizontal, DS.paddingPage)
            .padding(.top, 20)
            .padding(.bottom, 44)
            .background(
                LinearGradient(colors: [Color.hairBg.opacity(0), Color.hairBg], startPoint: .top, endPoint: UnitPoint(x: 0.5, y: 0.2))
                    .ignoresSafeArea()
            )
        }
        .background(Color.hairBg)
        .navigationBarHidden(true)
        .overlay(alignment: .bottom) {
            if let msg = saveMessage {
                Text(msg)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.75))
                    .clipShape(Capsule())
                    .padding(.bottom, 120)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation { saveMessage = nil }
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: saveMessage)
        .overlay(alignment: .top) {
            ScreenNav(title: "Your Preview", onBack: onBack)
                .background(.ultraThinMaterial)
        }
    }

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How does it look?")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.hairText)

            HStack(spacing: 10) {
                FeedbackButton(icon: "👍", label: "Love it", selected: liked == true) {
                    liked = true
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        AppStore.requestReview(in: scene)
                    }
                }
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

    private func saveImage() {
        guard let image = appState.generatedImage else { return }
        Task {
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            await MainActor.run {
                switch status {
                case .authorized, .limited:
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    saveMessage = "Saved to Photos"
                default:
                    saveMessage = "Allow Photos access in Settings to save images"
                }
            }
        }
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
            .background(selected ? Color.hairPurpleAlpha : Color.hairBg)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selected ? Color.hairPurple : Color.black.opacity(0.08), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
