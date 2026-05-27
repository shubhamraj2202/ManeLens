import SwiftUI

struct StyleDetailView: View {
    let style: HairStyle
    @Bindable var appState: AppState
    var onBack: () -> Void
    var onGenerate: () -> Void
    var onCustom: () -> Void

    @State private var tipsExpanded = false
    @State private var showPicker = false
    @State private var carouselPage = 0
    @State private var showSampleFullscreen = false
    @State private var showPhotoPreview = false

    private var sampleUIImages: [UIImage] {
        style.sampleImages.compactMap { StyleImageLoader.load($0) }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                navBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero area — carousel when images available, illustration otherwise
                        heroArea
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))
                            .padding(.horizontal, DS.paddingPage)
                            .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 16) {
                            Text(style.description)
                                .font(.system(size: 15))
                                .foregroundStyle(Color.hairTextSec)
                                .lineSpacing(4)
                                .lineLimit(3)

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Your Photo")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.hairText)

                                PhotoUploadZone(
                                    photo: appState.selectedPhoto,
                                    hairColor: style.hairColor,
                                    onTap: { showPicker = true },
                                    onTapPhoto: { showPhotoPreview = true },
                                    onRemove: {
                                        appState.selectedPhoto = nil
                                        appState.activeProfileId = nil
                                    }
                                )

                                if !appState.profiles.isEmpty {
                                    profilePickerRow
                                }
                            }

                            tipsSection

                            Spacer(minLength: 120)
                        }
                        .padding(.horizontal, DS.paddingPage)
                        .padding(.top, 16)
                    }
                }
            }

            bottomCTA
        }
        .background(Color.hairBg)
        .navigationBarHidden(true)
        .sheet(isPresented: $showPicker) {
            PhotoPickerSheet(isPresented: $showPicker) { image in
                appState.selectedPhoto = image
            }
        }
        .sheet(isPresented: $showPhotoPreview) {
            if let photo = appState.selectedPhoto {
                FullscreenImageSheet(image: photo)
            }
        }
        .sheet(isPresented: $showSampleFullscreen) {
            if !sampleUIImages.isEmpty {
                FullscreenCarouselSheet(images: sampleUIImages, startIndex: carouselPage)
            }
        }
    }

    // MARK: - Hero

    @ViewBuilder
    private var heroArea: some View {
        if sampleUIImages.isEmpty {
            StyleHeroView(style: style)
                .frame(maxWidth: .infinity)
                .frame(height: 240)
        } else {
            ZStack(alignment: .bottom) {
                TabView(selection: $carouselPage) {
                    ForEach(sampleUIImages.indices, id: \.self) { i in
                        Image(uiImage: sampleUIImages[i])
                            .resizable()
                            .scaledToFill()
                            .tag(i)
                            .onTapGesture { showSampleFullscreen = true }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxWidth: .infinity)
                .frame(height: 240)

                // Page dots
                if sampleUIImages.count > 1 {
                    HStack(spacing: 5) {
                        ForEach(sampleUIImages.indices, id: \.self) { i in
                            Circle()
                                .fill(i == carouselPage ? Color.white : Color.white.opacity(0.45))
                                .frame(width: i == carouselPage ? 7 : 5, height: i == carouselPage ? 7 : 5)
                        }
                    }
                    .padding(.bottom, 10)
                    .animation(.easeInOut(duration: 0.15), value: carouselPage)
                }
            }
        }
    }

    // MARK: - Nav bar

    private var navBar: some View {
        ScreenNav(
            title: style.name,
            onBack: onBack,
            trailing: AnyView(navTrailing)
        )
        .background(Color.hairBg)
    }

    @ViewBuilder
    private var navTrailing: some View {
        Button(action: { appState.toggleFavorite(style.id) }) {
            Image(systemName: appState.isFavorite(style.id) ? "heart.fill" : "heart")
                .font(.system(size: 20))
                .foregroundStyle(appState.isFavorite(style.id) ? Color.hairPink : Color.hairText)
        }
    }

    // MARK: - Profile picker

    private var profilePickerRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Or use a profile photo")
                .font(.system(size: 12))
                .foregroundStyle(Color.hairTextSec)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(appState.profiles) { profile in
                        let isSelected = appState.activeProfileId == profile.id
                        Button {
                            if let path = profile.displayPhotoPath,
                               let img = ProfilesStore.shared.loadPhoto(path: path) {
                                appState.selectedPhoto = img
                                appState.activeProfileId = profile.id
                            }
                        } label: {
                            VStack(spacing: 4) {
                                ProfileAvatarView(profile: profile, size: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(isSelected ? Color.hairPurple : Color.clear, lineWidth: 2)
                                    )
                                Text(profile.name.split(separator: " ").first.map(String.init) ?? profile.name)
                                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                                    .foregroundStyle(isSelected ? Color.hairPurple : Color.hairTextSec)
                                    .lineLimit(1)
                            }
                            .frame(width: 52)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Tips

    private var tipsSection: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { tipsExpanded.toggle() }
            }) {
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

    // MARK: - Bottom CTA

    private var bottomCTA: some View {
        VStack(spacing: 8) {
            Divider().opacity(0.4)
            PrimaryButton(
                title: "Generate Preview",
                icon: "✨",
                variant: .gradient,
                disabled: !appState.hasPhoto,
                action: onGenerate
            )
            Text(appState.hasPhoto
                 ? "Uses 1 credit · \(appState.credits) remaining"
                 : "Upload a photo to continue")
                .font(.system(size: 12))
                .foregroundStyle(Color.hairTextSec)
            Button(action: onCustom) {
                Text("Try a Custom Style Instead")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.hairPurple)
            }
        }
        .padding(.horizontal, DS.paddingPage)
        .padding(.top, 10)
        .padding(.bottom, 24)
        .background(.regularMaterial)
    }
}

// MARK: - Fullscreen sheets

private struct FullscreenImageSheet: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(20)
            }
        }
        .presentationBackground(.black)
    }
}

private struct FullscreenCarouselSheet: View {
    let images: [UIImage]
    let startIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var page: Int = 0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            TabView(selection: $page) {
                ForEach(images.indices, id: \.self) { i in
                    Image(uiImage: images[i])
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: images.count > 1 ? .always : .never))

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(20)
            }
        }
        .presentationBackground(.black)
        .onAppear { page = startIndex }
    }
}
