import SwiftUI

struct ProfilesListView: View {
    @Bindable var appState: AppState
    var onBack: () -> Void
    var onSelectProfile: (PersonProfile) -> Void

    @State private var showEdit = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                ScreenNav(
                    title: "Profiles",
                    onBack: onBack,
                    trailing: AnyView(
                        Button("+ New") { showEdit = true }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.hairPurple)
                    )
                )

                if appState.profiles.isEmpty {
                    emptyState
                } else {
                    profileGrid
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.hairBgOff)
        }
        .sheet(isPresented: $showEdit) {
            ProfileEditView(profile: nil) { name, notes, avatarImage in
                var newProfile = PersonProfile(name: name, notes: notes)
                if let img = avatarImage {
                    let path = ProfilesStore.shared.saveAvatarPhoto(img, profileId: newProfile.id)
                    newProfile.avatarPhotoPath = path
                }
                appState.profiles.append(newProfile)
                showEdit = false
            } onCancel: {
                showEdit = false
            }
            .presentationDetents([.medium, .large])
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.hairPurpleAlpha)
                    .frame(width: 80, height: 80)
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.hairPurple)
            }
            VStack(spacing: 6) {
                Text("No profiles yet")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.hairText)
                Text("Save profiles for yourself,\nfamily, or clients.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.hairTextSec)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            PrimaryButton(title: "Create First Profile", variant: .gradient) {
                showEdit = true
            }
            .frame(width: 200)
            Spacer()
        }
        .padding(.horizontal, DS.paddingPage)
    }

    private var profileGrid: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                ForEach(appState.profiles) { profile in
                    ProfileCard(profile: profile) {
                        onSelectProfile(profile)
                    }
                }
            }
            .padding(.horizontal, DS.paddingPage)
            .padding(.top, 4)
            .padding(.bottom, 30)
        }
    }
}

// MARK: - ProfileCard

private struct ProfileCard: View {
    let profile: PersonProfile
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    ProfileAvatarView(profile: profile, size: 60)

                    VStack(spacing: 3) {
                        Text(profile.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.hairText)
                            .lineLimit(1)
                        Text(entrySubtitle)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.hairTextSec)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 16)
                .padding(.bottom, profile.entries.isEmpty ? 12 : 10)

                if !profile.entries.isEmpty {
                    miniPhotoStrip
                        .padding(.horizontal, 14)
                        .padding(.bottom, 12)
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.hairBg)
            .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))
            .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var entrySubtitle: String {
        if profile.entries.isEmpty { return "No entries yet" }
        let count = profile.entries.count
        let noun = count == 1 ? "entry" : "entries"
        return "\(count) \(noun) · \(relativeDate(profile.entries[0].date))"
    }

    private var miniPhotoStrip: some View {
        HStack(spacing: 5) {
            ForEach(profile.entries.prefix(3)) { entry in
                ProfilePhotoThumb(path: entry.photoPath, size: 30)
            }
            if profile.entries.count > 3 {
                ZStack {
                    Circle()
                        .fill(Color.hairPurpleAlpha)
                    Text("+\(profile.entries.count - 3)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.hairPurple)
                }
                .frame(width: 30, height: 30)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func relativeDate(_ date: Date) -> String {
        let diff = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        if diff <= 0 { return "Today" }
        if diff == 1 { return "Yesterday" }
        if diff < 8  { return "\(diff)d ago" }
        let fmt = DateFormatter()
        if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
            fmt.dateFormat = "MMM d"
        } else {
            fmt.dateFormat = "MMM d, yyyy"
        }
        return fmt.string(from: date)
    }
}

// MARK: - Shared subviews

struct ProfileAvatarView: View {
    let profile: PersonProfile
    let size: CGFloat

    private var photo: UIImage? {
        guard let path = profile.displayPhotoPath else { return nil }
        return ProfilesStore.shared.loadPhoto(path: path)
    }

    private var initials: String {
        profile.name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map { String($0) } }
            .joined()
            .uppercased()
    }

    private var accentColor: Color {
        let palette: [Color] = [.hairPurple, Color(red:0.055,green:0.647,blue:0.914), Color(red:0.133,green:0.773,blue:0.369), Color(red:0.961,green:0.62,blue:0.043), .hairPink]
        let idx = abs(profile.name.hashValue) % palette.count
        return palette[idx]
    }

    var body: some View {
        ZStack {
            if let img = photo {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(LinearGradient(colors: [accentColor, accentColor.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: size, height: size)
                Text(initials.isEmpty ? "?" : initials)
                    .font(.system(size: size * 0.34, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }
}

struct ProfilePhotoThumb: View {
    let path: String
    let size: CGFloat

    private var image: UIImage? { ProfilesStore.shared.loadPhoto(path: path) }

    var body: some View {
        ZStack {
            Circle().fill(Color.hairBgOff)
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.hairBg, lineWidth: 2))
        .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1)
    }
}
