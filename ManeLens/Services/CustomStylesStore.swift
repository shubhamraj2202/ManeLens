import Foundation
import SwiftUI

// Persists user-saved custom styles across launches.
// Brand color/gradient is rehydrated on load (UIColor isn't Codable cleanly).
final class CustomStylesStore {
    static let shared = CustomStylesStore()

    private struct Persisted: Codable {
        let id: Int
        let name: String
        let prompt: String
        let createdAt: Date
    }

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("custom_styles.json")
    }

    func load() -> [HairStyle] {
        guard let data = try? Data(contentsOf: fileURL),
              let persisted = try? JSONDecoder().decode([Persisted].self, from: data) else {
            return []
        }
        return persisted.map { p in
            HairStyle(
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
                customPrompt: p.prompt
            )
        }
    }

    func save(_ styles: [HairStyle]) {
        let persisted = styles.compactMap { style -> Persisted? in
            guard let prompt = style.customPrompt else { return nil }
            return Persisted(id: style.id, name: style.name, prompt: prompt, createdAt: .now)
        }
        if let data = try? JSONEncoder().encode(persisted) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    func nextID() -> Int {
        let existing = load().map(\.id)
        let max = existing.max() ?? 9999
        return Swift.max(max + 1, 10000)  // catalog uses 1-20; custom starts at 10000+
    }
}
