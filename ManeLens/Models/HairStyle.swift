import SwiftUI

struct HairStyle: Identifiable, Hashable {
    let id: Int
    let name: String
    let category: String
    let gender: String          // "Male", "Female", "Unisex"
    let hairColor: Color
    let gradientColors: [Color]
    let description: String
    let styleKey: String
    var isNew: Bool = false
    var sampleImages: [String] = []  // Asset names; falls back to HairFaceView when empty

    static func == (lhs: HairStyle, rhs: HairStyle) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Style Catalog
extension HairStyle {
    static let catalog: [HairStyle] = [

        // ── Existing styles (gender assigned) ──────────────────────────────

        HairStyle(
            id: 1, name: "Classic Groom", category: "Wedding", gender: "Male",
            hairColor: Color(red: 0.118, green: 0.055, blue: 0.259),
            gradientColors: [
                Color(red: 0.051, green: 0.020, blue: 0.125),
                Color(red: 0.176, green: 0.082, blue: 0.412),
                Color(red: 0.298, green: 0.157, blue: 0.596),
            ],
            description: "A timeless, structured cut that blends clean sides with a polished top — perfect for the big day.",
            styleKey: "indian_groom_slick",
            sampleImages: ["sample_indian_groom_slick_1", "sample_indian_groom_slick_2"]
        ),
        HairStyle(
            id: 2, name: "Korean Wolf Cut", category: "Salon", gender: "Unisex",
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
            id: 3, name: "Indian Bridal Updo", category: "Wedding", gender: "Female",
            hairColor: Color(red: 0.478, green: 0.082, blue: 0.082),
            gradientColors: [
                Color(red: 0.102, green: 0.020, blue: 0.020),
                Color(red: 0.361, green: 0.063, blue: 0.063),
                Color(red: 0.612, green: 0.125, blue: 0.125),
            ],
            description: "An elaborate swept-up style adorned with layers and volume, ideal for traditional ceremonies.",
            styleKey: "indian_wedding_updo",
            sampleImages: ["sample_indian_wedding_updo_1"]
        ),
        HairStyle(
            id: 4, name: "French Crop Fade", category: "Casual", gender: "Male",
            hairColor: Color(red: 0.063, green: 0.063, blue: 0.227),
            gradientColors: [
                Color(red: 0.031, green: 0.031, blue: 0.063),
                Color(red: 0.078, green: 0.078, blue: 0.165),
                Color(red: 0.157, green: 0.157, blue: 0.282),
            ],
            description: "Short, clean and sharp — a low-maintenance crop with a high-contrast fade that suits any occasion.",
            styleKey: "french_crop_fade",
            sampleImages: ["sample_french_crop_fade_1", "sample_french_crop_fade_2"]
        ),
        HairStyle(
            id: 5, name: "Beach Waves", category: "Bold", gender: "Female",
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
            id: 6, name: "Curtain Bangs", category: "Salon", gender: "Unisex",
            hairColor: Color(red: 0.361, green: 0.188, blue: 0.094),
            gradientColors: [
                Color(red: 0.071, green: 0.031, blue: 0.020),
                Color(red: 0.290, green: 0.141, blue: 0.082),
                Color(red: 0.541, green: 0.333, blue: 0.208),
            ],
            description: "Soft, face-framing bangs that split naturally at the center, giving a relaxed, editorial feel.",
            styleKey: "curtain_bangs"
        ),

        // ── Male styles ────────────────────────────────────────────────────

        HairStyle(
            id: 7, name: "Buzz Cut", category: "Casual", gender: "Male",
            hairColor: Color(red: 0.180, green: 0.110, blue: 0.055),
            gradientColors: [
                Color(red: 0.063, green: 0.039, blue: 0.020),
                Color(red: 0.149, green: 0.094, blue: 0.047),
                Color(red: 0.255, green: 0.165, blue: 0.082),
            ],
            description: "Ultra-short, uniform length all over — minimal effort, maximum confidence. Clean and military-sharp.",
            styleKey: "buzz_cut",
            sampleImages: ["sample_buzz_cut_1", "sample_buzz_cut_2"]
        ),
        HairStyle(
            id: 8, name: "Classic Pompadour", category: "Salon", gender: "Male",
            hairColor: Color(red: 0.102, green: 0.063, blue: 0.031),
            gradientColors: [
                Color(red: 0.039, green: 0.024, blue: 0.012),
                Color(red: 0.094, green: 0.059, blue: 0.031),
                Color(red: 0.180, green: 0.118, blue: 0.063),
            ],
            description: "Voluminous, swept-back top with tight sides — a retro-inspired statement that commands the room.",
            styleKey: "classic_pompadour",
            sampleImages: ["sample_classic_pompadour_1", "sample_classic_pompadour_2"]
        ),
        HairStyle(
            id: 9, name: "Man Bun", category: "Casual", gender: "Male",
            hairColor: Color(red: 0.302, green: 0.188, blue: 0.094),
            gradientColors: [
                Color(red: 0.094, green: 0.059, blue: 0.031),
                Color(red: 0.235, green: 0.145, blue: 0.071),
                Color(red: 0.412, green: 0.263, blue: 0.133),
            ],
            description: "Long hair tied into a relaxed bun at the crown — effortlessly cool and practical for every season.",
            styleKey: "man_bun",
            sampleImages: ["sample_man_bun_1", "sample_man_bun_2"]
        ),
        HairStyle(
            id: 10, name: "Disconnected Undercut", category: "Bold", gender: "Male",
            hairColor: Color(red: 0.059, green: 0.059, blue: 0.059),
            gradientColors: [
                Color(red: 0.020, green: 0.020, blue: 0.020),
                Color(red: 0.059, green: 0.059, blue: 0.059),
                Color(red: 0.118, green: 0.118, blue: 0.118),
            ],
            description: "Shaved sides with a dramatic length contrast on top — a bold, high-fashion cut with serious edge.",
            styleKey: "disconnected_undercut",
            sampleImages: ["sample_disconnected_undercut_1", "sample_disconnected_undercut_2"]
        ),
        HairStyle(
            id: 11, name: "Textured Quiff", category: "Salon", gender: "Male",
            hairColor: Color(red: 0.149, green: 0.094, blue: 0.047),
            gradientColors: [
                Color(red: 0.059, green: 0.039, blue: 0.020),
                Color(red: 0.122, green: 0.078, blue: 0.039),
                Color(red: 0.220, green: 0.149, blue: 0.078),
            ],
            description: "A modern twist on the classic quiff — textured, tousled, and styled with a natural matte finish.",
            styleKey: "textured_quiff",
            isNew: true,
            sampleImages: ["sample_textured_quiff_1", "sample_textured_quiff_2"]
        ),

        // ── Female styles ──────────────────────────────────────────────────

        HairStyle(
            id: 12, name: "Classic Bob", category: "Salon", gender: "Female",
            hairColor: Color(red: 0.220, green: 0.133, blue: 0.063),
            gradientColors: [
                Color(red: 0.078, green: 0.047, blue: 0.024),
                Color(red: 0.176, green: 0.106, blue: 0.051),
                Color(red: 0.310, green: 0.196, blue: 0.094),
            ],
            description: "A clean, chin-length cut with blunt ends — timeless, chic, and flattering on every face shape.",
            styleKey: "classic_bob"
        ),
        HairStyle(
            id: 13, name: "Pixie Cut", category: "Bold", gender: "Female",
            hairColor: Color(red: 0.141, green: 0.094, blue: 0.047),
            gradientColors: [
                Color(red: 0.051, green: 0.035, blue: 0.016),
                Color(red: 0.118, green: 0.078, blue: 0.039),
                Color(red: 0.220, green: 0.149, blue: 0.078),
            ],
            description: "Short, daring, and deeply feminine — the pixie is a statement of effortless confidence.",
            styleKey: "pixie_cut"
        ),
        HairStyle(
            id: 14, name: "Long Straight", category: "Casual", gender: "Female",
            hairColor: Color(red: 0.063, green: 0.039, blue: 0.020),
            gradientColors: [
                Color(red: 0.024, green: 0.016, blue: 0.008),
                Color(red: 0.059, green: 0.039, blue: 0.020),
                Color(red: 0.118, green: 0.078, blue: 0.039),
            ],
            description: "Sleek, pin-straight locks flowing well past the shoulders — classic elegance at its purest.",
            styleKey: "long_straight"
        ),
        HairStyle(
            id: 15, name: "Side Swept Bangs", category: "Salon", gender: "Female",
            hairColor: Color(red: 0.467, green: 0.298, blue: 0.133),
            gradientColors: [
                Color(red: 0.122, green: 0.078, blue: 0.031),
                Color(red: 0.361, green: 0.224, blue: 0.094),
                Color(red: 0.596, green: 0.396, blue: 0.188),
            ],
            description: "Caramel waves swept softly to one side, framing the face with romantic, cascading texture.",
            styleKey: "side_swept_bangs"
        ),
        HairStyle(
            id: 16, name: "Braided Bridal", category: "Wedding", gender: "Female",
            hairColor: Color(red: 0.118, green: 0.039, blue: 0.039),
            gradientColors: [
                Color(red: 0.047, green: 0.016, blue: 0.016),
                Color(red: 0.094, green: 0.031, blue: 0.031),
                Color(red: 0.176, green: 0.063, blue: 0.063),
            ],
            description: "Intricate braids woven into an elegant updo — perfect for a bride who wants tradition with artistry.",
            styleKey: "braided_bridal_updo"
        ),
        HairStyle(
            id: 17, name: "Reception Waves", category: "Wedding", gender: "Female",
            hairColor: Color(red: 0.663, green: 0.533, blue: 0.318),
            gradientColors: [
                Color(red: 0.196, green: 0.149, blue: 0.078),
                Color(red: 0.510, green: 0.396, blue: 0.220),
                Color(red: 0.773, green: 0.647, blue: 0.431),
            ],
            description: "Soft, glamorous waves with champagne-gold tones — ideal for a wedding reception or evening event.",
            styleKey: "reception_waves"
        ),
        HairStyle(
            id: 18, name: "Platinum Blonde", category: "Bold", gender: "Female",
            hairColor: Color(red: 0.878, green: 0.847, blue: 0.780),
            gradientColors: [
                Color(red: 0.459, green: 0.439, blue: 0.400),
                Color(red: 0.718, green: 0.698, blue: 0.639),
                Color(red: 0.918, green: 0.898, blue: 0.839),
            ],
            description: "Ice-cold platinum from root to tip — the boldest statement in hair, for those who own every room.",
            styleKey: "platinum_blonde",
            isNew: true
        ),
        HairStyle(
            id: 19, name: "Balayage", category: "Salon", gender: "Female",
            hairColor: Color(red: 0.502, green: 0.345, blue: 0.169),
            gradientColors: [
                Color(red: 0.102, green: 0.063, blue: 0.024),
                Color(red: 0.373, green: 0.239, blue: 0.102),
                Color(red: 0.647, green: 0.471, blue: 0.235),
            ],
            description: "Hand-painted sun-kissed highlights blending from deep roots to honey ends — effortlessly dimensional.",
            styleKey: "balayage_highlights",
            isNew: true
        ),
        HairStyle(
            id: 20, name: "Ivy League", category: "Casual", gender: "Male",
            hairColor: Color(red: 0.388, green: 0.251, blue: 0.125),
            gradientColors: [
                Color(red: 0.102, green: 0.063, blue: 0.031),
                Color(red: 0.298, green: 0.188, blue: 0.094),
                Color(red: 0.510, green: 0.333, blue: 0.165),
            ],
            description: "A longer, side-parted crew cut with a polished finish — smart, clean and eternally preppy.",
            styleKey: "ivy_league",
            sampleImages: ["sample_ivy_league_1", "sample_ivy_league_2"]
        ),
    ]

    static let categories = ["All", "Male", "Female", "Wedding", "Salon", "Casual", "Bold"]
}
