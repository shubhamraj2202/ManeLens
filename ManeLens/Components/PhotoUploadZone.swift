import SwiftUI

struct PhotoUploadZone: View {
    let photo: UIImage?
    let hairColor: Color
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        ZStack {
            if let photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipped()

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
        .background(photo == nil ? Color.hairPurpleLight : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))
        .overlay(
            RoundedRectangle(cornerRadius: DS.radiusCard)
                .strokeBorder(
                    photo == nil ? Color.hairPurple.opacity(0.3) : Color.clear,
                    style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                )
        )
    }
}
