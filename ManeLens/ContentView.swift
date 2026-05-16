import SwiftUI

enum Screen {
    case onboarding
    case home
    case styleDetail(HairStyle)
    case customPrompt
    case generating(HairStyle?)
    case result(HairStyle?)
    case history
    case paywall
    case settings
}

struct ContentView: View {
    @State private var appState = AppState()
    @State private var screen: Screen = .onboarding
    @State private var screenStack: [Screen] = []

    var body: some View {
        ZStack {
            switch screen {
            case .onboarding:
                OnboardingView {
                    navigate(to: .home)
                }
                .transition(.opacity)

            case .home:
                HomeView(
                    appState: appState,
                    onStyleSelect: { style in navigate(to: .styleDetail(style)) },
                    onCustom: { navigate(to: .customPrompt) },
                    onSettings: { navigate(to: .settings) },
                    onHistory: { navigate(to: .history) },
                    onPaywall: { navigate(to: .paywall) }
                )
                .transition(.opacity)

            case .styleDetail(let style):
                StyleDetailView(
                    style: style,
                    appState: appState,
                    onBack: { navigateBack() },
                    onGenerate: {
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
                        if appState.credits > 0 {
                            appState.consumeCredit()
                            navigate(to: .generating(nil))
                        } else {
                            navigate(to: .paywall)
                        }
                    }
                )
                .transition(.move(edge: .trailing))

            case .generating(let style):
                GeneratingView(
                    styleName: style?.name ?? "Custom Style",
                    onCancel: { navigateBack() },
                    onDone: {
                        if let style { appState.recordGeneration(style: style) }
                        navigate(to: .result(style))
                    }
                )
                .transition(.opacity)

            case .result(let style):
                ResultView(
                    style: style,
                    appState: appState,
                    onBack: { navigateBack() },
                    onTryAnother: {
                        // Clear stack back to home
                        screenStack = []
                        navigate(to: .home)
                    }
                )
                .transition(.move(edge: .trailing))

            case .history:
                HistoryView(
                    appState: appState,
                    onBack: { navigateBack() },
                    onItemSelect: { record in navigate(to: .result(record.style)) }
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
            }
        }
        .animation(.easeInOut(duration: 0.3), value: screenDescription)
    }

    // MARK: Navigation helpers
    private func navigate(to newScreen: Screen) {
        screenStack.append(screen)
        withAnimation { screen = newScreen }
    }

    private func navigateBack() {
        guard let previous = screenStack.popLast() else { return }
        withAnimation { screen = previous }
    }

    // Used as animation value identity
    private var screenDescription: String {
        switch screen {
        case .onboarding:       return "onboarding"
        case .home:             return "home"
        case .styleDetail(let s): return "detail-\(s.id)"
        case .customPrompt:     return "custom"
        case .generating:       return "generating"
        case .result:           return "result"
        case .history:          return "history"
        case .paywall:          return "paywall"
        case .settings:         return "settings"
        }
    }
}

#Preview {
    ContentView()
}
