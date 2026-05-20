import SwiftUI

struct GeneratingView: View {
    let styleName: String
    var onCancel: () -> Void

    @State private var rotation: Double = 0
    @State private var pulse: Bool = false
    @State private var tipIndex: Int = 0
    @State private var progress: Double = 0

    private let tips = [
        "Matching lighting to your photo…",
        "Preserving every detail of your features…",
        "Crafting a natural hairline…",
        "Finalising texture and depth…",
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.hairBg, Color.hairPurpleLight],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Animated lens
                ZStack {
                    // Orbiting particles
                    ForEach(0..<8, id: \.self) { i in
                        Circle()
                            .fill(i % 2 == 0 ? Color.hairPurple : Color.hairPink)
                            .frame(width: i % 2 == 0 ? 10 : 7, height: i % 2 == 0 ? 10 : 7)
                            .opacity(0.3 + (0.7 * Double(i) / 8.0))
                            .offset(y: -60)
                            .rotationEffect(.degrees(Double(i) * 45 + rotation))
                    }

                    // Inner pulsing circle
                    Circle()
                        .fill(LinearGradient.hairBrand)
                        .frame(width: 110, height: 110)
                        .scaleEffect(pulse ? 1.06 : 0.97)
                        .shadow(color: Color.hairPurple.opacity(0.4), radius: 16, x: 0, y: 8)

                    Image(systemName: "sparkles")
                        .font(.system(size: 38))
                        .foregroundStyle(.white)
                }
                .frame(width: 160, height: 160)

                // Text
                VStack(spacing: 8) {
                    Text("Styling your hair…")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.hairText)

                    Text("This usually takes 8–12 seconds")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.hairTextSec)

                    Text(tips[tipIndex])
                        .font(.system(size: 13))
                        .foregroundStyle(Color.hairPurple)
                        .frame(height: 20)
                        .transition(.opacity)
                        .id(tipIndex)
                        .animation(.easeInOut(duration: 0.4), value: tipIndex)
                }
                .multilineTextAlignment(.center)

                // Progress bar — fills to 90% over 12 s, then holds until API responds
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.hairPurple.opacity(0.12))
                            .frame(height: 4)

                        Capsule()
                            .fill(LinearGradient.hairBrand)
                            .frame(width: max(0, geo.size.width * progress), height: 4)
                            .animation(.linear(duration: 0.1), value: progress)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 32)

                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 0.937, green: 0.267, blue: 0.267).opacity(0.7))
                }

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear { startAnimations() }
    }

    private func startAnimations() {
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            rotation = 360
        }

        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
            pulse = true
        }

        Timer.scheduledTimer(withTimeInterval: 2.8, repeats: true) { _ in
            withAnimation { tipIndex = (tipIndex + 1) % tips.count }
        }

        // Progress fills to 90% over 12 s, then holds — ContentView's .task drives actual navigation
        let startTime = Date()
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            let elapsed = Date().timeIntervalSince(startTime)
            let p = min(0.9, elapsed / 12.0)
            progress = p
            if p >= 0.9 { timer.invalidate() }
        }
    }
}
