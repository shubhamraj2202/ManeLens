import SwiftUI

struct ProfileDetailView: View {
    @Bindable var appState: AppState
    var profileId: UUID
    var onBack: () -> Void
    var onAnalyse: (PersonProfile, UIImage) -> Void
    var onUseForStyle: (UIImage) -> Void
    var onEntryDetail: (PersonProfile, TimelineEntry) -> Void

    @State private var showEdit = false
    @State private var showAddEntry = false

    private var profile: PersonProfile? {
        appState.profiles.first { $0.id == profileId }
    }

    var body: some View {
        guard let profile else {
            return AnyView(ScreenNav(title: "Profile", onBack: onBack))
        }
        return AnyView(content(profile: profile))
    }

    @ViewBuilder
    private func content(profile: PersonProfile) -> some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                ScreenNav(
                    title: "",
                    onBack: onBack,
                    trailing: AnyView(
                        Button("Edit") { showEdit = true }
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.hairPurple)
                    )
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        profileHeader(profile: profile)

                        if profile.entries.isEmpty {
                            emptyTimeline
                        } else {
                            timelineBody(profile: profile)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.hairBgOff)

            // FAB
            Button {
                showAddEntry = true
            } label: {
                ZStack {
                    Circle()
                        .fill(LinearGradient.hairBrand)
                        .frame(width: 52, height: 52)
                        .shadow(color: Color.hairPurple.opacity(0.42), radius: 12, x: 0, y: 6)
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            .padding(.trailing, DS.paddingPage)
            .padding(.bottom, 48)
        }
        .sheet(isPresented: $showEdit) {
            ProfileEditView(profile: profile) { name, notes in
                if let idx = appState.profiles.firstIndex(where: { $0.id == profile.id }) {
                    appState.profiles[idx].name = name
                    appState.profiles[idx].notes = notes
                }
                showEdit = false
            } onCancel: {
                showEdit = false
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showAddEntry) {
            AddTimelineEntryView(profile: profile) { image, date, note, styleKey in
                let path = ProfilesStore.shared.savePhoto(image, profileId: profile.id, entryId: UUID())
                let entry = TimelineEntry(date: date, photoPath: path, note: note, styleKey: styleKey)
                if let idx = appState.profiles.firstIndex(where: { $0.id == profile.id }) {
                    appState.profiles[idx].entries.insert(entry, at: 0)
                }
                showAddEntry = false
            } onCancel: {
                showAddEntry = false
            }
            .presentationDetents([.large])
        }
    }

    private func profileHeader(profile: PersonProfile) -> some View {
        VStack(spacing: 10) {
            ProfileAvatarView(profile: profile, size: 72)

            VStack(spacing: 3) {
                Text(profile.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.hairText)
                Text(headerSubtitle(profile: profile))
                    .font(.system(size: 13))
                    .foregroundStyle(Color.hairTextSec)
            }

            // Action chips
            HStack(spacing: 8) {
                ActionChip(icon: "face.dashed", label: "Analyse", gradient: false) {
                    if let path = profile.latestPhotoPath,
                       let img = ProfilesStore.shared.loadPhoto(path: path) {
                        onAnalyse(profile, img)
                    }
                }
                ActionChip(icon: "plus", label: "Add Entry", gradient: true) {
                    showAddEntry = true
                }
                ActionChip(icon: "wand.and.stars", label: "Try Style", gradient: false) {
                    if let path = profile.latestPhotoPath,
                       let img = ProfilesStore.shared.loadPhoto(path: path) {
                        onUseForStyle(img)
                    }
                }
            }

            if !profile.notes.isEmpty {
                Text(profile.notes)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.hairTextSec)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.hairPurpleLight)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal, DS.paddingPage)
        .padding(.vertical, 12)
        .background(Color.hairBg)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private var emptyTimeline: some View {
        VStack(spacing: 12) {
            Text("📅").font(.system(size: 36))
            Text("No entries yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.hairText)
            Text("Add your first photo to start the timeline")
                .font(.system(size: 13))
                .foregroundStyle(Color.hairTextSec)
            PrimaryButton(title: "Add First Entry", icon: "📷", variant: .gradient) {
                showAddEntry = true
            }
            .frame(width: 180)
        }
        .padding(32)
    }

    private func timelineBody(profile: PersonProfile) -> some View {
        let groups = groupByMonth(profile.entries)
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(groups, id: \.0) { month, entries in
                VStack(alignment: .leading, spacing: 0) {
                    Text(month)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.hairTextSec)
                        .tracking(1.2)
                        .padding(.top, 18)
                        .padding(.bottom, 12)
                        .padding(.horizontal, DS.paddingPage)

                    ForEach(Array(entries.enumerated()), id: \.element.id) { idx, entry in
                        HStack(alignment: .top, spacing: 12) {
                            // Timeline dot + connector
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(Color.hairPurple)
                                    .frame(width: 10, height: 10)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.hairPurple.opacity(0.25), lineWidth: 3)
                                            .frame(width: 16, height: 16)
                                    )
                                    .padding(.top, 6)
                                if idx < entries.count - 1 {
                                    Rectangle()
                                        .fill(Color.hairPurple.opacity(0.15))
                                        .frame(width: 2)
                                        .frame(maxHeight: .infinity)
                                        .padding(.top, 4)
                                }
                            }
                            .frame(width: 18)

                            // Entry card
                            Button {
                                onEntryDetail(profile, entry)
                            } label: {
                                TimelineEntryCard(entry: entry)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, DS.paddingPage)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .padding(.bottom, 80)
    }

    private func headerSubtitle(profile: PersonProfile) -> String {
        let c = profile.entryCount
        if c == 0 { return "No entries yet" }
        let noun = c == 1 ? "entry" : "entries"
        if let since = profile.sinceLabel {
            return "\(c) \(noun) · since \(since)"
        }
        return "\(c) \(noun)"
    }

    private func groupByMonth(_ entries: [TimelineEntry]) -> [(String, [TimelineEntry])] {
        var map: [(String, [TimelineEntry])] = []
        var seen: [String: Int] = [:]
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        for e in entries {
            let key = fmt.string(from: e.date).uppercased()
            if let idx = seen[key] {
                map[idx].1.append(e)
            } else {
                seen[key] = map.count
                map.append((key, [e]))
            }
        }
        return map
    }
}

// MARK: - ActionChip

private struct ActionChip: View {
    let icon: String
    let label: String
    let gradient: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            .foregroundStyle(gradient ? .white : Color.hairPurple)
            .background(gradient ? AnyShapeStyle(LinearGradient.hairBrand) : AnyShapeStyle(Color.hairPurpleAlpha))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - TimelineEntryCard

private struct TimelineEntryCard: View {
    let entry: TimelineEntry

    private var photo: UIImage?   { ProfilesStore.shared.loadPhoto(path: entry.photoPath) }
    private var generated: UIImage? {
        guard let p = entry.generatedPhotoPath else { return nil }
        return ProfilesStore.shared.loadPhoto(path: p)
    }

    private var dateLabel: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "d MMM yyyy"
        return fmt.string(from: entry.date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo area
            ZStack {
                if let gen = generated, let orig = photo {
                    // Before/after split
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            Image(uiImage: orig)
                                .resizable().scaledToFill()
                                .frame(width: geo.size.width / 2, height: geo.size.height)
                                .clipped()
                            Image(uiImage: gen)
                                .resizable().scaledToFill()
                                .frame(width: geo.size.width / 2, height: geo.size.height)
                                .clipped()
                        }
                        .overlay(
                            Rectangle()
                                .fill(.white.opacity(0.6))
                                .frame(width: 2)
                                .frame(maxWidth: .infinity, alignment: .center)
                        )
                        .overlay(alignment: .topLeading) {
                            Text("BEFORE")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(.black.opacity(0.5))
                                .clipShape(Capsule())
                                .padding(6)
                        }
                        .overlay(alignment: .topTrailing) {
                            Text("AFTER")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color.hairPurple)
                                .clipShape(Capsule())
                                .padding(6)
                        }
                    }
                } else if let orig = photo {
                    Image(uiImage: orig)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(4/3, contentMode: .fit)
            .background(Color.hairBgOff)
            .clipped()

            // Body
            VStack(alignment: .leading, spacing: 6) {
                Text(dateLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.hairTextSec)

                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.hairText)
                        .lineLimit(2)
                        .lineSpacing(3)
                }

                if let key = entry.styleKey {
                    HStack(spacing: 4) {
                        Image(systemName: "scissors")
                            .font(.system(size: 9))
                        Text(key)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(Color.hairPurple)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.hairPurpleAlpha)
                    .clipShape(Capsule())
                }
            }
            .padding(12)
        }
        .background(Color.hairBg)
        .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 1)
    }
}
