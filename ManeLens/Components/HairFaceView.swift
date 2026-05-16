import SwiftUI

// Simplified face+hair silhouette illustration matching the design's SVG placeholders
struct HairFaceView: View {
    var hairColor: Color
    var bgColors: [Color]
    var showSilhouette: Bool = true

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: bgColors.isEmpty ? [Color(red: 0.1, green: 0.05, blue: 0.2)] : bgColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                if showSilhouette {
                    // Shoulders
                    Ellipse()
                        .fill(hairColor.opacity(0.6))
                        .frame(width: w * 1.5, height: h * 0.3)
                        .offset(y: h * 0.42)

                    // Neck
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(red: 0.941, green: 0.812, blue: 0.659).opacity(0.6))
                        .frame(width: w * 0.14, height: h * 0.1)
                        .offset(y: h * 0.23)

                    // Hair sides
                    RoundedRectangle(cornerRadius: 8)
                        .fill(hairColor)
                        .frame(width: w * 0.10, height: h * 0.28)
                        .offset(x: -w * 0.30, y: h * 0.04)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(hairColor)
                        .frame(width: w * 0.10, height: h * 0.28)
                        .offset(x: w * 0.30, y: h * 0.04)

                    // Face
                    Ellipse()
                        .fill(Color(red: 0.957, green: 0.851, blue: 0.722).opacity(0.88))
                        .frame(width: w * 0.38, height: h * 0.37)
                        .offset(y: -h * 0.04)

                    // Hair top (behind face)
                    Ellipse()
                        .fill(hairColor)
                        .frame(width: w * 0.62, height: h * 0.44)
                        .offset(y: -h * 0.13)
                }
            }
            .clipped()
        }
    }
}

// MARK: - Style card hero image
struct StyleHeroView: View {
    let style: HairStyle

    var body: some View {
        HairFaceView(
            hairColor: style.hairColor,
            bgColors: style.gradientColors
        )
    }
}

// MARK: - Before/after face (before = dark, after = styled)
struct BeforeFaceView: View {
    var body: some View {
        HairFaceView(
            hairColor: Color(red: 0.18, green: 0.18, blue: 0.25),
            bgColors: [Color(red: 0.1, green: 0.1, blue: 0.16), Color(red: 0.16, green: 0.15, blue: 0.25)]
        )
    }
}
