import Foundation
import SwiftUI
import UIKit

// Persists user-saved custom styles across launches.
// Sample images are JPEG files in Documents/custom_styles_images/.
final class CustomStylesStore {
    static let shared = CustomStylesStore()

    private struct Persisted: Codable {
        let id: Int
        let name: String
        let prompt: String
        let createdAt: Date
        let sampleImageFiles: [String]  // filenames only, resolved to absolute paths on load
    }

    private var docsDir: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    private var metaURL: URL { docsDir.appendingPathComponent("custom_styles.json") }
    private var imagesDir: URL { docsDir.appendingPathComponent("custom_styles_images", isDirectory: true) }

    init() {
        try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
    }

    func load() -> [HairStyle] {
        guard let data = try? Data(contentsOf: metaURL),
              let persisted = try? JSONDecoder().decode([Persisted].self, from: data) else {
            return []
        }
        return persisted.map { p in
            let paths = p.sampleImageFiles.map { imagesDir.appendingPathComponent($0).path }
            return HairStyle(
                id: p.id,
                name: p.name,
                category: "Custom",
                gender: "Unisex",
                hairColor: Color(red: 0.486, green: 0.227, blue: 0.929),
                gradientColors: [
                    Color(red: 0.122, green: 0.063, blue: 0.235),
                    Color(red: 0.298, green: 0.157, blue: 0.596),
                    Color(red: 0.925, green: 0.286, blue: 0.600),
                ],
                description: p.prompt,
                styleKey: "",
                sampleImages: paths,
                customPrompt: p.prompt
            )
        }
    }

    func save(_ styles: [HairStyle]) {
        let persisted = styles.compactMap { style -> Persisted? in
            guard let prompt = style.customPrompt else { return nil }
            let filenames = style.sampleImages.map { ($0 as NSString).lastPathComponent }
            return Persisted(
                id: style.id,
                name: style.name,
                prompt: prompt,
                createdAt: .now,
                sampleImageFiles: filenames
            )
        }
        if let data = try? JSONEncoder().encode(persisted) {
            try? data.write(to: metaURL, options: .atomic)
        }
    }

    // Save image data to disk and return absolute paths (used as sampleImages entries).
    func saveSampleImages(_ images: [UIImage], for styleID: Int) -> [String] {
        var paths: [String] = []
        for (idx, image) in images.enumerated() {
            let filename = "\(styleID)_sample_\(idx).jpg"
            let url = imagesDir.appendingPathComponent(filename)
            if let data = image.jpegData(compressionQuality: 0.85) {
                try? data.write(to: url, options: .atomic)
                paths.append(url.path)
            }
        }
        return paths
    }

    // Remove a custom style's sample image files from disk.
    func deleteSampleImages(for styleID: Int) {
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: imagesDir.path) else { return }
        for file in files where file.hasPrefix("\(styleID)_sample_") {
            try? FileManager.default.removeItem(at: imagesDir.appendingPathComponent(file))
        }
    }

    func nextID() -> Int {
        let existing = load().map(\.id)
        let max = existing.max() ?? 9999
        return Swift.max(max + 1, 10000)  // catalog uses 1-20; custom starts at 10000+
    }
}
