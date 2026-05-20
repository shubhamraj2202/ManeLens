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
    let id = UUID()
    let style: HairStyle
    var liked: Bool = false
    let date: Date = .now
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
    var history: [GenerationRecord] = []

    var themeMode: ThemeMode = ThemeMode(rawValue: UserDefaults.standard.string(forKey: "hairlens_theme") ?? "system") ?? .system {
        didSet { UserDefaults.standard.set(themeMode.rawValue, forKey: "hairlens_theme") }
    }

    var credits: Int { creditManager.credits }
    var hasPhoto: Bool { selectedPhoto != nil }

    func consumeCredit() { creditManager.consume() }
    func refundCredit()  { creditManager.refund() }

    func recordGeneration(style: HairStyle, original: UIImage?, result: UIImage?) {
        history.insert(GenerationRecord(style: style, originalImage: original, resultImage: result), at: 0)
    }
}
