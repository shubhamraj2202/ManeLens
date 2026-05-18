import SwiftUI

struct StyleDetailView: View {
    let style: HairStyle
    @Bindable var appState: AppState
    var onBack: () -> Void
    var onGenerate: () -> Void
    var onCustom: () -> Void

    @State private var isFavorited = false
    @State private var tipsExpanded = false
    @State private var showPicker = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero image — sharp top, rounded bottom corners
                    StyleHeroView(style: style)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(16/9, contentMode: .fit)
                        .clipShape(
                            UnevenRoundedRectangle(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 20,
                                bottomTrailingRadius: 20,
                                topTrailingRadius: 0,
                                style: .continuous
                            )
                        )

                    VStack(alignment: .leading, spacing: 16) {
                        // Description
                        Text(style.description)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.hairTextSec)
                            .lineSpacing(4)
                            .lineLimit(3)

                        // Photo upload
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your Photo")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.hairText)

                            PhotoUploadZone(
                                photo: appState.selectedPhoto,
                                hairColor: style.hairColor,
                                onTap: { showPicker = true },
                                onRemove: { appState.selectedPhoto = nil }
                            )
                        }

                        // Tips
                        tipsSection

                        // Spacer for bottom gradient
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, DS.paddingPage)
                    .padding(.top, 16)
                }
            }
            .ignoresSafeArea(edges: .top)

            // Bottom CTA
            bottomCTA
        }
        .background(Color.hairBg)
        .navigationBarHidden(true)
        .overlay(alignment: .top) {
            navBar
        }
        .sheet(isPresented: $showPicker) {
            PhotoPickerSheet(isPresented: $showPicker) { image in
                appState.selectedPhoto = image
            }
        }
    }

    private var navBar: some View {
        ScreenNav(
            title: style.name,
            onBack: onBack,
            trailing: AnyView(
                Button(action: { isFavorited.toggle() }) {
                    Image(systemName: isFavorited ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundStyle(isFavorited ? Color.hairPink : Color.hairText)
                }
            )
        )
        .background(.ultraThinMaterial)
    }

    private var tipsSection: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { tipsExpanded.toggle() } }) {
                HStack {
                    Label("Photo Tips", systemImage: "camera")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.hairPurple)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.hairPurple)
                        .rotationEffect(.degrees(tipsExpanded ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }

            if tipsExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(["Front-facing", "Clear lighting", "No sunglasses or hat", "Neutral expression"], id: \.self) { tip in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.green)
                            Text(tip)
                                .font(.system(size: 13))
                                .foregroundStyle(Color.hairPurple)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(Color.hairPurpleLight)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var bottomCTA: some View {
        VStack(spacing: 6) {
            PrimaryButton(
                title: "Generate Preview",
                icon: "✨",
                variant: .primary,
                disabled: !appState.hasPhoto,
                action: onGenerate
            )

            Text(appState.hasPhoto
                 ? "Uses 1 credit · You have \(appState.credits) remaining"
                 : "Upload a photo to continue")
                .font(.system(size: 12))
                .foregroundStyle(Color.hairTextSec)

            Button(action: onCustom) {
                Text("Try a Custom Style Instead")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.hairPurple)
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, DS.paddingPage)
        .padding(.top, 20)
        .padding(.bottom, 44)
        .background(
            LinearGradient(
                colors: [.white.opacity(0), .white],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.2)
            )
            .ignoresSafeArea()
        )
    }
}
