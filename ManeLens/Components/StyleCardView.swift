import SwiftUI

struct StyleCardView: View {
    let style: HairStyle
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottom) {
                // Card image
                StyleHeroView(style: style)
                    .aspectRatio(5/6, contentMode: .fill)
                    .clipped()

                // Bottom gradient overlay
                LinearGradient(
                    colors: [.clear, .black.opacity(0.85)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                // Style name
                HStack {
                    Text(style.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 10)

                // Category tag (top-left)
                VStack {
                    HStack {
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
                    Spacer()
                }
                .padding(8)
            }
        }
        .aspectRatio(5/6, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))
        .shadow(color: .black.opacity(0.14), radius: 7, x: 0, y: 2)
        .scaleEffect(pressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: pressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }
}
