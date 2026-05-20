import SwiftUI

struct HistoryView: View {
    @Bindable var appState: AppState
    var onBack: () -> Void
    var onItemSelect: (GenerationRecord) -> Void

    @State private var selectedFilter = "All"
    @State private var isEditing = false
    @State private var selectedIDs: Set<UUID> = []

    private let filters = ["All", "Last 7 days"]

    private var filteredHistory: [GenerationRecord] {
        switch selectedFilter {
        case "Last 7 days":
            let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
            return appState.history.filter { $0.date >= cutoff }
        default:
            return appState.history
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenNav(
                title: "History",
                onBack: onBack,
                trailing: appState.history.isEmpty ? nil : AnyView(editButton)
            )

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
        .safeAreaInset(edge: .bottom) {
            if isEditing {
                editingToolbar
            }
        }
    }

    private var editButton: some View {
        Button(isEditing ? "Done" : "Edit") {
            withAnimation(.easeInOut(duration: 0.2)) {
                isEditing.toggle()
                if !isEditing { selectedIDs.removeAll() }
            }
        }
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
                ForEach(filteredHistory) { record in
                    HistoryCard(
                        record: record,
                        isEditing: isEditing,
                        isSelected: selectedIDs.contains(record.id)
                    ) {
                        if isEditing {
                            if selectedIDs.contains(record.id) {
                                selectedIDs.remove(record.id)
                            } else {
                                selectedIDs.insert(record.id)
                            }
                        } else {
                            onItemSelect(record)
                        }
                    }
                }
            }
            .padding(.horizontal, DS.paddingPage)
            .padding(.bottom, isEditing ? 100 : 40)
        }
    }

    private var editingToolbar: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation {
                    appState.history.removeAll { selectedIDs.contains($0.id) }
                    selectedIDs.removeAll()
                    if appState.history.isEmpty { isEditing = false }
                }
            } label: {
                Text(selectedIDs.isEmpty ? "Delete Selected" : "Delete (\(selectedIDs.count))")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(selectedIDs.isEmpty ? Color.hairTextSec : .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(selectedIDs.isEmpty ? Color.black.opacity(0.07) : Color(red: 0.937, green: 0.267, blue: 0.267))
                    .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))
            }
            .disabled(selectedIDs.isEmpty)

            Button {
                withAnimation {
                    appState.history.removeAll()
                    selectedIDs.removeAll()
                    isEditing = false
                }
            } label: {
                Text("Clear All")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(red: 0.937, green: 0.267, blue: 0.267))
                    .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))
            }
        }
        .padding(.horizontal, DS.paddingPage)
        .padding(.top, 12)
        .padding(.bottom, 36)
        .background(
            LinearGradient(colors: [.white.opacity(0), .white], startPoint: .top, endPoint: UnitPoint(x: 0.5, y: 0.3))
                .ignoresSafeArea()
        )
    }
}

private struct HistoryCard: View {
    let record: GenerationRecord
    let isEditing: Bool
    let isSelected: Bool
    let onTap: () -> Void

    private var relativeDate: String {
        let cal = Calendar.current
        if cal.isDateInToday(record.date) { return "Today" }
        if cal.isDateInYesterday(record.date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: record.date)
    }

    var body: some View {
        Button(action: onTap) {
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

                    if isEditing {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 22))
                            .foregroundStyle(isSelected ? Color.hairPurple : .white)
                            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
                            .padding(6)
                    } else if record.liked {
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
            .shadow(color: .black.opacity(isSelected ? 0.20 : 0.10), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.hairPurple : Color.clear, lineWidth: 2)
            )
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
