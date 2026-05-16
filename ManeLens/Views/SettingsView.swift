import SwiftUI

struct SettingsView: View {
    @Bindable var appState: AppState
    var onBack: () -> Void
    var onGetMore: () -> Void

    @State private var saveToPhotos = true
    @State private var hapticFeedback = true
    @State private var appearance = "System"

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
                        SettingsRow(label: "Restore Purchases", trailing: AnyView(chevron), hasChevron: false)
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
                        ForEach([
                            ("star.fill",     "Rate Hair Lens - AI"),
                            ("square.and.arrow.up", "Share App"),
                            ("questionmark.circle", "Help & FAQ"),
                            ("envelope",      "Contact Support"),
                        ], id: \.1) { (icon, label) in
                            SettingsRow(
                                icon: icon,
                                label: label,
                                trailing: AnyView(chevron)
                            )
                            if label != "Contact Support" {
                                Divider().padding(.leading, 16)
                            }
                        }
                    }

                    // Legal
                    SettingsSection(title: "Legal") {
                        ForEach(["Privacy Policy", "Terms of Service", "Acknowledgments"], id: \.self) { label in
                            SettingsRow(label: label, trailing: AnyView(chevron))
                            if label != "Acknowledgments" {
                                Divider().padding(.leading, 16)
                            }
                        }
                    }

                    // Danger Zone
                    SettingsSection(title: "Danger Zone") {
                        SettingsRow(label: "Clear History", isDestructive: true, trailing: nil)
                        Divider().padding(.leading, 16)
                        SettingsRow(label: "Delete All Data", isDestructive: true, trailing: nil)
                    }

                    // Footer
                    Text("Hair Lens - AI v1.0 (Build 1)\nMade with ❤️ by Shubham")
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
