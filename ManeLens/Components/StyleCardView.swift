import SwiftUI

struct StyleCardView: View {
    let style: HairStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                cardImage
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                // Bottom gradient
                LinearGradient(
                    colors: [.clear, .black.opacity(0.85)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                // Top badges — category top-left, NEW top-right
                VStack {
                    HStack(alignment: .top) {
                        Text(style.category)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.black.opacity(0.40))
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        Spacer()
                        if style.isNew {
                            Text("NEW")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Color.hairPink)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(8)
                    Spacer()
                }

                // Style name at bottom — centered
                VStack {
                    Spacer()
                    Text(style.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 10)
                }
            }
        }
        .frame(height: 165)
        .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))
        .shadow(color: .black.opacity(0.14), radius: 7, x: 0, y: 2)
        .buttonStyle(StyleCardButtonStyle())
    }

    @ViewBuilder
    private var cardImage: some View {
        if let first = style.sampleImages.first, let uiImage = UIImage(named: first) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            StyleHeroView(style: style)
        }
    }
}

// ButtonStyle so the system arbitrates tap vs ScrollView pan correctly —
// prior simultaneousGesture(DragGesture(minimumDistance:0)) blocked scroll.
private struct StyleCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
