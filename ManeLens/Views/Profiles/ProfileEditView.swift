import SwiftUI

struct ProfileEditView: View {
    var profile: PersonProfile?
    var onSave: (String, String, UIImage?) -> Void
    var onCancel: () -> Void

    @State private var name: String
    @State private var notes: String
    @State private var avatarImage: UIImage?
    @State private var showAvatarPicker = false

    init(profile: PersonProfile? = nil,
         onSave: @escaping (String, String, UIImage?) -> Void,
         onCancel: @escaping () -> Void) {
        self.profile = profile
        self.onSave = onSave
        self.onCancel = onCancel
        _name  = State(initialValue: profile?.name  ?? "")
        _notes = State(initialValue: profile?.notes ?? "")
        _avatarImage = State(initialValue: profile.flatMap {
            $0.displayPhotoPath.flatMap { ProfilesStore.shared.loadPhoto(path: $0) }
        })
    }

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 99)
                .fill(Color.hairBorder)
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 14)

            HStack {
                Text(profile == nil ? "New Profile" : "Edit Profile")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.hairText)
                Spacer()
                Button("Cancel", action: onCancel)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.hairPurple)
            }
            .padding(.horizontal, DS.paddingPage)
            .padding(.bottom, 16)

            // Tappable avatar
            Button { showAvatarPicker = true } label: {
                ZStack {
                    if let img = avatarImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(LinearGradient.hairBrand)
                            .frame(width: 72, height: 72)
                        if name.isEmpty {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(.white)
                        } else {
                            Text(String(name.prefix(1)).uppercased())
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    // Camera badge
                    Circle()
                        .fill(Color.hairPurple)
                        .frame(width: 24, height: 24)
                        .overlay(Image(systemName: "camera.fill").font(.system(size: 11)).foregroundStyle(.white))
                        .offset(x: 26, y: 26)
                }
            }
            .padding(.bottom, 18)

            VStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    TextField("Name", text: $name)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.hairText)
                        .padding(.horizontal, DS.paddingPage)
                        .padding(.vertical, 14)
                }
                .background(Color.hairBg)
                .clipShape(RoundedRectangle(cornerRadius: DS.radiusInput))
                .overlay(RoundedRectangle(cornerRadius: DS.radiusInput).stroke(Color.hairBorder, lineWidth: 1))

                ZStack(alignment: .topLeading) {
                    if notes.isEmpty {
                        Text("Notes — e.g. prefers warm tones, client since 2023")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.hairTextSec)
                            .padding(.horizontal, DS.paddingPage)
                            .padding(.vertical, 14)
                    }
                    TextEditor(text: $notes)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.hairText)
                        .frame(minHeight: 90)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .scrollContentBackground(.hidden)
                }
                .background(Color.hairBg)
                .clipShape(RoundedRectangle(cornerRadius: DS.radiusInput))
                .overlay(RoundedRectangle(cornerRadius: DS.radiusInput).stroke(Color.hairBorder, lineWidth: 1))

                PrimaryButton(title: "Save Profile", variant: .gradient, disabled: name.trimmingCharacters(in: .whitespaces).isEmpty) {
                    onSave(
                        name.trimmingCharacters(in: .whitespaces),
                        notes.trimmingCharacters(in: .whitespaces),
                        avatarImage
                    )
                }
            }
            .padding(.horizontal, DS.paddingPage)

            Spacer()
        }
        .background(Color.hairBgOff)
        .sheet(isPresented: $showAvatarPicker) {
            PhotoPickerSheet(isPresented: $showAvatarPicker) { image in
                avatarImage = image
            }
        }
    }
}
