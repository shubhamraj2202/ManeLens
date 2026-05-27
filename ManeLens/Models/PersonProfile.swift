import Foundation

struct TimelineEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = .now
    var photoPath: String
    var note: String = ""
    var styleKey: String? = nil
    var generatedPhotoPath: String? = nil
}

struct PersonProfile: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var entries: [TimelineEntry] = []
    var notes: String = ""
    var avatarPhotoPath: String? = nil

    var latestPhotoPath: String? { entries.first?.photoPath }
    var displayPhotoPath: String? { avatarPhotoPath ?? latestPhotoPath }
    var entryCount: Int { entries.count }

    var sinceLabel: String? {
        guard let oldest = entries.last else { return nil }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        return fmt.string(from: oldest.date)
    }
}
