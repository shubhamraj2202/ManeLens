import SwiftUI
import PhotosUI

struct CustomPromptView: View {
    @Bindable var appState: AppState
    var onBack: () -> Void
    var onGenerate: () -> Void

    @State private var showPicker = false
    @State private var styleName: String = ""
    @State private var savedToast: String? = nil
    @State private var sampleImagePickerItems: [PhotosPickerItem] = []
    @State private var sampleImages: [UIImage] = []

    private let chips = ["Long & wavy", "Short & textured", "Bold color", "Vintage", "Editorial", "Curly"]
    private let maxLength = 200
    private let maxNameLength = 30

    private var canSave: Bool {
        !styleName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !appState.customPromptText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // Header text
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Describe Your Dream Hairstyle")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.hairText)
                        Text("Be specific — length, color, texture, vibe")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.hairTextSec)
                    }

                    // Style Name input
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Style Name")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.hairText)
                        TextField("e.g. 'My beach vibe'", text: $styleName)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.hairText)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.hairPurpleLight)
                            .clipShape(RoundedRectangle(cornerRadius: DS.radiusInput))
                            .overlay(
                                RoundedRectangle(cornerRadius: DS.radiusInput)
                                    .stroke(Color.hairPurple.opacity(0.2), lineWidth: 1.5)
                            )
                            .onChange(of: styleName) { _, new in
                                if new.count > maxNameLength {
                                    styleName = String(new.prefix(maxNameLength))
                                }
                            }
                    }

                    // Text area — bound directly to appState so ContentView can read it
                    ZStack(alignment: .bottomTrailing) {
                        TextEditor(text: $appState.customPromptText)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.hairText)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 120)
                            .padding(14)
                            .onChange(of: appState.customPromptText) { _, new in
                                if new.count > maxLength {
                                    appState.customPromptText = String(new.prefix(maxLength))
                                }
                            }

                        if appState.customPromptText.isEmpty {
                            Text("e.g., Long wavy beach blonde hair with side bangs, K-pop inspired…")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.hairTextSec.opacity(0.6))
                                .padding(18)
                                .allowsHitTesting(false)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Text("\(appState.customPromptText.count)/\(maxLength)")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.hairTextSec)
                            .padding(10)
                    }
                    .background(Color.hairPurpleLight)
                    .clipShape(RoundedRectangle(cornerRadius: DS.radiusInput))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.radiusInput)
                            .stroke(Color.hairPurple.opacity(0.2), lineWidth: 1.5)
                    )

                    // Optional: sample images for the saved style's card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Sample Images")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.hairText)
                            Text("(optional)")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.hairTextSec)
                            Spacer()
                            PhotosPicker(selection: $sampleImagePickerItems, maxSelectionCount: 5, matching: .images) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 11, weight: .bold))
                                    Text(sampleImages.isEmpty ? "Add" : "Edit")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundStyle(Color.hairPurple)
                            }
                        }

                        if sampleImages.isEmpty {
                            Text("Add up to 5 reference photos to show on this style's card.")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.hairTextSec)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(sampleImages.enumerated()), id: \.offset) { idx, img in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: img)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 72, height: 72)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                            Button {
                                                sampleImages.remove(at: idx)
                                                if idx < sampleImagePickerItems.count {
                                                    sampleImagePickerItems.remove(at: idx)
                                                }
                                            } label: {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 9, weight: .bold))
                                                    .foregroundStyle(.white)
                                                    .frame(width: 18, height: 18)
                                                    .background(.black.opacity(0.65))
                                                    .clipShape(Circle())
                                            }
                                            .padding(4)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Save Style — saves the template (without generating)
                    Button(action: saveCustomStyle) {
                        HStack(spacing: 8) {
                            Image(systemName: "bookmark.fill")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Save to My Styles")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(canSave ? Color.hairPurple : Color.hairTextSec)
                        .padding(.horizontal, 16)
                        .frame(height: 38)
                        .background(canSave ? Color.hairPurpleAlpha : Color.black.opacity(0.05))
                        .overlay(Capsule().stroke(canSave ? Color.hairPurple.opacity(0.3) : Color.clear, lineWidth: 1))
                        .clipShape(Capsule())
                    }
                    .disabled(!canSave)

                    // Quick chips
                    FlowLayout(spacing: 8) {
                        ForEach(chips, id: \.self) { chip in
                            Button(action: {
                                let addition = appState.customPromptText.isEmpty
                                    ? chip.lowercased()
                                    : ", \(chip.lowercased())"
                                appState.customPromptText += addition
                            }) {
                                Text(chip)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.hairPurple)
                                    .padding(.horizontal, 14)
                                    .frame(height: 32)
                                    .background(Color.hairPurpleAlpha)
                                    .overlay(
                                        Capsule().stroke(Color.hairPurple.opacity(0.25), lineWidth: 1.5)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    // Photo upload
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Photo")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.hairText)

                        PhotoUploadZone(
                            photo: appState.selectedPhoto,
                            hairColor: Color(red: 0.29, green: 0.18, blue: 0.11),
                            onTap: { showPicker = true },
                            onRemove: { appState.selectedPhoto = nil }
                        )
                    }

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, DS.paddingPage)
                .padding(.top, 56)
            }

            // Bottom CTA
            bottomCTA
        }
        .background(Color.hairBg)
        .navigationBarHidden(true)
        .overlay(alignment: .top) {
            ScreenNav(
                title: "Custom Style",
                onBack: onBack,
                trailing: AnyView(
                    Button(action: onBack) {
                        Text("Cancel")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.hairPurple)
                    }
                )
            )
            .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showPicker) {
            PhotoPickerSheet(isPresented: $showPicker) { image in
                appState.selectedPhoto = image
            }
        }
        .onChange(of: sampleImagePickerItems) { _, items in
            Task {
                var images: [UIImage] = []
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let img = UIImage(data: data) {
                        images.append(img)
                    }
                }
                await MainActor.run { sampleImages = images }
            }
        }
        .overlay(alignment: .bottom) {
            if let msg = savedToast {
                Text(msg)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.75))
                    .clipShape(Capsule())
                    .padding(.bottom, 140)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation { savedToast = nil }
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: savedToast)
    }

    private func saveCustomStyle() {
        guard canSave else { return }
        appState.saveCustomStyle(name: styleName, prompt: appState.customPromptText, sampleImages: sampleImages)
        savedToast = "Saved to My Styles"
        styleName = ""
        appState.customPromptText = ""
        sampleImages = []
        sampleImagePickerItems = []
    }

    private var bottomCTA: some View {
        VStack(spacing: 8) {
            Divider().opacity(0.4)
            PrimaryButton(
                title: "Generate Preview",
                icon: "✨",
                variant: appState.customPromptText.trimmingCharacters(in: .whitespaces).isEmpty ? .primary : .gradient,
                disabled: appState.customPromptText.trimmingCharacters(in: .whitespaces).isEmpty || !appState.hasPhoto,
                action: onGenerate
            )
            Text(appState.hasPhoto
                 ? "Uses 1 credit · \(appState.credits) remaining"
                 : "Upload a photo to continue")
                .font(.system(size: 12))
                .foregroundStyle(Color.hairTextSec)
        }
        .padding(.horizontal, DS.paddingPage)
        .padding(.top, 10)
        .padding(.bottom, 24)
        .background(.regularMaterial)
    }
}

// MARK: - Simple flow layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.maxHeight }.reduce(0, +) + CGFloat(max(rows.count - 1, 0)) * spacing
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for subview in row.subviews {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.maxHeight + spacing
        }
    }

    private struct Row {
        var subviews: [LayoutSubview] = []
        var maxHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [Row] = []
        var current = Row()

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let needed = current.totalWidth == 0 ? size.width : current.totalWidth + spacing + size.width
            if needed > maxWidth && !current.subviews.isEmpty {
                rows.append(current)
                current = Row()
            }
            current.subviews.append(subview)
            current.totalWidth = current.subviews.count == 1 ? size.width : current.totalWidth + spacing + size.width
            current.maxHeight = max(current.maxHeight, size.height)
        }
        if !current.subviews.isEmpty { rows.append(current) }
        return rows
    }
}
