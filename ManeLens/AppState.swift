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
    let creditManager = CreditManager()

    var selectedPhoto: UIImage? = nil
    var generatedImage: UIImage? = nil
    var customPromptText: String = ""
    var generationError: String? = nil
    var history: [GenerationRecord] = []

    var credits: Int { creditManager.credits }
    var hasPhoto: Bool { selectedPhoto != nil }

    func consumeCredit() { creditManager.consume() }
    func refundCredit()  { creditManager.refund() }

    func recordGeneration(style: HairStyle) {
        history.insert(GenerationRecord(style: style), at: 0)
    }
}
