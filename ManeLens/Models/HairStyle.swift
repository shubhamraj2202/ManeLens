import SwiftUI

struct HairStyle: Identifiable, Hashable {
    let id: Int
    let name: String
    let category: String
    let hairColor: Color
    let gradientColors: [Color]
    let description: String
    let styleKey: String
    var isNew: Bool = false

    static func == (lhs: HairStyle, rhs: HairStyle) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Style Catalog
extension HairStyle {
    static let catalog: [HairStyle] = [
        HairStyle(
            id: 1, name: "Classic Groom", category: "Wedding",
            hairColor: Color(red: 0.118, green: 0.055, blue: 0.259),
            gradientColors: [
                Color(red: 0.051, green: 0.020, blue: 0.125),
                Color(red: 0.176, green: 0.082, blue: 0.412),
                Color(red: 0.298, green: 0.157, blue: 0.596),
            ],
            description: "A timeless, structured cut that blends clean sides with a polished top — perfect for the big day.",
            styleKey: "indian_groom_slick"
        ),
        HairStyle(
            id: 2, name: "Korean Wolf Cut", category: "Salon",
            hairColor: Color(red: 0.478, green: 0.271, blue: 0.125),
            gradientColors: [
                Color(red: 0.071, green: 0.031, blue: 0.012),
                Color(red: 0.361, green: 0.188, blue: 0.063),
                Color(red: 0.690, green: 0.408, blue: 0.145),
            ],
            description: "A trendy layered cut with face-framing texture and shaggy ends, popularized by K-pop idols.",
            styleKey: "wolf_cut",
            isNew: true
        ),
        HairStyle(
            id: 3, name: "Indian Bridal Updo", category: "Wedding",
            hairColor: Color(red: 0.478, green: 0.082, blue: 0.082),
            gradientColors: [
                Color(red: 0.102, green: 0.020, blue: 0.020),
                Color(red: 0.361, green: 0.063, blue: 0.063),
                Color(red: 0.612, green: 0.125, blue: 0.125),
            ],
            description: "An elaborate swept-up style adorned with layers and volume, ideal for traditional ceremonies.",
            styleKey: "indian_wedding_updo"
        ),
        HairStyle(
            id: 4, name: "French Crop Fade", category: "Casual",
            hairColor: Color(red: 0.063, green: 0.063, blue: 0.227),
            gradientColors: [
                Color(red: 0.031, green: 0.031, blue: 0.063),
                Color(red: 0.078, green: 0.078, blue: 0.165),
                Color(red: 0.157, green: 0.157, blue: 0.282),
            ],
            description: "Short, clean and sharp — a low-maintenance crop with a high-contrast fade that suits any occasion.",
            styleKey: "french_crop_fade"
        ),
        HairStyle(
            id: 5, name: "Beach Waves", category: "Bold",
            hairColor: Color(red: 0.627, green: 0.408, blue: 0.157),
            gradientColors: [
                Color(red: 0.165, green: 0.082, blue: 0.020),
                Color(red: 0.478, green: 0.310, blue: 0.102),
                Color(red: 0.769, green: 0.533, blue: 0.220),
            ],
            description: "Effortless, sun-kissed waves with natural texture and movement for a carefree, confident look.",
            styleKey: "beach_blonde_waves"
        ),
        HairStyle(
            id: 6, name: "Curtain Bangs", category: "Salon",
            hairColor: Color(red: 0.361, green: 0.188, blue: 0.094),
            gradientColors: [
                Color(red: 0.071, green: 0.031, blue: 0.020),
                Color(red: 0.290, green: 0.141, blue: 0.082),
                Color(red: 0.541, green: 0.333, blue: 0.208),
            ],
            description: "Soft, face-framing bangs that split naturally at the center, giving a relaxed, editorial feel.",
            styleKey: "curtain_bangs"
        ),
    ]

    static let categories = ["All", "Wedding", "Salon", "Casual", "Bold"]
}
