import SwiftUI

enum Screen {
    case onboarding
    case home
    case styleDetail(HairStyle)
    case customPrompt
    case editCustomStyle(HairStyle)
    case generating(HairStyle?)
    case result(HairStyle?)
    case history
    case paywall
    case settings
    // Profiles
    case profiles
    case profileDetail(UUID)
    case timelineEntryDetail(UUID, UUID)   // profileId, entryId
    case faceAnalyser(UUID, UIImage)       // profileId, photo
}

struct ContentView: View {
    @State private var appState = AppState()
    @State private var screen: Screen = ContentView.initialScreen()
    @State private var screenStack: [Screen] = []

    private static func initialScreen() -> Screen {
        UserDefaults.standard.bool(forKey: "hairlens_has_seen_onboarding") ? .home : .onboarding
    }

    var body: some View {
        ZStack {
            switch screen {
            case .onboarding:
                OnboardingView {
                    UserDefaults.standard.set(true, forKey: "hairlens_has_seen_onboarding")
                    navigate(to: .home)
                }
                .transition(.opacity)

            case .home:
                HomeView(
                    appState: appState,
                    onStyleSelect: { style in navigate(to: .styleDetail(style)) },
                    onCustom: { navigate(to: .customPrompt) },
                    onEdit: { style in navigate(to: .editCustomStyle(style)) },
                    onSettings: { navigate(to: .settings) },
                    onHistory: { navigate(to: .history) },
                    onPaywall: { navigate(to: .paywall) },
                    onProfiles: { navigate(to: .profiles) }
                )
                .transition(.opacity)

            case .styleDetail(let style):
                StyleDetailView(
                    style: style,
                    appState: appState,
                    onBack: { navigateBack() },
                    onGenerate: {
                        guard appState.hasPhoto else { return }
                        if appState.credits > 0 {
                            appState.consumeCredit()
                            navigate(to: .generating(style))
                        } else {
                            navigate(to: .paywall)
                        }
                    },
                    onCustom: { navigate(to: .customPrompt) }
                )
                .transition(.move(edge: .trailing))

            case .customPrompt:
                CustomPromptView(
                    appState: appState,
                    onBack: { navigateBack() },
                    onGenerate: {
                        guard appState.hasPhoto else { return }
                        if appState.credits > 0 {
                            appState.consumeCredit()
                            navigate(to: .generating(nil))
                        } else {
                            navigate(to: .paywall)
                        }
                    }
                )
                .transition(.move(edge: .trailing))

            case .editCustomStyle(let style):
                CustomPromptView(
                    appState: appState,
                    onBack: { navigateBack() },
                    onGenerate: {
                        guard appState.hasPhoto else { return }
                        if appState.credits > 0 {
                            appState.consumeCredit()
                            navigate(to: .generating(style))
                        } else {
                            navigate(to: .paywall)
                        }
                    },
                    editingStyle: style
                )
                .transition(.move(edge: .trailing))

            case .generating(let style):
                GeneratingView(
                    styleName: style?.name ?? "Custom Style",
                    onCancel: {
                        appState.refundCredit()
                        navigateBack()
                    }
                )
                .transition(.opacity)
                .task {
                    await runGeneration(style: style)
                }

            case .result(let style):
                ResultView(
                    style: style,
                    appState: appState,
                    onBack: { navigateBack() },
                    onTryAnother: {
                        screenStack = []
                        navigate(to: .home)
                    }
                )
                .transition(.move(edge: .trailing))

            case .history:
                HistoryView(
                    appState: appState,
                    onBack: { navigateBack() },
                    onItemSelect: { record in
                        appState.selectedPhoto = record.originalImage
                        appState.generatedImage = record.resultImage
                        navigate(to: .result(record.style))
                    }
                )
                .transition(.move(edge: .trailing))

            case .paywall:
                PaywallView(
                    appState: appState,
                    onClose: { navigateBack() }
                )
                .transition(.move(edge: .bottom))

            case .settings:
                SettingsView(
                    appState: appState,
                    onBack: { navigateBack() },
                    onGetMore: { navigate(to: .paywall) }
                )
                .transition(.move(edge: .trailing))

            // MARK: - Profiles

            case .profiles:
                ProfilesListView(
                    appState: appState,
                    onBack: { navigateBack() },
                    onSelectProfile: { profile in navigate(to: .profileDetail(profile.id)) }
                )
                .transition(.move(edge: .trailing))

            case .profileDetail(let profileId):
                if let profile = appState.profiles.first(where: { $0.id == profileId }) {
                    ProfileDetailView(
                        appState: appState,
                        profileId: profileId,
                        onBack: { navigateBack() },
                        onAnalyse: { prof, photo in
                            guard appState.credits > 0 else { navigate(to: .paywall); return }
                            appState.consumeCredit()
                            navigate(to: .faceAnalyser(prof.id, photo))
                        },
                        onUseForStyle: { photo in
                            appState.selectedPhoto = photo
                            navigateBack()
                        },
                        onEntryDetail: { _, entry in
                            navigate(to: .timelineEntryDetail(profileId, entry.id))
                        }
                    )
                    .transition(.move(edge: .trailing))
                    .id(profile.id)
                }

            case .timelineEntryDetail(let profileId, let entryId):
                if let profile = appState.profiles.first(where: { $0.id == profileId }) {
                    TimelineEntryDetailView(
                        appState: appState,
                        profile: profile,
                        entryId: entryId,
                        onBack: { navigateBack() },
                        onAnalyse: { prof, photo in
                            guard appState.credits > 0 else { navigate(to: .paywall); return }
                            appState.consumeCredit()
                            navigate(to: .faceAnalyser(prof.id, photo))
                        },
                        onGenerateStyle: { photo in
                            appState.selectedPhoto = photo
                            // Pop back to home so they can pick a style
                            screenStack = []
                            withAnimation { screen = .home }
                        },
                        onDeleteEntry: { navigateBack() }
                    )
                    .transition(.move(edge: .trailing))
                }

            case .faceAnalyser(let profileId, let photo):
                if let profile = appState.profiles.first(where: { $0.id == profileId }) {
                    FaceAnalyserView(
                        profile: profile,
                        photo: photo,
                        onBack: {
                            appState.refundCredit()
                            navigateBack()
                        },
                        onTryStyle: { style in
                            navigate(to: .styleDetail(style))
                        },
                        onSaveToTimeline: { result in
                            saveAnalysisToTimeline(result: result, profile: profile, photo: photo)
                            navigateBack()
                        }
                    )
                    .transition(.opacity)
                }
            }
        }
        .preferredColorScheme(appState.themeMode.colorScheme)
        .animation(.easeInOut(duration: 0.3), value: screenDescription)
        .alert("Generation Failed", isPresented: Binding(
            get: { appState.generationError != nil },
            set: { if !$0 { appState.generationError = nil } }
        )) {
            Button("OK") { appState.generationError = nil }
        } message: {
            Text(appState.generationError ?? "")
        }
    }

    // MARK: - Save analysis result as timeline entry

    private func saveAnalysisToTimeline(result: FaceAnalysisResult, profile: PersonProfile, photo: UIImage) {
        let entryId = UUID()
        let path = ProfilesStore.shared.savePhoto(photo, profileId: profile.id, entryId: entryId)
        let topStyle = result.recommendations.first?.styleKey
        let note = "Face analysis — \(result.faceShapeDisplay) face, \(result.undertoneDisplay) undertone. Top pick: \(topStyle ?? "—")"
        let entry = TimelineEntry(id: entryId, date: .now, photoPath: path, note: note, styleKey: topStyle)
        if let idx = appState.profiles.firstIndex(where: { $0.id == profile.id }) {
            appState.profiles[idx].entries.insert(entry, at: 0)
        }
    }

    // MARK: - Generation

    @MainActor
    private func runGeneration(style: HairStyle?) async {
        guard let photo = appState.selectedPhoto else {
            navigateBack()
            return
        }

        do {
            let effectiveStyleKey: String? = (style?.isCustom == true) ? nil : style?.styleKey
            let effectiveCustomPrompt: String? = style?.customPrompt
                ?? (appState.customPromptText.isEmpty ? nil : appState.customPromptText)
            let result = try await APIClient.generate(
                photo: photo,
                styleKey: effectiveStyleKey,
                customPrompt: effectiveCustomPrompt
            )

            guard !Task.isCancelled else {
                appState.refundCredit()
                return
            }

            appState.generatedImage = result
            if let style { appState.recordGeneration(style: style, original: photo, result: result) }
            withAnimation { screen = .result(style) }

        } catch is CancellationError {
            // onCancel already refunded
        } catch let error as APIError {
            appState.refundCredit()
            if case .paymentRequired = error {
                navigateBack()
                navigate(to: .paywall)
            } else {
                appState.generationError = error.userFacingMessage
                navigateBack()
            }
        } catch {
            appState.refundCredit()
            appState.generationError = "An unexpected error occurred. Please try again."
            navigateBack()
        }
    }

    // MARK: - Navigation helpers

    private func navigate(to newScreen: Screen) {
        screenStack.append(screen)
        withAnimation { screen = newScreen }
    }

    private func navigateBack() {
        guard let previous = screenStack.popLast() else { return }
        withAnimation { screen = previous }
    }

    private var screenDescription: String {
        switch screen {
        case .onboarding:                        return "onboarding"
        case .home:                              return "home"
        case .styleDetail(let s):                return "detail-\(s.id)"
        case .customPrompt:                      return "custom"
        case .editCustomStyle(let s):            return "edit-\(s.id)"
        case .generating:                        return "generating"
        case .result:                            return "result"
        case .history:                           return "history"
        case .paywall:                           return "paywall"
        case .settings:                          return "settings"
        case .profiles:                          return "profiles"
        case .profileDetail(let id):             return "profileDetail-\(id)"
        case .timelineEntryDetail(let p, let e): return "entry-\(p)-\(e)"
        case .faceAnalyser(let id, _):           return "analyser-\(id)"
        }
    }
}

#Preview {
    ContentView()
}
