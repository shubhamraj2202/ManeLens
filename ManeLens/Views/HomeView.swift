import SwiftUI

struct HomeView: View {
    @Bindable var appState: AppState
    var onStyleSelect: (HairStyle) -> Void
    var onCustom: () -> Void
    var onSettings: () -> Void
    var onHistory: () -> Void
    var onPaywall: () -> Void

    @State private var selectedCategory = "All"
    @State private var searchText = ""

    private var filteredStyles: [HairStyle] {
        HairStyle.catalog.filter { style in
            (selectedCategory == "All"
                || style.category == selectedCategory
                || style.gender == selectedCategory) &&
            (searchText.isEmpty || style.name.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Header
                header

                // Search
                searchBar

                // Category chips
                categoryChips

                // Style grid
                styleGrid
            }
            .background(Color.hairBg)

            // FAB
            customStyleFAB
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            // Logo
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient.hairBrand)
                        .frame(width: 34, height: 34)
                    Text("💇")
                        .font(.system(size: 18))
                }
                Text("Hair Lens")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.hairText)
            }

            Spacer()

            // Right controls
            Button(action: onPaywall) {
                CreditPill(credits: appState.credits)
            }

            Button(action: onHistory) {
                Image(systemName: "clock")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.hairText)
            }

            Button(action: onSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.hairText)
            }
        }
        .padding(.horizontal, DS.paddingPage)
        .padding(.vertical, 8)
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(Color.hairTextSec)
            TextField("Search styles…", text: $searchText)
                .font(.system(size: 15))
                .foregroundStyle(Color.hairText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: DS.radiusInput))
        .padding(.horizontal, DS.paddingPage)
        .padding(.bottom, 12)
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(HairStyle.categories, id: \.self) { cat in
                    CategoryChip(label: cat, selected: selectedCategory == cat) {
                        selectedCategory = cat
                    }
                }
            }
            .padding(.horizontal, DS.paddingPage)
        }
        .padding(.bottom, 14)
    }

    private var styleGrid: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                ForEach(filteredStyles) { style in
                    StyleCardView(style: style) {
                        onStyleSelect(style)
                    }
                }
            }
            .padding(.horizontal, DS.paddingPage)
            .padding(.bottom, 110)
        }
        .frame(maxHeight: .infinity)
    }

    private var customStyleFAB: some View {
        Button(action: onCustom) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                Text("Custom Style")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .frame(height: 50)
            .background(LinearGradient.hairBrand)
            .clipShape(Capsule())
            .shadow(color: Color.hairPurple.opacity(0.45), radius: 12, x: 0, y: 6)
        }
        .padding(.bottom, 40)
    }
}
