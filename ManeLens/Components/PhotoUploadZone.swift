import SwiftUI

struct PhotoUploadZone: View {
    let filled: Bool
    let hairColor: Color
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        ZStack {
            if filled {
                // Show the face illustration as if a photo was selected
                HairFaceView(
                    hairColor: hairColor,
                    bgColors: [Color(red: 0.133, green: 0.133, blue: 0.133), Color(red: 0.067, green: 0.067, blue: 0.067)]
                )
                .frame(height: 180)

                // Remove button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onRemove) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 26, height: 26)
                                .background(.black.opacity(0.55))
                                .clipShape(Circle())
                        }
                        .padding(8)
                    }
                    Spacer()
                }
            } else {
                // Empty state
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.hairPurpleAlpha)
                            .frame(width: 52, height: 52)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.hairPurple)
                    }

                    Text("Take or Upload Photo")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.hairPurple)

                    Text("Front-facing selfie, clear face")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.hairTextSec)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .contentShape(Rectangle())
                .onTapGesture(perform: onTap)
            }
        }
        .background(filled ? Color.clear : Color.hairPurpleLight)
        .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))
        .overlay(
            RoundedRectangle(cornerRadius: DS.radiusCard)
                .strokeBorder(
                    filled ? Color.clear : Color.hairPurple.opacity(0.3),
                    style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                )
        )
    }
}
