import SwiftUI
import UIKit

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

    var credits: Int { creditManager.credits }
    var hasPhoto: Bool { selectedPhoto != nil }

    func consumeCredit() { creditManager.consume() }
    func refundCredit()  { creditManager.refund() }

    func recordGeneration(style: HairStyle, original: UIImage?, result: UIImage?) {
        history.insert(GenerationRecord(style: style, originalImage: original, resultImage: result), at: 0)
    }
}
