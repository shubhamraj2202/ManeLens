import UIKit

final class ProfilesStore {
    static let shared = ProfilesStore()
    private init() {}

    private var profilesURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("profiles.json")
    }

    private func photosDir() -> URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ProfilePhotos", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    func save(_ profiles: [PersonProfile]) {
        guard let data = try? JSONEncoder().encode(profiles) else { return }
        try? data.write(to: profilesURL)
    }

    func load() -> [PersonProfile] {
        guard let data = try? Data(contentsOf: profilesURL),
              let profiles = try? JSONDecoder().decode([PersonProfile].self, from: data)
        else { return [] }
        return profiles
    }

    func savePhoto(_ image: UIImage, profileId: UUID, entryId: UUID) -> String {
        let name = "\(profileId.uuidString)_\(entryId.uuidString).jpg"
        let url = photosDir().appendingPathComponent(name)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: url)
        }
        return name
    }

    func saveAvatarPhoto(_ image: UIImage, profileId: UUID) -> String {
        let name = "avatar_\(profileId.uuidString).jpg"
        let url = photosDir().appendingPathComponent(name)
        if let data = image.jpegData(compressionQuality: 0.85) {
            try? data.write(to: url)
        }
        return name
    }

    func loadPhoto(path: String) -> UIImage? {
        let url = photosDir().appendingPathComponent(path)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    func deletePhoto(path: String) {
        let url = photosDir().appendingPathComponent(path)
        try? FileManager.default.removeItem(at: url)
    }
}
