import SwiftUI

// MARK: - FaceAnalyserView (two states: analysing → results)

struct FaceAnalyserView: View {
    @Bindable var appState: AppState
    let profile: PersonProfile
    let photo: UIImage
    var onBack: () -> Void
    var onTryStyle: (HairStyle) -> Void
    var onSaveToTimeline: (FaceAnalysisResult) -> Void

    @State private var phase: Phase = .analysing
    @State private var stepIndex: Int = 0
    @State private var barProgress: Double = 0
    @State private var result: FaceAnalysisResult? = nil

    enum Phase { case analysing, results }

    private let steps: [(icon: String, label: String)] = [
        ("person.crop.rectangle", "Detecting face shape…"),
        ("paintpalette.fill",     "Reading skin undertone…"),
        ("eye.fill",              "Identifying eye colour…"),
        ("wand.and.stars",        "Matching best styles…"),
    ]

    var body: some View {
        switch phase {
        case .analysing: analysingView
        case .results:   resultsView
        }
    }

    // MARK: - State A: Analysing

    private var analysingView: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                colors: [Color.hairBg, Color.hairPurpleLight],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Spinning gradient ring around avatar
                SpinningRingAvatar(profile: profile, photo: photo)

                VStack(spacing: 6) {
                    Text("Analysing \(profile.name.split(separator: " ").first.map(String.init) ?? "your")'s face…")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.hairText)
                        .multilineTextAlignment(.center)
                    Text("This takes about 8 seconds")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.hairTextSec)
                }

                // Step rows
                VStack(spacing: 16) {
                    ForEach(steps.indices, id: \.self) { i in
                        AnalysisStepRow(
                            icon: steps[i].icon,
                            label: steps[i].label,
                            state: stepState(i),
                            barProgress: i == stepIndex ? barProgress : (i < stepIndex ? 1 : 0)
                        )
                    }
                }
                .padding(.horizontal, 28)

                Spacer()
            }

            Button("Cancel") { onBack() }
                .font(.system(size: 14))
                .foregroundStyle(Color.red.opacity(0.75))
                .padding(.top, 16)
                .padding(.trailing, DS.paddingPage)
        }
        .task { await driveAnalysis() }
    }

    private func stepState(_ i: Int) -> AnalysisStepRow.StepState {
        if i < stepIndex  { return .done }
        if i == stepIndex { return .active }
        return .pending
    }

    @MainActor
    private func driveAnalysis() async {
        // Kick off the real API call in parallel
        async let apiCall = APIClient.analyse(photo: photo)

        // Animate steps sequentially (~2s each)
        for i in 0..<steps.count {
            stepIndex = i
            barProgress = 0
            let duration = 0.95
            let start = Date()
            while true {
                let elapsed = Date().timeIntervalSince(start)
                let p = min(1.0, elapsed / duration)
                barProgress = p
                if p >= 1.0 { break }
                try? await Task.sleep(nanoseconds: 16_000_000) // ~60fps
            }
        }

        // Await the real API result
        do {
            let analysisResult = try await apiCall
            result = analysisResult
        } catch {
            // Fallback: still show results with minimal data
            result = FaceAnalysisResult(
                faceShape: "oval", undertone: "warm",
                eyeColour: "dark brown", hairColour: "black",
                recommendations: []
            )
        }
        withAnimation(.easeInOut(duration: 0.35)) { phase = .results }
    }

    // MARK: - State B: Results

    private var resultsView: some View {
        guard let r = result else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(spacing: 0) {
                ScreenNav(title: "Face Analysis", onBack: onBack,
                    trailing: AnyView(
                        Button {
                            shareAnalysis(r)
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 17))
                                .foregroundStyle(Color.hairPurple)
                        }
                    )
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Profile header
                        profileHeader

                        // Face profile card
                        faceProfileCard(r)

                        // Recommendations
                        recommendationsSection(r)

                        Button("Analyse Again — 1 credit") {}
                            .font(.system(size: 12))
                            .foregroundStyle(Color.hairTextSec)
                            .padding(.bottom, 8)
                    }
                    .padding(.horizontal, DS.paddingPage)
                    .padding(.top, 14)
                    .padding(.bottom, 100)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.hairBgOff)
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(title: "Save to Timeline", icon: "📅", variant: .gradient) {
                    if let r = result { onSaveToTimeline(r) }
                }
                .padding(.horizontal, DS.paddingPage)
                .padding(.top, 12)
                .padding(.bottom, 28)
                .background(.regularMaterial)
            }
        )
    }

    private var profileHeader: some View {
        VStack(spacing: 8) {
            ZStack {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.hairPurple, lineWidth: 3)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.hairPurpleAlpha, lineWidth: 6)
                            .frame(width: 92, height: 92)
                    )
            }
            .frame(width: 80, height: 80)

            Text(profile.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.hairText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.hairBg)
        .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))
        .overlay(RoundedRectangle(cornerRadius: DS.radiusCard).stroke(Color.hairBorder, lineWidth: 1))
    }

    private func faceProfileCard(_ r: FaceAnalysisResult) -> some View {
        let traits: [(icon: String, label: String, value: String)] = [
            ("person.crop.rectangle", "Face Shape",  r.faceShapeDisplay),
            ("paintpalette.fill",     "Undertone",   r.undertoneDisplay),
            ("eye.fill",              "Eye Colour",  r.eyeColour),
            ("scissors",              "Hair Colour", r.hairColour),
        ]
        return VStack(alignment: .leading, spacing: 12) {
            Text("Face Profile")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.hairText)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(traits, id: \.label) { t in
                    HStack(spacing: 8) {
                        Image(systemName: t.icon)
                            .font(.system(size: 16))
                            .foregroundStyle(Color.hairPurple)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(t.label)
                                .font(.system(size: 10))
                                .foregroundStyle(Color.hairTextSec)
                            Text(t.value)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.hairText)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.hairPurpleLight)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(16)
        .background(Color.hairBg)
        .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))
        .overlay(RoundedRectangle(cornerRadius: DS.radiusCard).stroke(Color.hairBorder, lineWidth: 1))
    }

    private func recommendationsSection(_ r: FaceAnalysisResult) -> some View {
        let firstName = profile.name.split(separator: " ").first.map(String.init) ?? "You"
        let validRecs = r.recommendations.filter { $0.hairStyle != nil }
        return VStack(alignment: .leading, spacing: 12) {
            Text("Styles That Suit \(firstName)")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.hairText)

            ForEach(Array(validRecs.enumerated()), id: \.element.id) { idx, rec in
                RecommendationCard(
                    rec: rec,
                    rank: idx + 1,
                    isFavorited: appState.isFavorite(rec.hairStyle!.id),
                    onFavourite: { appState.toggleFavorite(rec.hairStyle!.id) },
                    onTry: { if let style = rec.hairStyle { onTryStyle(style) } }
                )
            }
        }
    }

    private func shareAnalysis(_ r: FaceAnalysisResult) {
        let text = """
        Face Analysis for \(profile.name)
        Face Shape: \(r.faceShapeDisplay)
        Undertone: \(r.undertoneDisplay)
        Eye Colour: \(r.eyeColour)
        Hair Colour: \(r.hairColour)

        Top style: \(r.recommendations.first?.styleKey ?? "–")
        """
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?
            .rootViewController?.present(av, animated: true)
    }
}

// MARK: - SpinningRingAvatar

private struct SpinningRingAvatar: View {
    let profile: PersonProfile
    let photo: UIImage
    @State private var rotating = false

    var body: some View {
        ZStack {
            // Spinning conic gradient ring
            Circle()
                .trim(from: 0, to: 1)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.hairPurple, .hairPink, .hairPurple]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 3)
                )
                .frame(width: 128, height: 128)
                .rotationEffect(.degrees(rotating ? 360 : 0))
                .animation(.linear(duration: 2.4).repeatForever(autoreverses: false), value: rotating)

            // Inner white ring
            Circle()
                .fill(Color.hairBg)
                .frame(width: 120, height: 120)

            // Photo
            Image(uiImage: photo)
                .resizable()
                .scaledToFill()
                .frame(width: 116, height: 116)
                .clipShape(Circle())
        }
        .onAppear { rotating = true }
    }
}

// MARK: - AnalysisStepRow

struct AnalysisStepRow: View {
    enum StepState { case pending, active, done }

    let icon: String
    let label: String
    let state: StepState
    let barProgress: Double

    var body: some View {
        HStack(spacing: 12) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(circleBackground)
                    .frame(width: 36, height: 36)
                if state == .done {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundStyle(state == .active ? Color.hairPurple : Color.hairTextSec)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(label)
                    .font(.system(size: 13, weight: state == .active ? .semibold : .regular))
                    .foregroundStyle(state == .active ? Color.hairPurple : Color.hairText)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.black.opacity(0.08))
                            .frame(height: 3)
                        Capsule()
                            .fill(LinearGradient.hairBrand)
                            .frame(width: geo.size.width * barProgress, height: 3)
                    }
                }
                .frame(height: 3)
            }
        }
        .opacity(state == .pending ? 0.32 : 1)
        .animation(.easeInOut(duration: 0.4), value: state)
    }

    private var circleBackground: Color {
        switch state {
        case .done:    return Color.hairPurple
        case .active:  return Color.hairPurpleAlpha
        case .pending: return Color.black.opacity(0.06)
        }
    }
}

// MARK: - RecommendationCard

private struct RecommendationCard: View {
    let rec: StyleRecommendation
    let rank: Int
    let isFavorited: Bool
    let onFavourite: () -> Void
    let onTry: () -> Void

    private var gradientColors: [Color] {
        if let style = rec.hairStyle {
            return style.gradientColors
        }
        return [Color(red:0.08,green:0.08,blue:0.16), Color(red:0.18,green:0.18,blue:0.30), Color(red:0.29,green:0.29,blue:0.47)]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Gradient header strip
            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 76)

                HStack {
                    Text("#\(rank)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(.black.opacity(0.55))
                        .clipShape(Capsule())
                    Spacer()
                    Text("\(rec.matchPercent)% match")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(LinearGradient.hairBrand)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 8)
            }

            // Body
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(rec.styleKey)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.hairText)
                    if let style = rec.hairStyle {
                        Text(style.category)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.hairTextSec)
                    }
                }
                Spacer()
                // Favourite heart toggle
                Button(action: onFavourite) {
                    Image(systemName: isFavorited ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundStyle(isFavorited ? Color.red : Color.hairTextSec)
                }
                .padding(.trailing, 6)

                // Try with profile photo → goes to StyleDetailView with photo pre-loaded
                Button("Try →", action: onTry)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.hairPurple)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 6)

            Text(rec.reason)
                .font(.system(size: 12))
                .foregroundStyle(Color.hairTextSec)
                .lineLimit(3)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
        }
        .background(Color.hairBg)
        .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 2)
    }
}
