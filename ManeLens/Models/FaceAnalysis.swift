import SwiftUI

struct StyleRecommendation: Identifiable, Decodable {
    let styleKey: String
    let matchPercent: Int
    let reason: String

    var id: String { styleKey }
    var hairStyle: HairStyle? { HairStyle.catalog.first { $0.styleKey == styleKey } }
}

struct FaceAnalysisResult: Decodable {
    let faceShape: String
    let undertone: String
    let eyeColour: String
    let hairColour: String
    let recommendations: [StyleRecommendation]

    var faceShapeDisplay: String { faceShape.capitalized }
    var undertoneDisplay: String { undertone.capitalized }
}
