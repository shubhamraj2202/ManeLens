import SwiftUI
import UIKit

struct GenerationRecord: Identifiable {
    let id = UUID()
    let style: HairStyle
    var liked: Bool = false
    let date: Date = .now
}

@Observable
class AppState {
    var credits: Int = 3
    var selectedPhoto: UIImage? = nil
    var generatedImage: UIImage? = nil
    var customPromptText: String = ""
    var generationError: String? = nil
    var showOnboarding: Bool = true
    var history: [GenerationRecord] = []
    var selectedStyle: HairStyle? = nil

    var hasPhoto: Bool { selectedPhoto != nil }

    func consumeCredit() { if credits > 0 { credits -= 1 } }
    func refundCredit() { credits += 1 }
    func addCredits(_ n: Int) { credits += n }

    func recordGeneration(style: HairStyle) {
        history.insert(GenerationRecord(style: style), at: 0)
    }
}
