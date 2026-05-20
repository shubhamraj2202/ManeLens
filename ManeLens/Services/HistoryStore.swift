import Foundation
import UIKit

// Persists GenerationRecord across app launches and updates.
// Files live in Documents/ so they survive normal upgrades but not full uninstall.
final class HistoryStore {
    static let shared = HistoryStore()

    private struct Persisted: Codable {
        let id: UUID
        let date: Date
        let styleId: Int
        let liked: Bool
    }

    private var docsDir: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    private var metaURL: URL { docsDir.appendingPathComponent("history.json") }
    private var imagesDir: URL { docsDir.appendingPathComponent("history_images", isDirectory: true) }

    init() {
        try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
    }

    func load() -> [GenerationRecord] {
        guard let data = try? Data(contentsOf: metaURL),
              let persisted = try? JSONDecoder().decode([Persisted].self, from: data) else {
            return []
        }
        return persisted.compactMap { p in
            guard let style = HairStyle.catalog.first(where: { $0.id == p.styleId }) else { return nil }
            let originalPath = imagesDir.appendingPathComponent("\(p.id.uuidString)_original.jpg").path
            let resultPath = imagesDir.appendingPathComponent("\(p.id.uuidString)_result.jpg").path
            return GenerationRecord(
                id: p.id,
                style: style,
                liked: p.liked,
                date: p.date,
                originalImage: UIImage(contentsOfFile: originalPath),
                resultImage: UIImage(contentsOfFile: resultPath)
            )
        }
    }

    func save(_ records: [GenerationRecord]) {
        let persisted = records.map {
            Persisted(id: $0.id, date: $0.date, styleId: $0.style.id, liked: $0.liked)
        }
        if let data = try? JSONEncoder().encode(persisted) {
            try? data.write(to: metaURL, options: .atomic)
        }

        for record in records {
            let originalURL = imagesDir.appendingPathComponent("\(record.id.uuidString)_original.jpg")
            let resultURL = imagesDir.appendingPathComponent("\(record.id.uuidString)_result.jpg")
            if let img = record.originalImage,
               !FileManager.default.fileExists(atPath: originalURL.path),
               let data = img.jpegData(compressionQuality: 0.85) {
                try? data.write(to: originalURL)
            }
            if let img = record.resultImage,
               !FileManager.default.fileExists(atPath: resultURL.path),
               let data = img.jpegData(compressionQuality: 0.85) {
                try? data.write(to: resultURL)
            }
        }

        // Clean orphan image files
        let validIDs = Set(records.map { $0.id.uuidString })
        if let files = try? FileManager.default.contentsOfDirectory(atPath: imagesDir.path) {
            for file in files {
                let baseID = String(file.split(separator: "_").first ?? "")
                if !validIDs.contains(baseID) {
                    try? FileManager.default.removeItem(at: imagesDir.appendingPathComponent(file))
                }
            }
        }
    }
}
