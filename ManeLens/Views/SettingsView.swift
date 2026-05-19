import SwiftUI
import StoreKit

struct SettingsView: View {
    @Bindable var appState: AppState
    var onBack: () -> Void
    var onGetMore: () -> Void

    @State private var appearance = "System"
    @State private var saveToPhotos = true
    @State private var hapticFeedback = true
    @State private var showClearHistoryAlert = false
    @State private var showDeleteDataAlert = false

    var body: some View {
        VStack(spacing: 0) {
            ScreenNav(title: "Settings", onBack: onBack)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Account
                    SettingsSection(title: "Account") {
                        SettingsRow(label: "Credits Remaining", trailing: AnyView(
                            HStack(spacing: 8) {
                                CreditPill(credits: appState.credits)
                                Button(action: onGetMore) {
                                    Text("+ Get More")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.hairPurple)
                                }
                            }
                        ))
                        Divider().padding(.leading, 16)
                        Button {
                            Task { await appState.creditManager.restore() }
                        } label: {
                            SettingsRow(label: "Restore Purchases", hasChevron: false, trailing: AnyView(chevron))
                        }
                        .buttonStyle(.plain)
                        .alert("Restore Failed",
                               isPresented: Binding(
                                get: { appState.creditManager.restoreError != nil },
                                set: { if !$0 { appState.creditManager.restoreError = nil } }
                               )) {
                            Button("OK") { appState.creditManager.restoreError = nil }
                        } message: {
                            Text(appState.creditManager.restoreError ?? "")
                        }
                    }

                    // Preferences
                    SettingsSection(title: "Preferences") {
                        SettingsRow(label: "Appearance", trailing: AnyView(
                            Picker("", selection: $appearance) {
                                ForEach(["Light", "Dark", "System"], id: \.self) { Text($0) }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 160)
                        ))
                        Divider().padding(.leading, 16)
                        SettingsRow(label: "Save originals to Photos", trailing: AnyView(
                            Toggle("", isOn: $saveToPhotos)
                                .tint(Color.hairPurple)
                                .labelsHidden()
                        ))
                        Divider().padding(.leading, 16)
                        SettingsRow(label: "Haptic feedback", trailing: AnyView(
                            Toggle("", isOn: $hapticFeedback)
                                .tint(Color.hairPurple)
                                .labelsHidden()
                        ))
                    }

                    // About
                    SettingsSection(title: "About") {
                        Button { rateApp() } label: {
                            SettingsRow(icon: "star.fill", label: "Rate Hair Lens - AI", trailing: AnyView(chevron))
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, 16)

                        Button { shareApp() } label: {
                            SettingsRow(icon: "square.and.arrow.up", label: "Share App", trailing: AnyView(chevron))
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, 16)

                        Button { openURL("mailto:shubhamraj2202@gmail.com") } label: {
                            SettingsRow(icon: "questionmark.circle", label: "Help & FAQ", trailing: AnyView(chevron))
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, 16)

                        Button { openURL("mailto:shubhamraj2202@gmail.com") } label: {
                            SettingsRow(icon: "envelope", label: "Contact Support", trailing: AnyView(chevron))
                        }
                        .buttonStyle(.plain)
                    }

                    // Legal
                    SettingsSection(title: "Legal") {
                        Button { openURL("https://aurax.ai/privacy") } label: {
                            SettingsRow(label: "Privacy Policy", trailing: AnyView(chevron))
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, 16)

                        Button { openURL("https://aurax.ai/terms") } label: {
                            SettingsRow(label: "Terms of Service", trailing: AnyView(chevron))
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.leading, 16)

                        SettingsRow(label: "Acknowledgments", trailing: AnyView(chevron))
                    }

                    // Danger Zone
                    SettingsSection(title: "Danger Zone") {
                        Button { showClearHistoryAlert = true } label: {
                            SettingsRow(label: "Clear History", isDestructive: true, trailing: nil)
                        }
                        .buttonStyle(.plain)
                        .alert("Clear History?", isPresented: $showClearHistoryAlert) {
                            Button("Clear", role: .destructive) { appState.history.removeAll() }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("All past generations will be removed. This cannot be undone.")
                        }

                        Divider().padding(.leading, 16)

                        Button { showDeleteDataAlert = true } label: {
                            SettingsRow(label: "Delete All Data", isDestructive: true, trailing: nil)
                        }
                        .buttonStyle(.plain)
                        .alert("Delete All Data?", isPresented: $showDeleteDataAlert) {
                            Button("Delete", role: .destructive) {
                                appState.history.removeAll()
                                appState.creditManager.resetCredits()
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("Your history and credits will be permanently deleted.")
                        }
                    }

                    // Footer
                    Text("Hair Lens - AI v1.0 (Build 2)\nMade with ❤️ by Shubham")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.hairTextSec)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, DS.paddingPage)
                .padding(.top, 4)
                .padding(.bottom, 40)
            }
        }
        .background(Color.hairBgOff)
        .navigationBarHidden(true)
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.hairTextSec)
    }

    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private func shareApp() {
        let appURL = URL(string: "https://apps.apple.com/app/id6745742590")!
        let av = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController?
            .present(av, animated: true)
    }

    private func openURL(_ string: String) {
        guard let url = URL(string: string) else { return }
        UIApplication.shared.open(url)
    }
}

private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.hairTextSec)
                .kerning(0.6)
                .padding(.leading, 6)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))
            .overlay(
                RoundedRectangle(cornerRadius: DS.radiusCard)
                    .stroke(Color.hairBorder, lineWidth: 1)
            )
        }
    }
}

private struct SettingsRow: View {
    var icon: String? = nil
    let label: String
    var isDestructive: Bool = false
    var hasChevron: Bool = true
    var trailing: AnyView?

    var body: some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.hairPurple)
                    .frame(width: 24)
            }

            Text(label)
                .font(.system(size: 16))
                .foregroundStyle(isDestructive ? Color(red: 0.937, green: 0.267, blue: 0.267) : Color.hairText)

            Spacer()

            if let trailing {
                trailing
            } else if hasChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.hairTextSec)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
