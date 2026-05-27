import SwiftUI

struct HomeView: View {
    @Bindable var appState: AppState
    var onStyleSelect: (HairStyle) -> Void
    var onCustom: () -> Void
    var onEdit: (HairStyle) -> Void
    var onSettings: () -> Void
    var onHistory: () -> Void
    var onPaywall: () -> Void

    private var allStyles: [HairStyle] {
        HairStyle.catalog + appState.customStyles
    }

    private var filteredStyles: [HairStyle] {
        allStyles.filter { style in
            let matchesCategory: Bool
            switch appState.homeSelectedCategory {
            case "All":       matchesCategory = true
            case "Favorites": matchesCategory = appState.isFavorite(style.id)
            case "Custom":    matchesCategory = style.isCustom
            default:          matchesCategory = style.category == appState.homeSelectedCategory || style.gender == appState.homeSelectedCategory
            }
            let matchesSearch = appState.homeSearchText.isEmpty || style.name.localizedCaseInsensitiveContains(appState.homeSearchText)
            return matchesCategory && matchesSearch
        }
    }

    private var categories: [String] {
        var base = ["Favorites", "All", "Male", "Female", "Wedding", "Salon", "Casual", "Bold"]
        if !appState.customStyles.isEmpty { base.append("Custom") }
        return base
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            searchBar
            categoryChips
            styleGrid
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.hairBg)
        .safeAreaInset(edge: .bottom) {
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
                        .frame(width: 36, height: 36)
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .white.opacity(0.4), radius: 4, x: 0, y: 0)
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
            TextField("Search styles…", text: $appState.homeSearchText)
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
                ForEach(categories, id: \.self) { cat in
                    CategoryChip(label: cat, selected: appState.homeSelectedCategory == cat) {
                        appState.homeSelectedCategory = cat
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
                    StyleCardView(
                        style: style,
                        action: { onStyleSelect(style) },
                        isFavorited: appState.isFavorite(style.id),
                        onFavoriteToggle: { appState.toggleFavorite(style.id) },
                        onEdit: style.isCustom ? { onEdit(style) } : nil,
                        onDelete: style.isCustom ? { appState.deleteCustomStyle(id: style.id) } : nil
                    )
                }
            }
            .padding(.horizontal, DS.paddingPage)
            .padding(.top, 4)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var customStyleFAB: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.4)
            Button(action: onCustom) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Create Custom Style")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: DS.buttonHeight)
                .background(LinearGradient.hairBrand)
                .clipShape(RoundedRectangle(cornerRadius: DS.radiusButton))
            }
            .padding(.horizontal, DS.paddingPage)
            .padding(.top, 10)
            .padding(.bottom, 12)
        }
        .background(.regularMaterial)
    }
}
