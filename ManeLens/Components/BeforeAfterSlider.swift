import SwiftUI

struct BeforeAfterSlider: View {
    let beforeColors: [Color]
    let afterStyle: HairStyle

    @State private var sliderPosition: CGFloat = 0.48

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack {
                // Before (left)
                HairFaceView(
                    hairColor: Color(red: 0.18, green: 0.18, blue: 0.25),
                    bgColors: [Color(red: 0.10, green: 0.10, blue: 0.16), Color(red: 0.16, green: 0.15, blue: 0.25)]
                )

                // After (right, clipped)
                HairFaceView(
                    hairColor: afterStyle.hairColor,
                    bgColors: afterStyle.gradientColors
                )
                .clipShape(
                    Rectangle()
                        .offset(x: w * sliderPosition)
                )

                // Labels
                VStack {
                    HStack {
                        Text("BEFORE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .kerning(1)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.black.opacity(0.45))
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .padding(12)

                        Spacer()

                        Text("AFTER")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .kerning(1)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.black.opacity(0.45))
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .padding(12)
                    }
                    Spacer()
                }

                // Divider line + handle
                ZStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)

                    ZStack {
                        Circle()
                            .fill(Color.hairPurple)
                            .frame(width: 36, height: 36)
                            .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 2)

                        Image(systemName: "arrow.left.and.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 36, height: 36)
                    )
                }
                .offset(x: w * sliderPosition - w / 2)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        sliderPosition = max(0.03, min(0.97, value.location.x / w))
                    }
            )
        }
        .aspectRatio(1.05, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .background(Color.black)
    }
}
