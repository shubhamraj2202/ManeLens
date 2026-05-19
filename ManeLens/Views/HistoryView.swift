import SwiftUI

struct HistoryView: View {
    @Bindable var appState: AppState
    var onBack: () -> Void
    var onItemSelect: (GenerationRecord) -> Void

    @State private var selectedFilter = "All"
    private let filters = ["All", "Favorites", "Last 7 days"]

    var body: some View {
        VStack(spacing: 0) {
            ScreenNav(title: "History", onBack: onBack, trailing: appState.history.isEmpty ? nil : AnyView(editButton))

            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(filters, id: \.self) { f in
                        CategoryChip(label: f, selected: selectedFilter == f) {
                            selectedFilter = f
                        }
                    }
                }
                .padding(.horizontal, DS.paddingPage)
            }
            .padding(.bottom, 12)

            if appState.history.isEmpty {
                emptyState
            } else {
                historyGrid
            }
        }
        .background(Color.hairBg)
        .navigationBarHidden(true)
    }

    private var editButton: some View {
        Button("Edit") {}
            .font(.system(size: 15))
            .foregroundStyle(Color.hairPurple)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            Text("🪞")
                .font(.system(size: 52))

            Text("No generations yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.hairText)

            Text("Pick a style to get started")
                .font(.system(size: 14))
                .foregroundStyle(Color.hairTextSec)
                .multilineTextAlignment(.center)

            PrimaryButton(title: "Browse Styles", variant: .secondary, action: onBack)
                .frame(width: 180)

            Spacer()
        }
        .padding(.horizontal, DS.paddingPage)
    }

    private var historyGrid: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                ForEach(appState.history) { record in
                    HistoryCard(record: record) {
                        onItemSelect(record)
                    }
                }
            }
            .padding(.horizontal, DS.paddingPage)
            .padding(.bottom, 40)
        }
    }
}

private struct HistoryCard: View {
    let record: GenerationRecord
    let action: () -> Void

    private var relativeDate: String {
        let cal = Calendar.current
        if cal.isDateInToday(record.date) { return "Today" }
        if cal.isDateInYesterday(record.date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: record.date)
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    if let img = record.resultImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        HairFaceView(
                            hairColor: record.style.hairColor,
                            bgColors: record.style.gradientColors
                        )
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    if record.liked {
                        Text("❤️")
                            .font(.system(size: 14))
                            .padding(6)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(record.style.name)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.hairText)
                        .lineLimit(1)

                    Text(relativeDate)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.hairTextSec)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.white)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.10), radius: 5, x: 0, y: 2)
        }
    }
}
