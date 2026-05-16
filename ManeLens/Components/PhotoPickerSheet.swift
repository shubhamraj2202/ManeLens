import SwiftUI

private struct RecentPhoto: Identifiable {
    let id: String
    let label: String
    let hairColor: Color
    let bgColors: [Color]
}

private let recentPhotos: [RecentPhoto] = [
    RecentPhoto(id: "p1", label: "Today",
                hairColor: Color(red: 0.24, green: 0.17, blue: 0.12),
                bgColors: [Color(red: 0.10, green: 0.08, blue: 0.06)]),
    RecentPhoto(id: "p2", label: "2 days ago",
                hairColor: Color(red: 0.10, green: 0.10, blue: 0.16),
                bgColors: [Color(red: 0.06, green: 0.06, blue: 0.09)]),
    RecentPhoto(id: "p3", label: "Last week",
                hairColor: Color(red: 0.29, green: 0.21, blue: 0.14),
                bgColors: [Color(red: 0.12, green: 0.09, blue: 0.07)]),
    RecentPhoto(id: "p4", label: "Mar 12",
                hairColor: Color(red: 0.18, green: 0.11, blue: 0.07),
                bgColors: [Color(red: 0.09, green: 0.06, blue: 0.03)]),
    RecentPhoto(id: "p5", label: "Feb 28",
                hairColor: Color(red: 0.36, green: 0.23, blue: 0.13),
                bgColors: [Color(red: 0.16, green: 0.10, blue: 0.06)]),
]

struct PhotoPickerSheet: View {
    @Binding var isPresented: Bool
    let onSelect: () -> Void

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Recent photos section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("RECENT PHOTOS")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.hairTextSec)
                                .kerning(0.6)
                            Spacer()
                            Button("See All") {}
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.hairPurple)
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(recentPhotos) { photo in
                                    Button(action: { onSelect(); isPresented = false }) {
                                        VStack(alignment: .leading, spacing: 5) {
                                            HairFaceView(
                                                hairColor: photo.hairColor,
                                                bgColors: photo.bgColors
                                            )
                                            .frame(width: 88, height: 110)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)

                                            Text(photo.label)
                                                .font(.system(size: 11))
                                                .foregroundStyle(Color.hairTextSec)
                                                .lineLimit(1)
                                        }
                                    }
                                    .frame(width: 88)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Source options
                    VStack(spacing: 8) {
                        SourceRow(icon: "camera.fill",         title: "Take Photo",          subtitle: "Use your camera",        action: { onSelect(); isPresented = false })
                        SourceRow(icon: "photo.on.rectangle",  title: "Choose from Library", subtitle: "Pick from Photos",       action: { onSelect(); isPresented = false })
                        SourceRow(icon: "folder.fill",         title: "Browse Files",        subtitle: "Import from Files app",  action: { onSelect(); isPresented = false })
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Add a photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                        .foregroundStyle(Color.hairPurple)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

private struct SourceRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.hairPurpleAlpha)
                        .frame(width: 42, height: 42)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(Color.hairPurple)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.hairText)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.hairTextSec)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.hairTextSec)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
