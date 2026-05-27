import SwiftUI

struct FaceAnalysisView: View {
    @Bindable var appState: AppState
    var onBack: () -> Void
    var onAnalyse: () -> Void
    var onPaywall: () -> Void

    @State private var showPicker = false

    var body: some View {
        VStack(spacing: 0) {
            ScreenNav(title: "Face Analysis", onBack: onBack)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Hero explainer
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.hairPurpleAlpha)
                                .frame(width: 88, height: 88)
                            Image(systemName: "person.crop.circle.badge.magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.hairPurple)
                        }

                        Text("Find Your Perfect Style")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.hairText)

                        Text("Upload a clear selfie and we'll analyse your face shape, skin tone, and features to recommend the 5 styles that suit you best.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.hairTextSec)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Feature chips
                    HStack(spacing: 10) {
                        FaceFeatureChip(icon: "person.crop.rectangle", label: "Face Shape")
                        FaceFeatureChip(icon: "paintpalette.fill", label: "Skin Tone")
                        FaceFeatureChip(icon: "eye.fill", label: "Eye Colour")
                    }

                    // Photo zone
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Selfie")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.hairText)

                        if let photo = appState.selectedPhoto {
                            ZStack(alignment: .bottomTrailing) {
                                Image(uiImage: photo)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 240)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))

                                Button { showPicker = true } label: {
                                    Label("Change", systemImage: "arrow.triangle.2.circlepath")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(.black.opacity(0.5))
                                        .clipShape(Capsule())
                                }
                                .padding(12)
                            }
                        } else {
                            Button { showPicker = true } label: {
                                VStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.hairPurpleAlpha)
                                            .frame(width: 72, height: 72)
                                        Image(systemName: "person.crop.circle.badge.plus")
                                            .font(.system(size: 32))
                                            .foregroundStyle(Color.hairPurple)
                                    }
                                    Text("Upload a clear selfie\nfor best results")
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color.hairTextSec)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 180)
                                .background(Color.hairBgOff)
                                .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))
                                .overlay(
                                    RoundedRectangle(cornerRadius: DS.radiusCard)
                                        .stroke(Color.hairBorder, lineWidth: 1)
                                )
                            }
                        }
                    }

                    // Tips
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Best results with:")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.hairTextSec)
                        TipRow(text: "Good lighting on your face")
                        TipRow(text: "Looking directly at the camera")
                        TipRow(text: "No sunglasses or hats")
                    }
                    .padding(14)
                    .background(Color.hairBgOff)
                    .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, DS.paddingPage)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.hairBg)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                PrimaryButton(
                    title: appState.credits > 0 ? "Analyse My Face — 1 Credit" : "Get Credits to Analyse",
                    variant: .gradient,
                    disabled: appState.selectedPhoto == nil
                ) {
                    if appState.credits > 0 {
                        onAnalyse()
                    } else {
                        onPaywall()
                    }
                }

                Text("1 credit per analysis · Uses AI vision")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.hairTextSec)
            }
            .padding(.horizontal, DS.paddingPage)
            .padding(.top, 12)
            .padding(.bottom, 28)
            .background(.regularMaterial)
        }
        .sheet(isPresented: $showPicker) {
            PhotoPickerSheet(isPresented: $showPicker) { image in
                appState.selectedPhoto = image
            }
        }
    }
}

private struct FaceFeatureChip: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.hairPurple)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.hairTextSec)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.hairBgOff)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct TipRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 13))
                .foregroundStyle(Color.hairPurple)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(Color.hairTextSec)
        }
    }
}
