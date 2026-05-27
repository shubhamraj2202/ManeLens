import SwiftUI
import UIKit

enum ThemeMode: String, CaseIterable {
    case system, light, dark

    var label: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

struct GenerationRecord: Identifiable {
    var id: UUID = UUID()
    let style: HairStyle
    var liked: Bool = false
    var date: Date = .now
    let originalImage: UIImage?
    let resultImage: UIImage?
}

@Observable
class AppState {
    let creditManager = CreditManager()

    var selectedPhoto: UIImage? = nil
    var generatedImage: UIImage? = nil
    var customPromptText: String = ""
    var generationError: String? = nil
    var homeSelectedCategory: String = "All"
    var homeSearchText: String = ""
    var history: [GenerationRecord] = [] {
        didSet { HistoryStore.shared.save(history) }
    }

    var customStyles: [HairStyle] = [] {
        didSet { CustomStylesStore.shared.save(customStyles) }
    }

    init() {
        self.history = HistoryStore.shared.load()
        self.customStyles = CustomStylesStore.shared.load()
    }

    func saveCustomStyle(name: String, prompt: String, sampleImages: [UIImage] = []) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !trimmedPrompt.isEmpty else { return }
        let newID = CustomStylesStore.shared.nextID()
        let imagePaths = sampleImages.isEmpty
            ? []
            : CustomStylesStore.shared.saveSampleImages(sampleImages, for: newID)
        let style = HairStyle(
            id: newID,
            name: trimmedName,
            category: "Custom",
            gender: "Unisex",
            hairColor: Color(red: 0.486, green: 0.227, blue: 0.929),
            gradientColors: [
                Color(red: 0.122, green: 0.063, blue: 0.235),
                Color(red: 0.298, green: 0.157, blue: 0.596),
                Color(red: 0.925, green: 0.286, blue: 0.600),
            ],
            description: trimmedPrompt,
            styleKey: "",
            sampleImages: imagePaths,
            customPrompt: trimmedPrompt
        )
        customStyles.append(style)
    }

    func deleteCustomStyle(id: Int) {
        customStyles.removeAll { $0.id == id }
        CustomStylesStore.shared.deleteSampleImages(for: id)
        favorites.remove(id)
    }

    func updateCustomStyle(id: Int, name: String, prompt: String, sampleImages: [UIImage] = []) {
        guard let idx = customStyles.firstIndex(where: { $0.id == id }) else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !trimmedPrompt.isEmpty else { return }
        CustomStylesStore.shared.deleteSampleImages(for: id)
        let imagePaths = sampleImages.isEmpty ? [] : CustomStylesStore.shared.saveSampleImages(sampleImages, for: id)
        let existing = customStyles[idx]
        customStyles[idx] = HairStyle(
            id: id,
            name: trimmedName,
            category: "Custom",
            gender: "Unisex",
            hairColor: existing.hairColor,
            gradientColors: existing.gradientColors,
            description: trimmedPrompt,
            styleKey: "",
            sampleImages: imagePaths,
            customPrompt: trimmedPrompt
        )
    }

    var themeMode: ThemeMode = ThemeMode(rawValue: UserDefaults.standard.string(forKey: "hairlens_theme") ?? "system") ?? .system {
        didSet { UserDefaults.standard.set(themeMode.rawValue, forKey: "hairlens_theme") }
    }

    var favorites: Set<Int> = {
        let kvArr = NSUbiquitousKeyValueStore.default.array(forKey: "hairlens_favorites_v1") as? [Int]
        let udArr = UserDefaults.standard.array(forKey: "hairlens_favorites") as? [Int]
        return Set(kvArr ?? udArr ?? [])
    }() {
        didSet {
            let arr = Array(favorites)
            UserDefaults.standard.set(arr, forKey: "hairlens_favorites")
            NSUbiquitousKeyValueStore.default.set(arr, forKey: "hairlens_favorites_v1")
            NSUbiquitousKeyValueStore.default.synchronize()
        }
    }

    func isFavorite(_ id: Int) -> Bool { favorites.contains(id) }
    func toggleFavorite(_ id: Int) {
        if favorites.contains(id) { favorites.remove(id) } else { favorites.insert(id) }
    }

    var credits: Int { creditManager.credits }
    var hasPhoto: Bool { selectedPhoto != nil }

    func consumeCredit() { creditManager.consume() }
    func refundCredit()  { creditManager.refund() }

    func recordGeneration(style: HairStyle, original: UIImage?, result: UIImage?) {
        history.insert(GenerationRecord(style: style, originalImage: original, resultImage: result), at: 0)
    }
}
