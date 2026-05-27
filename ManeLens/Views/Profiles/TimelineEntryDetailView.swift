import SwiftUI

struct TimelineEntryDetailView: View {
    @Bindable var appState: AppState
    var profile: PersonProfile
    var entryId: UUID
    var onBack: () -> Void
    var onAnalyse: (PersonProfile, UIImage) -> Void
    var onGenerateStyle: (UIImage) -> Void
    var onDeleteEntry: () -> Void

    @State private var currentEntryId: UUID
    @State private var note: String = ""
    @State private var dragOffset: CGFloat = 0
    @GestureState private var isDragging = false

    init(appState: AppState, profile: PersonProfile, entryId: UUID,
         onBack: @escaping () -> Void,
         onAnalyse: @escaping (PersonProfile, UIImage) -> Void,
         onGenerateStyle: @escaping (UIImage) -> Void,
         onDeleteEntry: @escaping () -> Void) {
        self.appState = appState
        self.profile = profile
        self.entryId = entryId
        self.onBack = onBack
        self.onAnalyse = onAnalyse
        self.onGenerateStyle = onGenerateStyle
        self.onDeleteEntry = onDeleteEntry
        _currentEntryId = State(initialValue: entryId)
    }

    private var currentProfile: PersonProfile {
        appState.profiles.first { $0.id == profile.id } ?? profile
    }

    private var currentEntry: TimelineEntry? {
        currentProfile.entries.first { $0.id == currentEntryId }
    }

    private var currentIndex: Int? {
        currentProfile.entries.firstIndex { $0.id == currentEntryId }
    }

    var body: some View {
        guard let entry = currentEntry else {
            return AnyView(ScreenNav(title: "Entry", onBack: onBack))
        }
        return AnyView(entryContent(entry: entry))
    }

    @ViewBuilder
    private func entryContent(entry: TimelineEntry) -> some View {
        let profileSnap = currentProfile
        let entries = profileSnap.entries
        let idx = currentIndex ?? 0

        VStack(spacing: 0) {
            ScreenNav(
                title: formattedDate(entry.date),
                onBack: onBack,
                trailing: AnyView(
                    HStack(spacing: 12) {
                        if let count = currentIndex.map({ "\($0+1)/\(entries.count)" }) {
                            Text(count)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.hairTextSec)
                        }
                        Button {
                            shareEntry(entry: entry)
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 17))
                                .foregroundStyle(Color.hairPurple)
                        }
                    }
                )
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Photo or before/after slider
                    photoArea(entry: entry)

                    // Dot navigation
                    if entries.count > 1 {
                        HStack(spacing: 5) {
                            ForEach(Array(entries.enumerated()), id: \.element.id) { i, e in
                                Capsule()
                                    .fill(e.id == currentEntryId ? Color.hairPurple : Color.hairTextSec.opacity(0.25))
                                    .frame(width: e.id == currentEntryId ? 18 : 6, height: 6)
                                    .onTapGesture { currentEntryId = e.id }
                            }
                        }
                        .animation(.spring(response: 0.25), value: currentEntryId)
                        .padding(.top, 10)
                    }

                    // Entry details
                    VStack(alignment: .leading, spacing: 16) {
                        // Date
                        HStack(spacing: 10) {
                            Image(systemName: "calendar")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.hairPurple)
                            Text(longDate(entry.date))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.hairText)
                        }

                        // Note
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Note")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color.hairTextSec)
                                .textCase(.uppercase)
                                .tracking(0.6)
                            NoteEditor(profileId: profile.id, entryId: entry.id, appState: appState)
                        }

                        // Style chip
                        if let key = entry.styleKey {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Linked Style")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Color.hairTextSec)
                                    .textCase(.uppercase)
                                    .tracking(0.6)
                                HStack(spacing: 6) {
                                    Image(systemName: "scissors")
                                        .font(.system(size: 11))
                                    Text(key)
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundStyle(Color.hairPurple)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color.hairPurpleAlpha)
                                .clipShape(Capsule())
                            }
                        }

                        // Action buttons
                        HStack(spacing: 8) {
                            EntryActionButton(icon: "face.dashed", label: "Analyse", destructive: false) {
                                if let img = ProfilesStore.shared.loadPhoto(path: entry.photoPath) {
                                    onAnalyse(profileSnap, img)
                                }
                            }
                            EntryActionButton(icon: "wand.and.stars", label: "Generate", destructive: false) {
                                if let img = ProfilesStore.shared.loadPhoto(path: entry.photoPath) {
                                    onGenerateStyle(img)
                                }
                            }
                            EntryActionButton(icon: "person.crop.circle.badge.checkmark", label: "Set as DP", destructive: false) {
                                setAsProfilePhoto(entry: entry)
                            }
                            EntryActionButton(icon: "trash", label: "Delete", destructive: true) {
                                deleteEntry(entry: entry)
                            }
                        }
                    }
                    .padding(.horizontal, DS.paddingPage)
                    .padding(.top, 14)
                    .padding(.bottom, 40)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.hairBg)
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { val in
                    let dx = val.translation.width
                    guard abs(dx) > 60 else { return }
                    if dx < 0, idx < entries.count - 1 {
                        currentEntryId = entries[idx + 1].id
                    } else if dx > 0, idx > 0 {
                        currentEntryId = entries[idx - 1].id
                    }
                }
        )
    }

    @ViewBuilder
    private func photoArea(entry: TimelineEntry) -> some View {
        let orig = ProfilesStore.shared.loadPhoto(path: entry.photoPath)
        let gen  = entry.generatedPhotoPath.flatMap { ProfilesStore.shared.loadPhoto(path: $0) }
        if let o = orig, let g = gen {
            BeforeAfterSlider(before: o, after: g)
                .aspectRatio(4/5, contentMode: .fit)
        } else if let o = orig {
            Image(uiImage: o)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .aspectRatio(4/3, contentMode: .fit)
                .clipped()
        } else {
            Color.hairBgOff
                .aspectRatio(4/3, contentMode: .fit)
        }
    }

    private func setAsProfilePhoto(entry: TimelineEntry) {
        guard let img = ProfilesStore.shared.loadPhoto(path: entry.photoPath) else { return }
        let path = ProfilesStore.shared.saveAvatarPhoto(img, profileId: profile.id)
        if let pi = appState.profiles.firstIndex(where: { $0.id == profile.id }) {
            appState.profiles[pi].avatarPhotoPath = path
        }
    }

    private func deleteEntry(entry: TimelineEntry) {
        ProfilesStore.shared.deletePhoto(path: entry.photoPath)
        if let gp = entry.generatedPhotoPath { ProfilesStore.shared.deletePhoto(path: gp) }
        if let pi = appState.profiles.firstIndex(where: { $0.id == profile.id }) {
            appState.profiles[pi].entries.removeAll { $0.id == entry.id }
        }
        onDeleteEntry()
    }

    private func shareEntry(entry: TimelineEntry) {
        guard let img = ProfilesStore.shared.loadPhoto(path: entry.photoPath) else { return }
        let av = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?
            .rootViewController?.present(av, animated: true)
    }

    private func formattedDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "d MMM yyyy"
        return fmt.string(from: date)
    }

    private func longDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .full
        return fmt.string(from: date)
    }
}

// MARK: - NoteEditor

private struct NoteEditor: View {
    let profileId: UUID
    let entryId: UUID
    @Bindable var appState: AppState
    @State private var text: String = ""
    @State private var loaded = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text("Add a note…")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.hairTextSec)
                    .padding(.horizontal, 13)
                    .padding(.top, 13)
            }
            TextEditor(text: $text)
                .font(.system(size: 14))
                .foregroundStyle(Color.hairText)
                .frame(minHeight: 80)
                .padding(.horizontal, 9)
                .padding(.vertical, 8)
                .scrollContentBackground(.hidden)
                .onChange(of: text) { _, newVal in
                    guard loaded else { return }
                    if let pi = appState.profiles.firstIndex(where: { $0.id == profileId }),
                       let ei = appState.profiles[pi].entries.firstIndex(where: { $0.id == entryId }) {
                        appState.profiles[pi].entries[ei].note = newVal
                    }
                }
        }
        .background(Color.hairBgOff)
        .clipShape(RoundedRectangle(cornerRadius: DS.radiusInput))
        .overlay(RoundedRectangle(cornerRadius: DS.radiusInput).stroke(Color.hairBorder, lineWidth: 1))
        .onAppear {
            if let p = appState.profiles.first(where: { $0.id == profileId }),
               let e = p.entries.first(where: { $0.id == entryId }) {
                text = e.note
            }
            loaded = true
        }
    }
}

// MARK: - EntryActionButton

private struct EntryActionButton: View {
    let icon: String
    let label: String
    let destructive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(destructive ? Color.red : Color.hairText)
            .background(destructive ? Color.red.opacity(0.08) : Color.hairBg)
            .clipShape(RoundedRectangle(cornerRadius: DS.radiusInput))
            .overlay(
                RoundedRectangle(cornerRadius: DS.radiusInput)
                    .stroke(destructive ? Color.red.opacity(0.3) : Color.hairBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
