import SwiftUI

struct OnboardingView: View {
    var onDone: () -> Void

    @State private var currentSlide = 0

    private struct Slide {
        let title: String
        let subtitle: String
        let bgColors: [Color]
    }

    private let slides: [Slide] = [
        Slide(
            title: "See Yourself With Any Hairstyle",
            subtitle: "AI-powered previews in seconds — no filters, no wigs.",
            bgColors: [
                Color(red: 0.051, green: 0.020, blue: 0.125),
                Color(red: 0.176, green: 0.082, blue: 0.412),
                Color(red: 0.486, green: 0.227, blue: 0.929),
            ]
        ),
        Slide(
            title: "Indian Weddings. Japanese Salons. Bold Looks.",
            subtitle: "Curated styles you won't find anywhere else.",
            bgColors: [
                Color(red: 0.102, green: 0.020, blue: 0.020),
                Color(red: 0.361, green: 0.063, blue: 0.063),
                Color(red: 0.925, green: 0.286, blue: 0.600),
            ]
        ),
        Slide(
            title: "Your Face Stays You",
            subtitle: "We change only the hair. Photorealistic results, every time.",
            bgColors: [
                Color(red: 0.020, green: 0.055, blue: 0.102),
                Color(red: 0.059, green: 0.176, blue: 0.361),
                Color(red: 0.102, green: 0.290, blue: 0.612),
            ]
        ),
    ]

    var body: some View {
        let slide = slides[currentSlide]

        ZStack {
            LinearGradient(
                colors: slide.bgColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentSlide)

            VStack(spacing: 0) {
                // Visual area
                Group {
                    if currentSlide == 0 { slide0Visual }
                    else if currentSlide == 1 { slide1Visual }
                    else { slide2Visual }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .animation(.easeInOut(duration: 0.4), value: currentSlide)

                Spacer()

                // Text + controls
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Text(slide.title)
                            .font(.system(size: 30, weight: .bold, design: .default))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)

                        Text(slide.subtitle)
                            .font(.system(size: 16))
                            .foregroundStyle(.white.opacity(0.65))
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                    .padding(.horizontal, 28)
                    .animation(.easeInOut(duration: 0.3), value: currentSlide)

                    // Pagination dots
                    HStack(spacing: 6) {
                        ForEach(0..<slides.count, id: \.self) { i in
                            Capsule()
                                .fill(i == currentSlide ? Color.white : Color.white.opacity(0.35))
                                .frame(width: i == currentSlide ? 22 : 7, height: 7)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentSlide)
                                .onTapGesture { currentSlide = i }
                        }
                    }

                    // CTA
                    if currentSlide == slides.count - 1 {
                        PrimaryButton(title: "Get 3 Free Generations", icon: "✨", variant: .gradient, action: onDone)
                    } else {
                        PrimaryButton(title: "Continue", variant: .white) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentSlide += 1
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }

    // MARK: Slide visuals
    private var slide0Visual: some View {
        VStack {
            Spacer()
            ZStack {
                // Before/After split card
                HStack(spacing: 0) {
                    HairFaceView(
                        hairColor: Color(red: 0.24, green: 0.24, blue: 0.24),
                        bgColors: [Color(red: 0.1, green: 0.1, blue: 0.16)]
                    )
                    .frame(width: 110, height: 130)

                    Rectangle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 2)

                    HairFaceView(
                        hairColor: Color(red: 0.627, green: 0.408, blue: 0.157),
                        bgColors: [Color(red: 0.10, green: 0.08, blue: 0.04)]
                    )
                    .frame(width: 110, height: 130)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 12)

                VStack {
                    Spacer()
                    Text("BEFORE · AFTER")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .kerning(0.8)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 4)
                        .background(.black.opacity(0.4))
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(.bottom, 14)
                }
                .frame(width: 222, height: 130)
            }
            Spacer()
        }
    }

    private var slide1Visual: some View {
        HStack(alignment: .center, spacing: 12) {
            let styles = [HairStyle.catalog[0], HairStyle.catalog[1], HairStyle.catalog[4]]
            let offsets: [CGFloat] = [10, 0, 14]
            ForEach(Array(zip(styles, offsets)), id: \.0.id) { style, offset in
                HairFaceView(
                    hairColor: style.hairColor,
                    bgColors: style.gradientColors
                )
                .frame(width: 90, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                .offset(y: offset)
            }
        }
        .padding(.horizontal, 20)
    }

    private var slide2Visual: some View {
        VStack(spacing: 20) {
            HStack(spacing: 24) {
                ForEach(["lock.fill", "person.fill"], id: \.self) { icon in
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.10))
                            .frame(width: 72, height: 72)
                            .overlay(
                                Circle().stroke(.white.opacity(0.2), lineWidth: 1.5)
                            )
                        Image(systemName: icon)
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(["Only your hair changes", "Face stays identical", "Photos never stored"], id: \.self) { item in
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.green)
                        Text(item)
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(.white.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
